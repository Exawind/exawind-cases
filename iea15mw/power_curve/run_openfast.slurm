#!/bin/bash

#SBATCH --nodes=1
#SBATCH --time=4:00:00
#SBATCH --account=hfm
#SBATCH --job-name=iea15mw_powercurve
#SBATCH --output=out.%x_%j

export SPACK_MANAGER=/home/gvijayak/exawind/source/spack-manager
source /home/gvijayak/exawind/source/spack-manager/start.sh
spack-start
quick-activate /home/gvijayak/exawind/source/spack-manager/environments/fsi-merge-release
spack load openfast

ls -d wind_speed* | xargs -n 1 -P 13 bash run_openfast.sh
