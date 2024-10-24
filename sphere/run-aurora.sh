#!/bin/bash -l

#PBS -A CSC249ADSE13_CNDA
#PBS -q EarlyAppAccess
#PBS -l select=1
#PBS -l walltime=30:00
#PBS -j oe

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

SPACK_ENV_NAME=exawind
MESH_PATH=/lus/flare/projects/CSC249ADSE13_CNDA/${USER}/exawind/files/meshes
MY_EXAWIND_MANAGER=/lus/flare/projects/CSC249ADSE13_CNDA/${USER}/exawind/exawind-manager

cmd "cd ${PBS_O_WORKDIR}"
cmd "module load python"
cmd "export EXAWIND_MANAGER=${MY_EXAWIND_MANAGER}"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "spack load exawind+amr_wind_gpu~nalu_wind_gpu"
cmd "export LD_PRELOAD=/opt/aurora/24.180.0/CNDA/oneapi/compiler/eng-20240629/lib/libsycl.so.8"
cmd "which exawind"

#Current possibly necessary exports
#cmd "export FI_MR_CACHE_MONITOR=memhooks"
#cmd "export FI_CXI_RX_MATCH_MODE=software"
#cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"
#cmd "export MPIR_CVAR_ENABLE_GPU=0"
#cmd "unset MPIR_CVAR_CH4_COLL_SELECTION_TUNING_JSON_FILE"
#cmd "unset MPIR_CVAR_COLL_SELECTION_TUNING_JSON_FILE"
#cmd "unset MPIR_CVAR_CH4_POSIX_COLL_SELECTION_TUNING_JSON_FILE"

#Update mesh path
sed -i "s|CHANGE_PATH|${MESH_PATH}|g" sphere-nalu.yaml || true

cmd "mpiexec -n 2 -ppn 2 -envall gpu_tile_compact.sh exawind --awind 1 --nwind 1 sphere.yaml"
