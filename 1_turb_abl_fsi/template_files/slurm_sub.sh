#!/bin/bash -l
{SLURM_ARGS}
#SBATCH -J {NAME}
{if(EMAIL)}
#SBATCH --mail-type=ALL
#SBATCH --mail-user={EMAIL}
{endif}

source $EXAWIND_MANAGER/start.sh
spack load exawind

{if(SUBMIT_EXPORTS)}
{SUBMIT_EXPORTS}
{endif}

{SRUN_COMMAND}

mkdir run_$SLURM_JOBID
mv *.log run_$SLURM_JOBID
mv {NAME}.o$SLURM_JOBID run_$SLURM_JOBID
mv timings.dat run_$SLURM_JOBID/
mv forces*dat run_$SLURM_JOBID/
