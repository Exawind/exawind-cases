module use /projects/wind/spack-manager/modules
module load linux-rhel7-x86_64/hfm-fsi/exawind-intel-2021.3.0
umask 0007
function ranks_per_node(){
  lscpu | grep -m 1 "CPU(s):" | awk '{print $2}'
}
