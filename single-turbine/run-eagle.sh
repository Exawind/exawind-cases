#!/bin/bash -l

#SBATCH -J single-turbine
#SBATCH -o %x.o%j
#SBATCH -A hpcapps
#SBATCH -t 30
#SBATCH -N 16

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

SPACK_ENV_NAME=exawind-eagle
MESH_PATH=/scratch/${USER}/shared

cmd "export EXAWIND_MANAGER=/scratch/${USER}/exawind-manager"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "spack load exawind+amr_wind_gpu~nalu_wind_gpu"
cmd "which exawind"

#Update mesh path
sed -i "s|CHANGE_PATH|${MESH_PATH}|g" nrel5mw_nalu.yaml || true

AWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*18))
NWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*18))
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*36))

cmd "srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --gpus-per-node=8 --gpu-bind=closest exawind --awind ${AWIND_RANKS} --nwind ${NWIND_RANKS} nrel5mw.yaml"
