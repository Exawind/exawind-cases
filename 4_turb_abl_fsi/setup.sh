# step 1 checks
source ${SPACK_MANAGER}/start.sh
spack-start # ensure spack-manager is going
spack load exawind

# machine specific params i.e. mesh/restart/etc
aprepro_include=template_files/${SPACK_MANAGER_MACHINE}_aprepro.txt

# step 2 parse
for i in "$@"; do
    case "$1" in
        -n=*|--name=*)
            PROBNAME="${i#*=}"
            shift # past argument=value
            ;;
        -e=*|--email=*)
            EMAIL="${i#*=}"
            shift # past argument=value
            ;;
        -s=*|--submit=*)
            SUBMIT="${i#*=}"
            shift # past argument=value
            ;;
        --)
            shift
            break
            ;;
    esac
done

# hard code tower on
TOWER=True

# step 3 create dirs
if [[ -z ${PROBNAME} ]]; then
  PROBNAME=$(date "+%Y%m%d")
fi
rundir="$(pwd)/run_${PROBNAME}"
mkdir -p ${rundir}

# step 4 setup run dir
echo "Setting up run dir"
single_turb_ref=$(pwd)/../1_turb_abl_fsi/template_files

# files that do not change
cp ${single_turb_ref}/static_files/* ${rundir}
cp template_files/static_files/* ${rundir}
cp template_files/${SPACK_MANAGER_MACHINE}_static_box.txt ${rundir}/static_box.txt

# files that need to be edited with the preprocessor, mainly for reuse from the single turbine case
aprepro -qW --include ${aprepro_include} template_files/nrel5mw_nalu.yaml ${rundir}/nrel5mw_nalu.yaml
aprepro -qW --include ${aprepro_include} ${single_turb_ref}/nrel5mw_amr.inp ${rundir}/nrel5mw_amr.inp
aprepro -qW --include ${aprepro_include} EMAIL=${EMAIL} NAME="fsi-${PROBNAME}" template_files/slurm_sub.sh ${rundir}/slurm_sub.sh

cd ${rundir}

# step 6 submit job if desired
# openfast will be run in parallel to start this job
#
if [ -n "${SUBMIT}" ]; then
  echo "Submit job"
if [ "darwin" = "${SPACK_MANAGER_MACHINE}" ]; then
  # TEST INFRASTUCTURE as a bash script
  bash slurm_sub.sh
else
  sbatch slurm_sub.sh
fi
fi
