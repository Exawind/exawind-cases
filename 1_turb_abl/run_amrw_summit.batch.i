#!/bin/bash -l

#BSUB -J amrw-abl_gpu
#BSUB -o amrw-abl_gpu_%AMRW_RANKS%.o%J
#BSUB -P CFD116
#BSUB -W 0:30
#BSUB -nnodes %NODES%

module load DefApps
module load cuda/11.4.2
module load gcc/10.2.0
module load spectrum-mpi/10.4.0.3-20210112
module load valgrind

export CUDA_LAUNCH_BLOCKING=1

amrw=/gpfs/alpine/cfd116/proj-shared/mullowne/spack-manager/spack/opt/spack/linux-rhel8-ppc64le/gcc-10.2.0/amr-wind-main-u4rkzozr5i5zk7jop2tvcll5xu7xatft/bin/amr_wind

jsrun --smpiargs="-gpu" -n %RANKS% -r %RANKS_PER_NODE% -a 1 -c 1 -g 1 $amrw nrel5mw_amr_summit.inp
