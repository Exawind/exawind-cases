#!/bin/bash -l

#SBATCH -o %x.o%j
#SBATCH -A CFD162
#SBATCH -t 00:30:00
#SBATCH -q debug
#SBATCH -S 0
#SBATCH -J sphere
#SBATCH -N 4

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

SPACK_ENV_NAME=exawind_frontier_gpu_02_05_2025
export EXAWIND_MANAGER=${MEMBERWORK}/cfd162/exawind-manager
MESH_PATH=${PROJWORK}/cfd162/shared
spec="exawind"

cmd "module load cray-python"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "spack load ${spec}"
cmd "which exawind"

#Current possibly necessary exports
cmd "export FI_MR_CACHE_MONITOR=memhooks"
cmd "export FI_CXI_RX_MATCH_MODE=software"
cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"

#Update mesh path
sed -i "s|CHANGE_PATH|${MESH_PATH}|g" sphere-nalu.yaml || true

#+amr_wind_gpu~nalu_wind_gpu
#cmd "python3 ../tools/reorder_file.py ${SLURM_JOB_NUM_NODES}"
#AWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*8))
#NWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*56))
#TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*64))
#cmd "export MPICH_RANK_REORDER_METHOD=3"
#cmd "export MPICH_RANK_REORDER_FILE=exawind.reorder_file"

#+amr_wind_gpu+nalu_wind_gpu
cmd "export HIP_LAUNCH_BLOCKING=1"
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*8))
NWIND_RANKS=$((TOTAL_RANKS - 1))
AWIND_RANKS=$((TOTAL_RANKS - NWIND_RANKS))

cmd "srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --gpus-per-node=8 --gpu-bind=closest spack build-env exawind exawind --awind ${AWIND_RANKS} --nwind ${NWIND_RANKS} sphere.yaml"

