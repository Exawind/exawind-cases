# step 1 checks
source ${SPACK_MANAGER}/start.sh
spack-start # ensure spack-manager is going

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
        -t=*|--tower=*)
            TOWER="${i#*=}"
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
rundir="run_${PROBNAME}"
mkdir -p ${rundir}

# step 4 setup build dir
echo "Setting up build dir"
spack build-env trilinos aprepro -qW --include ${aprepro_include} TOWER=${TOWER} template_files/nrel5mw_nalu.yaml ${rundir}/nrel5mw_nalu.yaml
spack build-env trilinos aprepro -qW --include ${aprepro_include} template_files/nrel5mw_amr.inp ${rundir}/nrel5mw_amr.inp
spack build-env trilinos aprepro -qW --include ${aprepro_include} NAME=${PROBNAME}  template_files/slurm_sub.sh ${rundir}/slurm_sub.sh
cp template_files/nrel5mw.yaml ${rundir}
cp template_files/hypre_file.yaml ${rundir}
cp openfast_run/* ${rundir}
exit

# step 5 run openfast
cd ../5MW_Baseline/ServoData/
spack build-env openfast fc -shared -fPIC -o libdiscon.so DISCON/DISCON.F90 
# run standalone openfast and copy files to run directory
set -x
cd $rundir/
spack build-env openfast openfastcpp inp.yaml

# step 6 submit job if desired
if [ -n "${SUBMIT}" ]; then
  sbatch slurm_sub.sh
fi
