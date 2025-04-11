#!/bin/bash -l

#SBATCH -o %x.o%j
#SBATCH -A CFD162
#SBATCH -t 00:30:00
#SBATCH -q debug
#SBATCH -S 0
#SBATCH -N 1

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

SPACK_ENV_NAME=exawind-env
MY_EXAWIND_MANAGER=${PROJWORK}/cfd162/${USER}/exawind-manager
EXAWIND_EXE=exawind~amr_wind_gpu~nalu_wind_gpu
cmd "module load PrgEnv-gnu-amd/8.6.0"
cmd "module load amd-mixed/6.1.3"
cmd "module load rocm/6.1.3"
cmd "module load cray-mpich/8.1.28"
cmd "module load cray-python"
#Possibly necessary exports
#cmd "export FI_MR_CACHE_MONITOR=memhooks"
#cmd "export FI_CXI_RX_MATCH_MODE=software"
#cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"

cmd "export EXAWIND_MANAGER=${MY_EXAWIND_MANAGER}"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "spack load ${EXAWIND_EXE}"
cmd "which exawind"

cmd "srun -N 2 -n 2 --distribution=block:block --ntasks-per-node=1 --gpus-per-node=8 --gpu-bind=closest --cpu_bind=cores exawind --awind 1 --nwind 1 sphere.yaml"
