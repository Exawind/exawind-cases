#!/bin/bash -l
{SLURM_ARGS}
{if(EMAIL)}
#SBATCH --mail-type=ALL
#SBATCH --mail-user={EMAIL}
{endif}

nodes=$SLURM_JOB_NUM_NODES
ranks=$SLURM_NTASKS

# env variables for the spack environment will propogate to a new shell
# commands (i.e. spack) most likely do not
source $SPACK_MANAGER/start.sh
spack load exawind

{if(SUBMIT_EXPORTS)}
{SUBMIT_EXPORTS}
{endif}

{SRUN_COMMAND}

mkdir run_$SLURM_JOBID
#
mv nrel5mw_nalu*.log run_$SLURM_JOBID
mv 1t-abl_gpu_2048_128.o$SLURM_JOBID run_$SLURM_JOBID
mv amr-wind.log run_$SLURM_JOBID/amr_wind_2048.log
mv timings.dat run_$SLURM_JOBID/
mv forces*dat run_$SLURM_JOBID/

