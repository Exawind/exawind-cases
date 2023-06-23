#!/bin/bash -l

#SBATCH -A CFD116
#SBATCH -o amrw-abl_gpu_%AMRW_RANKS%.o%j
#SBATCH -J amrw-abl_gpu
#SBATCH -t 00:20:00
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

amrw=/autofs/nccs-svm1_home1/mullowne/SM/spack-manager/spack/opt/spack/linux-sles15-zen3/clang-15.0.0/amr-wind-main-u3riz6tomvv2umbvc5zjrqzo6qmy7zpw/bin/amr_wind

srun -N %NODES% -n %RANKS% --gpus-per-node=%RANKS_PER_NODE% --gpu-bind=closest  $amrw nrel5mw_amr.inp

mkdir run_${SLURM_JOBID}
#
mv amrw-abl_gpu_%AMRW_RANKS%.o${SLURM_JOBID} run_${SLURM_JOBID}
