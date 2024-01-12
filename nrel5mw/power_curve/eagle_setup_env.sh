module load mpt/2.22
module load gcc/9.3.0
source /projects/hfm/kmoore/spack-manager/start.sh && spack-start
spack env activate /projects/hfm/kmoore/spack-manager/environments/exawindDev4
spack load exawind
spack load openfast

export PATH=$PATH:/lustre/eaglefs/projects/hfm/kmoore/spack-manager/spack/opt/spack/linux-rhel7-skylake_avx512/gcc-9.3.0/openfast-fsi-2hifpohrhjmw2lzhrqu6lgdadxq4eose/lib

function ranks_per_node(){
  lscpu | grep -m 1 "CPU(s):" | awk '{print $2}'
}

