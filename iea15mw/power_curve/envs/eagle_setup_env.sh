source /nopt/nrel/ecom/hpacf/env.sh # if you aren't already doing this
module use /projects/hfm/psakiev/spack-manager/modules
module load exawind-master/2024-02-20

function ranks_per_node(){
  lscpu | grep -m 1 "CPU(s):" | awk '{print $2}'
}
