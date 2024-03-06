PRECURSORLENGTH=80.0
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

# must load things so that aprepro is active in the shell
# machine specific params i.e. mesh/restart/etc
scriptdir=$(pwd)
aprepro_include=$(pwd)/aprepro/${MACHINE}_aprepro.txt
source $(pwd)/envs/${MACHINE}_setup_env.sh

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

if [ "$RUNDIRECTORY" != "$scriptdir" ] ; then
    cp -R IEA-15-240-RWT ${RUNDIRECTORY}/.
fi

cd $target_dir

# If just a precursor run, use only single node per job
if [ "$RUNCFD" -eq 1 ] ; then
    echo "Not changing NUMNODES"
else 
    echo "Running on single nodes, precursor only"
    NUMNODES=1
fi

echo "$w: dt ratio: $dtratio"

# text replace the wind speed and mesh location in these files
# cfd input file replacements
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED CFD_DT=$cfd_dt OPENFAST_DT=$openfast_dt PREC_LEN=$preclen CHKP_NUM=$chkpnum AZB=$azblend iea15mw-nalu-01.yaml iea15mw-nalu-01.yaml 
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED CFD_DT=$cfd_dt iea15mw-amr-01.inp iea15mw-amr-01.inp 

# openfast model replacements
aprepro -qW --include ${aprepro_include} IEA-15-240-RWT-Monopile_ServoDyn.dat IEA-15-240-RWT-Monopile_ServoDyn.dat
aprepro -qW --include ${aprepro_include} RPM=$rpm PITCH=$pitch  IEA-15-240-RWT-Monopile_ElastoDyn.dat IEA-15-240-RWT-Monopile_ElastoDyn.dat
aprepro -qW --include ${aprepro_include} OPENFAST_DT=$openfast_dt IEA-15-240-RWT-Monopile.fst IEA-15-240-RWT-Monopile.fst

# openfastcpp input replacements 
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED CFD_DT=$cfd_dt PREC_LEN=$preclen AZB=$azblend inp.yaml inp.yaml

# submit script replacements
aprepro -qW --include ${aprepro_include} WIND_SPEED=$WIND_SPEED EMAIL=$EMAIL RUN_PRE=$RUNPRECURSOR RUN_CFD=$RUNCFD NNODES=$NUMNODES SCRIPT_DIR=$scriptdir $scriptdir/run_case.sh.i run_case.sh

# submit case if submit flag given
if [ -n "${SUBMIT}" ]; then
  if [ "${MACHINE}"=="snl-hpc" ]; then
    #sbatch -M chama,skybridge run_case.sh
    sbatch run_case.sh
  else
    sbatch run_case.sh
  fi
fi
