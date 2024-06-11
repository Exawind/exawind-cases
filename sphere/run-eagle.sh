#!/bin/bash -l

#SBATCH -J exawind-sphere
#SBATCH -o %x.o%j
#SBATCH -A hpcapps
#SBATCH -t 30
#SBATCH -N 1

set -e
cmd() {
  echo "+ $@"
  eval "$@"
}

cmd "export EXAWIND_MANAGER=/scratch/${USER}/exawind-manager"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate exawind-eagle"
cmd "spack load exawind~amr_wind_gpu~nalu_wind_gpu"
cmd "which exawind"
cmd "srun -N1 -n2 exawind --awind 1 --nwind 1 sphere.yaml"
