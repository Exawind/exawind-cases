## 5MW_Land_DLL_WTurb

To run a single wind speed:

./setup_case.sh -m=eagle -e="ndeveld@sandia.gov" -w=14 -s=0 -p=1 -c=1 -n=80 -l=60.0 -d=./test1

To run timeseries comparison:

python3 post/timeseries_powercurve.py -d testBDchange -p ws14 -y cDriver.yaml -f 5MW_Land_DLL_WTurb_cpp.out


