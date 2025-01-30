#!/bin/bash -l

#SBATCH -J single-turbine
#SBATCH -o %x.o%j
#SBATCH -A CFD162
#SBATCH -t 30
#SBATCH -q debug
#SBATCH -S 0
#SBATCH -N 4

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

SPACK_ENV_NAME=exawind_01_29_2025
EXAWIND_MANAGER=${MEMBERWORK}/cfd162/exawind-manager-builds/exawind-manager/
MESH_PATH=${PROJWORK}/cfd162/shared

cmd "module load cray-python"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "module purge"

#load_packages=("exawind", "amr-wind", "nalu-wind") #uncomment to only load specific root packages 
root_specs=$(spack find | grep '[+]' | cut -d' ' -f2) #get root spec names from spack find
# Loop through all packages
for package in $root_specs; do
    loaded=false
    # If load_packages is undefined, load all root specs
    if [ ${#load_packages[@]} -eq 0 ]; then
        cmd "spack load "$package""
        loaded=true

    # Else, only load packages in load_packages variable 
    else
        for load_package in "${load_packages[@]}"; do
            if [[ "$package" == *"$load_package"* ]]; then
                cmd "spack load "$package""
                loaded=true
                break
            fi
        done
    fi

    # Load all modules for each package from the build environment
    if [ "$loaded" = true ]; then
        mods=$(spack build-env "$package" | grep 'LOADEDMODULES' | cut -d'=' -f2)
        IFS=':' read -r -a modules <<< "$mods"
        for module in "${modules[@]}"; do
            # Check if the module is already loaded
            if ! module list 2>&1 | grep -q "$module"; then
                cmd "module load "$module""
            fi
        done
    fi
done

#Current possibly necessary exports
cmd "export FI_MR_CACHE_MONITOR=memhooks"
cmd "export FI_CXI_RX_MATCH_MODE=software"
cmd "export MPICH_SMP_SINGLE_COPY_MODE=NONE"

#Update mesh path
sed -i "s|CHANGE_PATH|${MESH_PATH}|g" nrel5mw_nalu.yaml || true

#+amr_wind_gpu~nalu_wind_gpu
#cmd "python3 ../tools/reorder_file.py ${SLURM_JOB_NUM_NODES}"
#AWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*8))
#NWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*56))
#TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*64))
#cmd "export MPICH_RANK_REORDER_METHOD=3"
#cmd "export MPICH_RANK_REORDER_FILE=exawind.reorder_file"

#+amr_wind_gpu+nalu_wind_gpu
cmd "export HIP_LAUNCH_BLOCKING=1"
AWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*4))
NWIND_RANKS=$((${SLURM_JOB_NUM_NODES}*4))
TOTAL_RANKS=$((${SLURM_JOB_NUM_NODES}*8))

cmd "srun -N${SLURM_JOB_NUM_NODES} -n${TOTAL_RANKS} --gpus-per-node=8 --gpu-bind=closest exawind --awind ${AWIND_RANKS} --nwind ${NWIND_RANKS} nrel5mw.yaml"
