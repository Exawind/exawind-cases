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

cp template_files/driver_static_files/* ${rundir}
cp template_files/${SPACK_MANAGER_MACHINE}_static_box.txt ${rundir}/static_box.txt

spack build-env trilinos aprepro -qW --include ${aprepro_include} TOWER=${TOWER} ${single_turb_ref}/nrel5mw_nalu.yaml ${rundir}/nrel5mw_nalu.yaml
spack build-env trilinos aprepro -qW --include ${aprepro_include} TOWER=${TOWER} ${single_turb_ref}/NRELOffshrBsline5MW_Onshore_ElastoDyn_BDoutputs.dat ${rundir}/NRELOffshrBsline5MW_Onshore_ElastoDyn_BDoutputs.dat
spack build-env trilinos aprepro -qW --include ${aprepro_include} ${single_turb_ref}/nrel5mw_amr.inp ${rundir}/nrel5mw_amr.inp
spack build-env trilinos aprepro -qW --include ${aprepro_include} EMAIL=${EMAIL} NAME="fsi-${PROBNAME}" template_files/slurm_sub.sh ${rundir}/slurm_sub.sh

echo "Compile openfast servo"
cd $(pwd)/../5MW_Baseline/ServoData/
spack build-env openfast fc -shared -fPIC -o libdiscon.so DISCON/DISCON.F90

# setup openfast run dirs
for ((i=0; i<4; i++)); do
  echo "Setup Turb $i}"
  fastdir=${rundir}/fast_turb_${i}
  # copy openfast files needed
  cp template_files/openfast_static_files/* ${fastdir}
  # aprepro
  spack build-env trilinos aprepro -qW  TURBID=${i} template_files/inp.yaml ${fastdir}/inp.yaml
  # runcase
  cd ${fastdir}
  spack build-env openfast openfastcpp inp.yaml
  # copy nc files and other required things to the 
done

cd ${rundir}

# step 6 submit job if desired
if [ -n "${SUBMIT}" ]; then
  echo "Submit job"
  sbatch slurm_sub.sh
fi
