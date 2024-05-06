#!/bin/bash
source /etc/profile.d/modules.sh
source /home/ndeveld/python-env/load-flightpython.sh

module purge
module load aue/zlib/1.3
module load aue/binutils/2.41
module load aue/intel-oneapi-compilers/2023.2.0
module load aue/openmpi/4.1.6-intel-2023.2.0
module load aue/cmake/3.27.7

module use /projects/wind/hpc/wind/ndeveld/em-exawind-flight/environments/exawind-04182024/modules
module load openfast-develop/exawind-master/intel-2023.2.0

umask 007

threads=$(lscpu | grep -m 1 "CPU(s):" | awk '{print $2}')
tpcore=$(lscpu | grep -m 1 "Thread(s) per core:" | awk '{print $4}')
export RANKS_PER_NODE=$(($threads/$tpcore))

