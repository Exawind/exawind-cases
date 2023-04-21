#!/bin/bash

#PBS -A CSC249ADSE13_CNDA
#PBS -q workq
#PBS -l select=1
#PBS -l walltime=30:00
#PBS -l filesystems=home
#PBS -j oe

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

cmd "cd $PBS_O_WORKDIR"
cmd "export SPACK_MANAGER=${HOME}/exawind/spack-manager"
cmd "source ${SPACK_MANAGER}/start.sh && spack-start"
cmd "spack env activate -d ${SPACK_MANAGER}/environments/exawind-sunspot"
cmd "spack load exawind+amr_wind_gpu~nalu_wind_gpu"
cmd "spack load trilinos"
cmd "which exawind"
cmd "mpiexec -n 2 -ppn 2 exawind --awind 1 --nwind 1 sphere.yaml"
