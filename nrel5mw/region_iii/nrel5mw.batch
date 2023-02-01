#!/bin/bash

#SBATCH --nodes=32
#SBATCH --time=240:00:00
#SBATCH --account=hfm
#SBATCH --job-name=nrel5mw_riii
#SBATCH --output=out.%x_%j

module purge
export SPACK_MANAGER=${HOME}/exawind/spack-manager
source ${SPACK_MANAGER}/start.sh && quick-activate ${SPACK_MANAGER}/environments/exawind
spack load exawind

ranks_per_node=36
mpi_ranks=$(expr $SLURM_JOB_NUM_NODES \* $ranks_per_node)
export OMP_NUM_THREADS=1  # Max hardware threads = 4
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

echo "Job name       = $SLURM_JOB_NAME"
echo "Num. nodes     = $SLURM_JOB_NUM_NODES"
echo "Num. MPI Ranks = $mpi_ranks"
echo "Num. threads   = $OMP_NUM_THREADS"
echo "Working dir    = $PWD"

cd mesh
srun -n 360 stk_balance.exe nrel5mw_volume.exo &> log.decompose
cd ../
srun -n ${mpi_ranks} exawind --awind 792 --nwind 360 nrel5mw-01.yaml
