#module load mpt/2.22
#module load gcc/9.3.0
#source /projects/hfm/kmoore/spack-manager/start.sh && spack-start
#spack env activate /projects/hfm/kmoore/spack-manager/environments/exawindDev4
#spack load exawind
#spack load openfast

source /nopt/nrel/ecom/hpacf/env.sh
module load gcc/9.3.0
module load binutils
module load git
module load python
export SPACK_MANAGER=/lustre/eaglefs/scratch/psakiev/spack-manager
source /lustre/eaglefs/scratch/psakiev/spack-manager/start.sh && spack-start
spack load exawind
spack load openfast
export PATH=$PATH:$(spack location -i openfast)/lib/openfastcpp


function ranks_per_node(){
  lscpu | grep -m 1 "CPU(s):" | awk '{print $2}'
}

