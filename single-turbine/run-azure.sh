#!/bin/bash -l

#SBATCH -J single-turbine
#SBATCH -o %x.o%j
#SBATCH -t 12:00:00
#SBATCH -N 32
#SBATCH --ntasks-per-node=120

set -e
cmd() {
  echo "+ $@"
  eval "$@"
}

cmd "module load mpi/hpcx-v2.8.3"
cmd "module use /lustre/jrood/exawind/software/modules/linux-centos7-zen2"
cmd "module load trilinos-13.4.0.2023.02.28-gcc-9.2.0-c53hhhp"
cmd "module load exawind-master-gcc-9.2.0-iqx3u53"
cmd "which stk_balance.exe"
cmd "which exawind"
cmd "which mpirun"
cmd "rm -rf mesh"
cmd "mkdir mesh"
cmd "mpirun -np 960 -bind-to core stk_balance.exe -o ./mesh/ -i ./nrel5mw_nearbody.exo"
cmd "mpirun -np 3840 -bind-to core exawind --awind 2880 --nwind 960 nrel5mw.yaml"
cmd "rm -r mesh"
