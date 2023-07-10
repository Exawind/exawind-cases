#!/bin/bash

#PBS -A CSC249ADSE13_CNDA
#PBS -q workq
#PBS -l select=4
#PBS -l walltime=30:00
#PBS -j oe

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

cmd "cd $PBS_O_WORKDIR"
cmd "export SPACK_MANAGER=/lus/gila/projects/CSC249ADSE13_CNDA/${USER}/exawind/spack-manager"
cmd "source ${SPACK_MANAGER}/start.sh && spack-start"
cmd "spack env activate -d ${SPACK_MANAGER}/environments/exawind-sunspot"
cmd "spack load exawind+amr_wind_gpu~nalu_wind_gpu"
cmd "spack load trilinos"
cmd "which exawind"
cmd "rm -rf mesh"
cmd "mkdir mesh"
cmd "mpiexec -np 12 -ppn 12 stk_balance.exe -o ./mesh/ -i ./nrel5mw_nearbody.exo"
cmd "mpiexec -np 48 -ppn 12 -envall gpu_tile_compact.sh exawind --awind 36 --nwind 12 nrel5mw.yaml"
cmd "rm -r mesh"
