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
        -s=*|--yaw=*)
            YAW="${i#*=}"
            shift # past argument=value
            ;;
        -d=*|--wind_dir=*)
            DIR="${i#*=}"
            shift # past argument=value
            ;;
        -s=*|--wind_speed=*)
            SPEED="${i#*=}"
            shift # past argument=value
            ;;
        --)
            shift
            break
            ;;
    esac
done

# defaults
if [[ -z ${YAW} ]]; then
  YAW=0.0
fi
if [[ -z ${DIR} ]]; then
  DIR=270.0
fi
if [[ -z ${SPEED} ]]; then
  SPEED=8.0
fi

# step 3 create dirs
if [[ -z ${PROBNAME} ]]; then
  PROBNAME=$(date "+%Y%m%d")
fi
rundir="$(pwd)/run_${PROBNAME}"
mkdir -p ${rundir}

# step 4 setup run dir
echo "Setting up run dir"
single_turb_ref=$(pwd)/../1_turb_abl_fsi/template_files
cp $(spack location -s nalu-wind)/reg_tests/mesh/cylinder_turbine.g ${rundir}

# files that do not change
cp ${single_turb_ref}/static_files/* ${rundir}
cp template_files/static_files/* ${rundir}

# files that need to be edited with the preprocessor, mainly for reuse from the single turbine case
spack build-env trilinos aprepro -qW --include ${aprepro_include} \
  WIND_SPEED=${SPEED} WIND_DIR=${DIR} YAW=${YAW} \
  template_files/fsiTurbineSurrogate.yaml ${rundir}/fsiTurbineSurrogate.yaml

spack build-env trilinos aprepro -qW --include ${aprepro_include} \
  WIND_SPEED=${SPEED} WIND_DIR=${DIR} YAW=${YAW} \
  template_files/inp.yaml ${rundir}/inp.yaml

spack build-env trilinos aprepro -qW --include ${aprepro_include} \
  WIND_SPEED=${SPEED} WIND_DIR=${DIR} YAW=${YAW} \
  template_files/NRELOffshrBsline5MW_Onshore_ElastoDyn_BDoutputs.dat \
  ${rundir}/NRELOffshrBsline5MW_Onshore_ElastoDyn_BDoutputs.dat

spack build-env trilinos aprepro -qW --include ${aprepro_include} EMAIL=${EMAIL} \
  NAME="fsi-${PROBNAME}" template_files/slurm_sub.sh ${rundir}/slurm_sub.sh

cd ${rundir}

# run openfast to create the restart files
spack build-env openfast openfastcpp inp.yaml

# step 6 submit job if desired
if [ -n "${SUBMIT}" ]; then
  echo "Submit job"
if [ "darwin" = "${SPACK_MANAGER_MACHINE}" ] || [ "cee" = "${SPACK_MANAGER_MACHINE}" ]; then
  # TEST INFRASTUCTURE as a bash script
  bash slurm_sub.sh
else
  sbatch slurm_sub.sh
fi
fi
