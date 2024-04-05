export EXAWIND_MANAGER=/lustre/orion/proj-shared/cfd162/jrood/exawind-manager
source ${EXAWIND_MANAGER}/start.sh
spack-start
spack load exawind

# machine specific params i.e. mesh/restart/etc
aprepro_include=template_files/${EXAWIND_MANAGER_MACHINE}_aprepro.txt

# Defaults for load blending (units are revolutions)
MEAN_CUT_IN=3.0 # middle of hyperbolic tangent
DELTA_CUT_IN=0.25 # width of hyperbolid tangent

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
        -t=*|--tower=*)
            TOWER="${i#*=}"
            shift # past argument=value
            ;;
        -d=*|--delta_cut_in_rev=*)
            DELTA_CUT_IN="${i#*=}"
            shift # past argument=value
            ;;
        -m=*|--mean_cut_in_rev=*)
            MEAN_CUT_IN="${i#*=}"
            shift # past argument=value
            ;;
        -c=*|--controller=*)
            USE_CONTROLLER="${i#*=}"
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

# step 3 create dirs
if [[ -z ${PROBNAME} ]]; then
  PROBNAME=$(date "+%Y%m%d")
fi
rundir="$(pwd)/run_${PROBNAME}"
mkdir -p ${rundir}

# step 4 setup run dir
echo "Setting up run dir"
cp template_files/static_files/* ${rundir}
cp template_files/${EXAWIND_MANAGER_MACHINE}_static_box.txt ${rundir}/static_box.txt
spack build-env trilinos aprepro -qW --include ${aprepro_include} CUT_IN_MEAN=${MEAN_CUT_IN} CUT_IN_WIDTH=${DELTA_CUT_IN} TOWER=${TOWER} template_files/nrel5mw_nalu.yaml ${rundir}/nrel5mw_nalu.yaml
spack build-env trilinos aprepro -qW --include ${aprepro_include} USE_CONTROLLER=${USE_CONTROLLER} TOWER=${TOWER} template_files/NRELOffshrBsline5MW_Onshore_ElastoDyn_BDoutputs.dat ${rundir}/NRELOffshrBsline5MW_Onshore_ElastoDyn_BDoutputs.dat
spack build-env trilinos aprepro -qW  CUT_IN_MEAN=${MEAN_CUT_IN} CUT_IN_WIDTH=${DELTA_CUT_IN} template_files/inp.yaml ${rundir}/inp.yaml
spack build-env trilinos aprepro -qW  USE_CONTROLLER=${USE_CONTROLLER} template_files/nrel5mw.fst ${rundir}/nrel5mw.fst

# getting a weird carriage on frontier in this file for some reason
sed -i 's/\r//g' ${rundir}/NRELOffshrBsline5MW_Onshore_ElastoDyn_BDoutputs.dat
sed -i 's/\r//g' ${rundir}/nrel5mw.fst

spack build-env trilinos aprepro -qW --include ${aprepro_include} template_files/nrel5mw_amr.inp ${rundir}/nrel5mw_amr.inp
spack build-env trilinos aprepro -qW --include ${aprepro_include} EMAIL=${EMAIL} NAME="fsi-${PROBNAME}" template_files/slurm_sub.sh ${rundir}/slurm_sub.sh

# step 5 run openfast
if [ -n "${USE_CONTROLLER}" ]; then
echo "Compile openfast servo"
cd $(pwd)/../5MW_Baseline/ServoData/
spack build-env openfast fc -shared -fPIC -o libdiscon.so DISCON/DISCON.F90
fi

# run standalone openfast and copy files to run directory
echo "Run openfast to start"
set -x
cd ${rundir}
spack build-env openfast openfastcpp inp.yaml

# step 6 submit job if desired
if [ -n "${SUBMIT}" ]; then
  echo "Submit job"
  sbatch slurm_sub.sh
fi
