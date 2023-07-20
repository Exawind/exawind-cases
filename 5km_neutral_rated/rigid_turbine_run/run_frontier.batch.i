#!/bin/bash -l

#SBATCH -A CFD116
#SBATCH -o 1t-tower_blades-abl_gpu_%AMRW_RANKS%_%NALU_RANKS%.o%j
#SBATCH -J 1t-tower_blades-abl_gpu
#SBATCH -t 02:00:00
#SBATCH -p batch
#SBATCH -N %NODES%
#SBATCH --ntasks-per-node=%RANKS_PER_NODE%
#SBATCH --exclusive
#SBATCH --mail-user=Paul.Mullowney@amd.com
#SBATCH --mail-type=BEGIN

nodes=$SLURM_JOB_NUM_NODES
ranks=$SLURM_NTASKS

export rocm_version=5.4.3

#export SPACK_MANAGER=/lustre/orion/proj-shared/cfd116/mullowne/spack-manager
#source ${SPACK_MANAGER}/start.sh && spack-start
#module list
#spack env activate -d ${SPACK_MANAGER}/environments/exawind_umpire_rocm-${rocm_version}
#spack load exawind
#exawind=$(which exawind)

module purge
module load amd/${rocm_version}
module load craype-accel-amd-gfx90a
module load PrgEnv-amd
module load cray-mpich

export LD_LIBRARY_PATH=/opt/rocm-${rocm_version}/llvm/lib/:$LD_LIBRARY_PATH
#export MPICH_SMP_SINGLE_COPY_MODE=NONE
#export HIP_LAUNCH_BLOCKING=1

#export FI_MR_CACHE_MONITOR=memhooks
#export FI_CXI_RX_MATCH_MODE=software

# release
#exawind=/lustre/orion/cfd116/proj-shared/mullowne/spack-manager/spack/opt/spack/linux-sles15-zen3/clang-15.0.0/exawind-master-ndi3c36sv4e6dpvcwggd7g46ozuicnxb/bin/exawind
# release + umpire
exawind=/lustre/orion/cfd116/proj-shared/mullowne/spack-manager/spack/opt/spack/linux-sles15-zen3/clang-15.0.0/exawind-master-mxxau6pf4aanv5o5gwp6km6f7vklbe6c/bin/exawind

srun -N %NODES% -n %RANKS% --gpus-per-node=%RANKS_PER_NODE% --gpu-bind=closest  $exawind --awind %AMRW_RANKS% --nwind %NALU_RANKS% nrel5mw.yaml

mkdir run_${SLURM_JOBID}
cp nrel5mw_amr.inp run_${SLURM_JOBID}
cp nrel5mw_nalu_w_tower.yaml run_${SLURM_JOBID}
#
mv nrel5mw_nalu*.log run_${SLURM_JOBID}
mv 1t-tower_blades-abl_gpu_%AMRW_RANKS%_%NALU_RANKS%.o${SLURM_JOBID} run_${SLURM_JOBID}
mv amr-wind.log run_${SLURM_JOBID}/amr_wind_%AMRW_RANKS%.log
mv timings.dat run_${SLURM_JOBID}/
mv forces*dat run_${SLURM_JOBID}/
