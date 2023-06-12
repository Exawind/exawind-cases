#!/bin/bash -l

#SBATCH -A CFD116
#SBATCH -o 4t-unifinflow_gpu_%AMRW_RANKS%_%NALU_RANKS%.o%j
#SBATCH -J 4t-unifinflow_gpu
#SBATCH -t 02:00:00
#SBATCH -p batch
#SBATCH -N %NODES%
#SBATCH --ntasks-per-node=%RANKS_PER_NODE%
#SBATCH --exclusive

nodes=$SLURM_JOB_NUM_NODES
ranks=$SLURM_NTASKS

export rocm_version=5.4.3

module purge
module load amd/${rocm_version}
module load craype-accel-amd-gfx90a
module load PrgEnv-amd
module load cray-mpich

export LD_LIBRARY_PATH=/opt/rocm-${rocm_version}/llvm/lib/:$LD_LIBRARY_PATH
export HIP_LAUNCH_BLOCKING=1

export FI_MR_CACHE_MONITOR=memhooks
export FI_CXI_RX_MATCH_MODE=software

# release
#exawind=/ccs/home/mullowne/SM/spack-manager/spack/opt/spack/linux-sles15-zen3/clang-15.0.0/exawind-master-vqtsoq4t2jy4es4sgh5zwxpu3iwwjfzg/bin/exawind

# release + umpire
exawind=/ccs/home/mullowne/SM/spack-manager/spack/opt/spack/linux-sles15-zen3/clang-15.0.0/exawind-master-t724fodm66sjoisqcbgxjajke5bloqlp/bin/exawind

srun -N %NODES% -n %RANKS% --gpus-per-node=%RANKS_PER_NODE% --gpu-bind=closest  $exawind --awind %AMRW_RANKS% --nwind %NALU_RANKS% nrel5mw.yaml

mkdir run_${SLURM_JOBID}
#
mv nrel5mw_nalu*.log run_${SLURM_JOBID}
mv 4t-unifinflow_gpu_%AMRW_RANKS%_%NALU_RANKS%.o${SLURM_JOBID} run_${SLURM_JOBID}
mv amr-wind.log run_${SLURM_JOBID}/amr_wind_%AMRW_RANKS%.log
mv timings.dat run_${SLURM_JOBID}/
mv forces*dat run_${SLURM_JOBID}/
