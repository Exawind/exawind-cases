#!/bin/bash -l

#PBS -A CSC249ADSE13_CNDA
#PBS -q workq
#PBS -l select=2
#PBS -l walltime=30:00
#PBS -j oe

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

#PBS does not appear to have an easily accesible env variable for this
NUM_NODES=2
SPACK_ENV_NAME=exawind-sunspot
MESH_PATH=/lus/gila/projects/CSC249ADSE13_CNDA/jrood/exawind/files
MY_EXAWIND_MANAGER=/lus/gila/projects/CSC249ADSE13_CNDA/jrood/exawind/exawind-manager

cmd "cd ${PBS_O_WORKDIR}"
cmd "export SPACK_PYTHON=python3.10"
cmd "export EXAWIND_MANAGER=${MY_EXAWIND_MANAGER}"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "spack load exawind+amr_wind_gpu~nalu_wind_gpu"
cmd "which exawind"

#Current possibly necessary exports
#cmd "export FI_MR_CACHE_MONITOR=memhooks"
#cmd "export FI_CXI_RX_MATCH_MODE=software"
#cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"
#cmd "export MPIR_CVAR_ENABLE_GPU=0"
cmd "unset MPIR_CVAR_CH4_COLL_SELECTION_TUNING_JSON_FILE"
cmd "unset MPIR_CVAR_COLL_SELECTION_TUNING_JSON_FILE"
cmd "unset MPIR_CVAR_CH4_POSIX_COLL_SELECTION_TUNING_JSON_FILE"

#Update mesh path
sed -i "s|CHANGE_PATH|${MESH_PATH}|g" nrel5mw_nalu.yaml || true

#+amr_wind_gpu~nalu_wind_gpu
cmd "python3.10 rank_file.py ${NUM_NODES}"
cmd "cat exawind.rank_file | sort -g > tmp.txt && mv tmp.txt exawind.rank_file"
AWIND_RANKS=$((${NUM_NODES}*12))
NWIND_RANKS=$((${NUM_NODES}*44))
TOTAL_RANKS=$((${NUM_NODES}*56))

cmd "mpiexec -np ${TOTAL_RANKS} -ppn 56 --rankfile exawind.rank_file -envall gpu_tile_compact.sh exawind --awind ${AWIND_RANKS} --nwind ${NWIND_RANKS} nrel5mw.yaml"
