#!/bin/bash

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

cmd "export SPACK_MANAGER=${HOME}/exawind/spack-manager"
cmd "source ${SPACK_MANAGER}/start.sh && spack-start"
cmd "spack env activate -d ${SPACK_MANAGER}/environments/exawind-${SPACK_MANAGER_MACHINE}"
cmd "spack load exawind"
cmd "spack load trilinos"
cmd "spack load mpich"
cmd "which exawind"
cmd "rm -rf mesh"
cmd "mkdir mesh"
cmd "mpiexec -np 8 stk_balance.exe -o ./mesh/ -i ./nrel5mw_nearbody.exo"
cmd "mpiexec -np 8 exawind --awind 8 --nwind 8 nrel5mw.yaml"
cmd "rm -r mesh"
