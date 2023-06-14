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
cmd "export ASAN_OPTIONS=detect_container_overflow=0"
cmd "mpiexec -np 1 exawind --awind 1 --nwind 1 sphere.yaml"
