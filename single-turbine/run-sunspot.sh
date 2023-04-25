#!/bin/bash

#PBS -A CSC249ADSE13_CNDA
#PBS -q workq
#PBS -l select=8
#PBS -l walltime=30:00
##PBS -l filesystems=home
#PBS -j oe

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

cmd "cd $PBS_O_WORKDIR"
cmd "export SPACK_MANAGER=/lus/gila/projects/CSC249ADSE13_CNDA/jrood/exawind/spack-manager"
cmd "source ${SPACK_MANAGER}/start.sh && spack-start"
cmd "spack env activate -d ${SPACK_MANAGER}/environments/exawind-sunspot"
cmd "spack load exawind+amr_wind_gpu~nalu_wind_gpu"
cmd "spack load trilinos"
cmd "which exawind"
cmd "rm -rf mesh"
cmd "mkdir mesh"
cmd "mpiexec -np 24 -ppn 24 stk_balance.exe -o ./mesh/ -i ./nrel5mw_nearbody.exo"
cmd "mpiexec -np 48 -ppn 6 -envall gpu_tile_compact.sh exawind --awind 24 --nwind 24 nrel5mw.yaml"
cmd "rm -r mesh"
