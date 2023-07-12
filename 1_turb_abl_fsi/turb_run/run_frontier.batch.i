#!/bin/bash -l

#SBATCH -A CFD116
#SBATCH -o 1t-abl_gpu_%AMRW_RANKS%_%NALU_RANKS%.o%j
#SBATCH -J 1t-abl_gpu
#SBATCH -t 02:00:00
#SBATCH -p batch
#SBATCH -N %NODES%
#SBATCH --ntasks-per-node=%RANKS_PER_NODE%
#SBATCH --exclusive

nodes=$SLURM_JOB_NUM_NODES
ranks=$SLURM_NTASKS

export rocm_version=5.4.3

# env variables for the spack environment will propogate to a new shell
# commands (i.e. spack) most likely do not
source ${SPACK_MANAGER}/start.sh
spack load exawind
export HIP_LAUNCH_BLOCKING=1

export FI_MR_CACHE_MONITOR=memhooks
export FI_CXI_RX_MATCH_MODE=software

srun -N %NODES% -n %RANKS% --gpus-per-node=%RANKS_PER_NODE% --gpu-bind=closest  exawind --awind %AMRW_RANKS% --nwind %NALU_RANKS% nrel5mw.yaml

mkdir run_${SLURM_JOBID}
#
mv nrel5mw_nalu*.log run_${SLURM_JOBID}
mv 1t-abl_gpu_%AMRW_RANKS%_%NALU_RANKS%.o${SLURM_JOBID} run_${SLURM_JOBID}
mv amr-wind.log run_${SLURM_JOBID}/amr_wind_%AMRW_RANKS%.log
mv timings.dat run_${SLURM_JOBID}/
mv forces*dat run_${SLURM_JOBID}/
