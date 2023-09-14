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
SPACK_MANAGER=/lustre/orion/proj-shared/cfd116/mullowne/spack-manager/
source ${SPACK_MANAGER}/start.sh
spack-start # ensure spack-manager is going
spack env activate -d $SPACK_MANAGER/environments/exawind_rocm-5.4.3
spack load exawind

{if(SUBMIT_EXPORTS)}
{SUBMIT_EXPORTS}
{endif}

{SRUN_COMMAND}

mkdir run_$SLURM_JOBID
#
mv *.log run_$SLURM_JOBID
mv {NAME}.o$SLURM_JOBID run_$SLURM_JOBID
mv timings.dat run_$SLURM_JOBID/
mv forces*dat run_$SLURM_JOBID/

