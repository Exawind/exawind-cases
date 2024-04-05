#!/bin/bash -l

#SBATCH -J single-turbine
#SBATCH -o %x.o%j
#SBATCH -A CFD162
#SBATCH -t 30
#SBATCH -q debug
#SBATCH -N 2

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

cmd "module load PrgEnv-amd"
cmd "module load amd/5.7.1"
cmd "module load cray-mpich/8.1.27"
cmd "export EXAWIND_MANAGER=${PROJWORK}/cfd162/${USER}/exawind-manager"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate exawind-frontier"
cmd "spack load exawind+amr_wind_gpu+nalu_wind_gpu"
cmd "which exawind"
cmd "export HIP_LAUNCH_BLOCKING=1"
cmd "export FI_MR_CACHE_MONITOR=memhooks"
cmd "export FI_CXI_RX_MATCH_MODE=software"
cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"
cmd "srun -N2 -n16 --gpus-per-node=8 --gpu-bind=closest exawind --awind 8 --nwind 8 nrel5mw.yaml"
