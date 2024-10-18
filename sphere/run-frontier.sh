#!/bin/bash -l

#SBATCH -o %x.o%j
#SBATCH -A CFD162
#SBATCH -t 00:30:00
#SBATCH -q debug
#SBATCH -S 0
#SBATCH -N 4

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}


SPACK_ENV_NAME=exawind_latest
MY_EXAWIND_MANAGER=${PROJWORK}/cfd162/${USER}/exawind-manager
EXAWIND_EXE=exawind
cmd "module load PrgEnv-amd/8.5.0"
cmd "module load amd/6.0.0"
cmd "module load cray-mpich/8.1.27"
#cmd "module unload lfs-wrapper"
cmd "module load cray-python"
#Possibly necessary exports
cmd "export FI_MR_CACHE_MONITOR=memhooks"
cmd "export FI_CXI_RX_MATCH_MODE=software"
cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"

cmd "export EXAWIND_MANAGER=${MY_EXAWIND_MANAGER}"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "spack load ${EXAWIND_EXE}"
cmd "which exawind"


cmd "srun -N 4 -n 32 --gpus-per-node=8 --gpu-bind=closest exawind --awind 1 --nwind 31 sphere.yaml"

