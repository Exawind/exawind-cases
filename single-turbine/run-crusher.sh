#!/bin/bash -l

#SBATCH -J single-turbine
#SBATCH -o %x.o%j
#SBATCH -A CFD116_crusher
#SBATCH -t 30
#SBATCH -N 2

set -e
cmd() {
  echo "+ $@"
  eval "$@"
}

cmd "module unload PrgEnv-cray"
cmd "module load PrgEnv-amd"
cmd "module load amd/5.4.3"
cmd "export SPACK_MANAGER=${MEMBERWORK}/cfd116/spack-manager-crusher"
cmd "source ${SPACK_MANAGER}/start.sh && spack-start"
cmd "spack env activate -d ${SPACK_MANAGER}/environments/exawind-crusher"
cmd "spack load exawind+amr_wind_gpu+nalu_wind_gpu"
cmd "spack load trilinos+rocm"
cmd "which exawind"
cmd "rm -rf mesh"
cmd "mkdir mesh"
cmd "export FI_CXI_RX_MATCH_MODE=software"
cmd "srun -N1 -n8 stk_balance.exe -o ./mesh/ -i ./nrel5mw_nearbody.exo"
cmd "srun -N2 -n16 --gpus-per-node=8 --gpu-bind=closest exawind --awind 8 --nwind 8 nrel5mw.yaml"
cmd "rm -r mesh"
