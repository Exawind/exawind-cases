#!/bin/bash -l

# Notes: AMR-Wind Frontier weak scaling study for ABL case

#SBATCH -J amrwind-frontier-weak-scaling-3
#SBATCH -o %x.o%j
#SBATCH -A CFD116
#SBATCH -t 30
#SBATCH -p batch
#SBATCH -N 4
#SBATCH -S 0

set -e
cmd() {
  echo "+ $@"
  eval "$@"
}
echo "Running with 8 ranks per node and 1 ranks per GPU on 4 nodes for a total of 32 ranks and 32 total GPUs with 32 AMR-Wind ranks..."

cmd "module unload PrgEnv-cray"
cmd "module load PrgEnv-amd"
cmd "module load amd/5.4.3"
cmd "export FI_MR_CACHE_MONITOR=memhooks"
cmd "export FI_CXI_RX_MATCH_MODE=software"
cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"
cmd "export SPACK_MANAGER=${HOME}/exawind/spack-manager"
cmd "source ${SPACK_MANAGER}/start.sh && spack-start"
cmd "spack env activate -d ${SPACK_MANAGER}/environments/amr-wind-mpi"
cmd "spack load amr-wind+rocm+tiny_profile+gpu-aware-mpi"
cmd "which amr_wind"
cmd "srun -N4 -n32 -c1 --gpus-per-node=8 --gpu-bind=closest amr_wind abl_godunov_wenoz.inp amr.n_cell=2048 2048 256 geometry.prob_hi=8000. 8000. 1000. time.fixed_dt=0.02 time.max_step=5 time.plot_interval=-1 time.checkpoint_interval=-1 amrex.abort_on_out_of_gpu_memory=1 amrex.the_arena_is_managed=0 amr.blocking_factor=16 amr.max_grid_size=128 amrex.use_profiler_syncs=0 amrex.async_out=0"
