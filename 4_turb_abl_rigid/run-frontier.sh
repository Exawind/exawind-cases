#!/bin/bash -l

#SBATCH -J 4_turb_abl_rigid
#SBATCH -o %x.o%j
#SBATCH -A CFD162
#SBATCH -t 30
#SBATCH -S 0
#SBATCH -N 64

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

SPACK_ENV_NAME=exawind_frontier_01_30_2025
EXAWIND_MANAGER=${MEMBERWORK}/cfd162/exawind-manager
MESH_PATH=${PROJWORK}/cfd162/shared

#spec="exawind+amr_wind_gpu~nalu_wind_gpu"
spec="exawind"

cmd "module load cray-python"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
mods=$(spack build-env "$spec" | grep 'LOADEDMODULES' | cut -d'=' -f2)
IFS=':' read -r -a modules <<< "$mods"
for module in "${modules[@]}"; do
    # Check if the module is already loaded
    if ! module list 2>&1 | grep -q "$module"; then
        cmd "module load "$module""
    fi
done
cmd "spack load ${spec}"
cmd "which exawind"

#Current possibly necessary exports
cmd "export FI_MR_CACHE_MONITOR=memhooks"
cmd "export FI_CXI_RX_MATCH_MODE=software"
cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"

#Update mesh path
set +e
find . -name 'nrel5mw_nalu_w_tower*.yaml' -type f -exec sed -i "s|CHANGE_PATH|${MESH_PATH}|g" {} \;
find . -name 'nrel5mw_amr.inp' -type f -exec sed -i "s|CHANGE_PATH|${MESH_PATH}|g" {} \;
set -e

#+amr_wind_gpu~nalu_wind_gpu
cmd "python3 ../tools/reorder_file.py ${SLURM_JOB_NUM_NODES}"
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
