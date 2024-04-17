#!/bin/bash -l

#SBATCH -J single-turbine
#SBATCH -o %x.o%j
#SBATCH -A CFD162
#SBATCH -t 30
#SBATCH -q debug
#SBATCH -S 0
#SBATCH -N 2

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

SPACK_ENV_NAME=exawind-frontier
MESH_PATH=${PROJWORK}/cfd162/shared

cmd "module load PrgEnv-amd/8.5.0"
cmd "module load amd/5.7.1"
cmd "module load cray-mpich/8.1.27"
cmd "module unload lfs-wrapper"
cmd "module load cray-python"
cmd "export EXAWIND_MANAGER=${PROJWORK}/cfd162/${USER}/exawind-manager"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "spack load exawind+amr_wind_gpu~nalu_wind_gpu"
cmd "which exawind"

#Current possibly necessary exports
cmd "export FI_MR_CACHE_MONITOR=memhooks"
cmd "export FI_CXI_RX_MATCH_MODE=software"
cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"

#Update mesh path
sed -i "s|CHANGE_PATH|${MESH_PATH}|g" nrel5mw_nalu.yaml || true

#+amr_wind_gpu~nalu_wind_gpu
cmd "python3 reorder_file.py ${SLURM_JOB_NUM_NODES}"
AWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*8))
NWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*56))
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*64))
cmd "export MPICH_RANK_REORDER_METHOD=3"
cmd "export MPICH_RANK_REORDER_FILE=exawind.reorder_file"

#+amr_wind_gpu+nalu_wind_gpu
#cmd "export HIP_LAUNCH_BLOCKING=1"
#AWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*4))
#NWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*4))
#TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*8))

cmd "srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --gpus-per-node=8 --gpu-bind=closest exawind --awind ${AWIND_RANKS} --nwind ${NWIND_RANKS} nrel5mw.yaml"
