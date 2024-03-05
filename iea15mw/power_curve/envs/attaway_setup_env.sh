module use /projects/wind/spack-manager/modules
module load linux-rhel7-skylake_avx512/hfm-fsi/exawind-intel-2021.3.0
umask 007
function ranks_per_node(){
  threads=$(lscpu | grep -m 1 "CPU(s):" | awk '{print $2}')
  tpcore=$(lscpu | grep -m 1 "Thread(s) per core:" | awk '{print $4}')
  echo $(($threads/$tpcore))
}
