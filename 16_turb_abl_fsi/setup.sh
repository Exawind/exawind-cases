#/bin/bash -l

#For Sunspot run something like this command
#export SPACK_PYTHON=python3.10 && export EXAWIND_MANAGER=/lus/gila/projects/CSC249ADSE13_CNDA/jrood/exawind/exawind-manager && export EXAWIND_EXE=exawind+amr_wind_gpu~nalu_wind_gpu && export MY_SPACK_ENV=exawind-sunspot && cd ${EXAWIND_MANAGER} && source shortcut.sh && cd - && spack env activate ${MY_SPACK_ENV} && spack load ${EXAWIND_EXE} && ./setup.sh

#For Frontier run something like this command
#export EXAWIND_MANAGER=${PROJWORK}/cfd162/${USER}/exawind-manager && export EXAWIND_EXE=exawind+amr_wind_gpu~nalu_wind_gpu && export MY_SPACK_ENV=exawind-frontier && cd ${EXAWIND_MANAGER} && source shortcut.sh && cd - && spack env activate ${MY_SPACK_ENV} && spack load ${EXAWIND_EXE} && ./setup.sh

#For Kestrel run something like this command
#module load cray-python && export EXAWIND_MANAGER=/scratch/${USER}/exawind-manager && export EXAWIND_EXE=exawind~amr_wind_gpu~nalu_wind_gpu && export MY_SPACK_ENV=exawind-kestrel && cd ${EXAWIND_MANAGER} && source shortcut.sh && cd - && spack env activate ${MY_SPACK_ENV} && spack load ${EXAWIND_EXE} && ./setup.sh

SPACK_MANAGER_MACHINE=$(spack manager find-machine | awk '{print $2}')
aprepro_include=template_files/${SPACK_MANAGER_MACHINE}_aprepro.txt

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
        -d=*|--delta_cut_in_rev=*)
            DELTA_CUT_IN="${i#*=}"
            shift # past argument=value
            ;;
        -m=*|--mean_cut_in_rev=*)
            MEAN_CUT_IN="${i#*=}"
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
aprepro -q -W --include ${aprepro_include} CUT_IN_MEAN=${MEAN_CUT_IN} CUT_IN_WIDTH=${DELTA_CUT_IN} template_files/nrel5mw_nalu.yaml ${rundir}/nrel5mw_nalu.yaml
aprepro -q -W  CUT_IN_MEAN=${MEAN_CUT_IN} CUT_IN_WIDTH=${DELTA_CUT_IN} template_files/inp.yaml ${rundir}/inp.yaml
aprepro -q -W --include ${aprepro_include} ${single_turb_ref}/nrel5mw_amr.inp ${rundir}/nrel5mw_amr.inp
aprepro -q -W --include ${aprepro_include} NAME="${PROBNAME}" template_files/run.sh ${rundir}/run.sh
