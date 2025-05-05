#!/bin/bash -l

#SBATCH --job-name=single-turbine
#SBATCH --output %x.o%j
#SBATCH --account=hpcapps
#SBATCH --time=0:30:00
#SBATCH --reservation=exawind-movie
#SBATCH --ntasks-per-node=128
#SBATCH --gres=gpu:h100:4
#SBATCH --nodes=2
#SBATCH --mem=0
#SBATCH --exclusive
#SBATCH -S 0

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

SPACK_ENV_NAME=exawind-env
MESH_PATH=/scratch/jrood/mpich/exawind-cases/single-turbine

cmd "module load cray-pals"
cmd "module load cray-libpals"
cmd "module load cray-pmi"
cmd "export EXAWIND_MANAGER=/scratch/jrood/mpich/exawind-manager"
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

cmd "export LD_LIBRARY_PATH=/opt/cray/pe/lib64:${LD_LIBRARY_PATH}"
cmd "python3 ../tools/reorder_file_kestrel.py ${SLURM_JOB_NUM_NODES}"
AWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*4))
NWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*124))
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*128))
cmd "export MPICH_RANK_REORDER_METHOD=3"
cmd "export MPICH_RANK_REORDER_FILE=exawind.reorder_file"
#cmd "export MPICH_RANK_REORDER_DISPLAY=1"
cmd "srun --mpi=cray_shasta -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} exawind --awind ${AWIND_RANKS} --nwind ${NWIND_RANKS} nrel5mw.yaml"
