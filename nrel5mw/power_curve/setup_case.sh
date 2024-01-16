#----------------------------------
# OPENFAST FILES
#----------------------------------
TURBINE_BASE_DIR="/projects/hfm/ndevelder/hfm-nrel5mw-push1/nrel5mw/5MW_Baseline"
SERVO_FILE="NRELOffshrBsline5MW_Onshore_ServoDyn.dat"
AERODYN_FILE="NRELOffshrBsline5MW_Onshore_AeroDyn15.dat"
ELASTO_FILE="NRELOffshrBsline5MW_Onshore_ElastoDyn.dat"
FAST_FILE="5MW_Land_DLL_WTurb_cpp.fst"
FASTCPP_FILE="cDriver.yaml"
#----------------------------------
# EXAWIND FILES
#----------------------------------
NALU_FILE="nrel5mw_nalu.yaml"
AMR_FILE="nrel5mw_amr.inp"
DRIVER_FILE="nrel5mw.yaml"
#----------------------------------
# DEFAULT VARIABLES
#----------------------------------
PRECURSORLENGTH=80.0

#----------------------------------
# PARSER START
#----------------------------------
for i in "$@"; do
    case "$1" in
        -m=*|--machine=*)
            MACHINE="${i#*=}"
            shift # past argument=value
            ;;
        -w=*|--wind_speed=*)
            WIND_SPEED="${i#*=}"
            shift # past argument=value
            ;;
        -s=*|--submit=*)
            SUBMIT="${i#*=}"
            shift # past argument=value
            ;;
        -e=*|--email=*)
            EMAIL="${i#*=}"
            shift # past argument=value
            ;;
        -c=*|--runcfd=*)
            RUNCFD="${i#*=}"
            shift # past argument=value
            ;;
        -p=*|--runprescursor=*)
            RUNPRECURSOR="${i#*=}"
            shift # past argument=value
            ;;
        -n=*|--numnodes=*)
            NUMNODES="${i#*=}"
            shift # past argument=value
            ;;
        -l=*|--precursorlength=*)
            PRECURSORLENGTH="${i#*=}"
            shift # past argument=value
            ;;
        -d=*|--rundir=*)
            RUNDIRECTORY="${i#*=}"
            shift # past argument=value
            ;;
        --)
            shift
            break
            ;;
    esac
done
#----------------------------------
# PARSER END
#----------------------------------

# must load things so that aprepro is active in the shell
# machine specific params i.e. mesh/restart/etc
scriptdir=$(pwd)
aprepro_include=$(pwd)/aprepro/${MACHINE}_aprepro.txt
source $(pwd)/${MACHINE}_setup_env.sh

# define rpm and pitch inputs for this wind speed
rpm_pitch_time=$(./process_turbine_params.py ${WIND_SPEED} ${PRECURSORLENGTH})
rpm=$(echo "$rpm_pitch_time" | awk '{print $1}')
pitch=$(echo "$rpm_pitch_time" | awk '{print $2}')
cfd_dt=$(echo "$rpm_pitch_time" | awk '{print $3}')
openfast_dt=$(echo "$rpm_pitch_time" | awk '{print $4}')
azblend=$(echo "$rpm_pitch_time" | awk '{print $5}')
preclen=$(echo "$rpm_pitch_time" | awk '{print $6}')
dtratio=$(echo "$rpm_pitch_time" | awk '{print $7}')
chkpnum=$(echo "$rpm_pitch_time" | awk '{print $8}')

if [ -z "$RUNDIRECTORY" ]; then
  RUNDIRECTORY=${scriptdir}
fi

target_dir=${RUNDIRECTORY}/wind_speed_$WIND_SPEED
mkdir -p $target_dir

cp -R openfast_run/* $target_dir
cp -R fsi_run/* $target_dir

# shouldn't need to do this, pointing to the absolute path of the files now
# if [ "$RUNDIRECTORY" != "$scriptdir" ] ; then
#     cp -R ${TURBINE_BASE_DIR} ${RUNDIRECTORY}/.
# fi

cd $target_dir

# If just a precursor run, use only single node per job
if [ "$RUNCFD" -eq 1 ] ; then
    echo "Not changing NUMNODES"
else 
    echo "Running on single nodes, precursor only"
    NUMNODES=1
fi

FAST_NAME="${FAST_FILE%????}"

echo "Fast name: $FAST_NAME"

echo "$w: dt ratio: $dtratio"

# text replace the wind speed and mesh location in these files
# cfd input file replacements
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED CFD_DT=$cfd_dt OPENFAST_DT=$openfast_dt PREC_LEN=$preclen CHKP_NUM=$chkpnum AZB=$azblend ${NALU_FILE} ${NALU_FILE} 
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED CFD_DT=$cfd_dt ${AMR_FILE} ${AMR_FILE} 

# openfast model replacements
aprepro -qW --include ${aprepro_include} TURBINE_BASE_DIR=$TURBINE_BASE_DIR ${SERVO_FILE} ${SERVO_FILE}
aprepro -qW --include ${aprepro_include} RPM=$rpm PITCH=$pitch  ${ELASTO_FILE} ${ELASTO_FILE}
aprepro -qW --include ${aprepro_include} TURBINE_BASE_DIR=$TURBINE_BASE_DIR OPENFAST_DT=$openfast_dt ${FAST_FILE} ${FAST_FILE}
aprepro -qW --include ${aprepro_include} TURBINE_BASE_DIR=$TURBINE_BASE_DIR ${AERODYN_FILE} ${AERODYN_FILE}

# openfastcpp input replacements 
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED CFD_DT=$cfd_dt PREC_LEN=$preclen AZB=$azblend ${FASTCPP_FILE} ${FASTCPP_FILE}

# submit script replacements
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED EMAIL=$EMAIL RUN_PRE=$RUNPRECURSOR RUN_CFD=$RUNCFD NNODES=$NUMNODES SCRIPT_DIR=$scriptdir $scriptdir/run_case.sh.i run_case.sh

# submit case if submit flag given
if [ -n "${SUBMIT}" ]; then
    sbatch run_case.sh
else
    return
fi
