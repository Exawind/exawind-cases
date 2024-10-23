#!/bin/bash -l

#PBS -A CSC249ADSE13_CNDA
#PBS -q EarlyAppAccess
#PBS -l select=256
#PBS -l walltime=30:00
#PBS -j oe

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

#PBS does not appear to have an easily accesible env variable for querying this
NUM_NODES=256
SPACK_ENV_NAME=exawind
MY_EXAWIND_MANAGER=/lus/flare/projects/CSC249ADSE13_CNDA/rood/exawind/exawind-manager

cmd "cd ${PBS_O_WORKDIR}"
cmd "module load python"
cmd "export EXAWIND_MANAGER=${MY_EXAWIND_MANAGER}"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "spack load exawind+amr_wind_gpu~nalu_wind_gpu"
cmd "export LD_PRELOAD=/opt/aurora/24.180.0/CNDA/oneapi/compiler/eng-20240629/lib/libsycl.so.8"
cmd "which exawind"

#Current possibly necessary exports
cmd "export FI_MR_CACHE_MONITOR=memhooks"
cmd "export FI_CXI_RX_MATCH_MODE=software"
cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"
cmd "export FI_CXI_DEFAULT_CQ_SIZE=131072"
cmd "export FI_CXI_CQ_FILL_PERCENT=20"
#cmd "export MPIR_CVAR_ENABLE_GPU=0"
cmd "unset MPIR_CVAR_CH4_COLL_SELECTION_TUNING_JSON_FILE"
cmd "unset MPIR_CVAR_COLL_SELECTION_TUNING_JSON_FILE"
cmd "unset MPIR_CVAR_CH4_POSIX_COLL_SELECTION_TUNING_JSON_FILE"

#+amr_wind_gpu~nalu_wind_gpu
cmd "python3 ../tools/rank_file.py ${NUM_NODES}"
cmd "cat exawind.rank_file | sort -g > tmp.txt && mv tmp.txt exawind.rank_file"
AWIND_RANKS=$((${NUM_NODES}*12))
NWIND_RANKS=$((${NUM_NODES}*44))
TOTAL_RANKS=$((${NUM_NODES}*56))
cmd "mpiexec -np ${TOTAL_RANKS} -ppn 56 --rankfile exawind.rank_file -envall gpu_tile_compact.sh exawind --awind ${AWIND_RANKS} --nwind ${NWIND_RANKS} nrel5mw.yaml"
