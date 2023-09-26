#!/bin/bash -l
{SLURM_ARGS}
#SBATCH -o {NAME}.o%j
#SBATCH -J {NAME}
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

{SRUN_COMMAND_OPENFAST}
{SRUN_COMMAND_EXAWIND}

mkdir run_$SLURM_JOBID
#
mv *.log run_$SLURM_JOBID
mv {NAME}.o$SLURM_JOBID run_$SLURM_JOBID
mv timings.dat run_$SLURM_JOBID/
mv forces*dat run_$SLURM_JOBID/

