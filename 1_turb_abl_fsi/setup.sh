# run this from inside your fsi spack environment
spack load openfast
# build controller shared lib
set -x
rundir=$(pwd)
cd ../5MW_Baseline/ServoData/
spack build-env openfast fc -shared  -o libdiscon.so DISCON/DISCON.F90 
# run standalone openfast and copy files to run directory
cd $rundir/openfast_run/
openfastcpp inp.yaml
cp *.nc ../turb_run/
cp *.chkp* ../turb_run/
