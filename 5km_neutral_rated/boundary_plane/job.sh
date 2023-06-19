#!/bin/bash
#SBATCH --job-name=5km_abl
#SBATCH --account=hfm
#SBATCH --time=48:00:00 
#SBATCH --nodes=70
#SBATCH --qos=high
#SBATCH --output=abl.out
#SBATCH --mail-user=ashesh.sharma@nrel.gov
#SBATCH --mail-type=BEGIN,END,FAIL

export SPACK_MANAGER=/home/asharma/exawind_spack_latest/spack-manager
source ${SPACK_MANAGER}/configs/eagle/env.sh
module load mpt
source ${SPACK_MANAGER}/start.sh && quick-activate ${SPACK_MANAGER}/environments/latest
spack load exawind
amr_exec="$(spack location -i amr-wind)/bin/amr_wind"

mpirun -np 2520 ${amr_exec} abl.inp
