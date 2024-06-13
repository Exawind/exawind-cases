#!/bin/bash -l

#SBATCH -J exawind-sphere
#SBATCH -o %x.o%j
#SBATCH -t 30
#SBATCH -A hpcapps
#SBATCH -N 1

set -e
cmd() {
  echo "+ $@"
  eval "$@"
}

cmd "module purge"
cmd "module load cray-python"
cmd "module load PrgEnv-intel/8.5.0"
cmd "module load libfabric/1.15.2.0"
cmd "module load cray-libsci/23.12.5"
cmd "module load intel/2023.2.0"
cmd "module load craype-network-ofi"
cmd "module load craype-x86-spr"
cmd "module load cray-mpich/8.1.28"
cmd "export EXAWIND_MANAGER=/scratch/${USER}/exawind-manager"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate exawind-kestrel"
cmd "spack load exawind~amr_wind_gpu~nalu_wind_gpu"
cmd "which exawind"
cmd "srun -N1 -n2 exawind --awind 1 --nwind 1 sphere.yaml"
