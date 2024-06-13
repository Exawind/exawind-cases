#!/bin/bash -l

##SBATCH -J single-turbine
#SBATCH -o %x.o%j
#SBATCH -A hpcapps
#SBATCH -t 30
##SBATCH -q high
##SBATCH -N 16

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
cmd "spack load exawind~amr_wind_gpu~nalu_wind_gpu"
cmd "which exawind"

#Update mesh path
sed -i "s|CHANGE_PATH|${MESH_PATH}|g" nrel5mw_nalu.yaml || true

AWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*34))
NWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*2))
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*36))

cmd "mkdir single-turbine-${SLURM_JOB_NUM_NODES}"
cmd "cp nrel5mw_amr.inp nrel5mw_nalu.yaml nrel5mw.yaml static_box.txt single-turbine-${SLURM_JOB_NUM_NODES}/"
cmd "cd single-turbine-${SLURM_JOB_NUM_NODES}"
cmd "srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --cpu_bind=cores exawind --awind ${AWIND_RANKS} --nwind ${NWIND_RANKS} nrel5mw.yaml"
