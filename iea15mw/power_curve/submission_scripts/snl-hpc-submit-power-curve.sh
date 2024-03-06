#!/bin/bash

wind_speeds=(5.0 6.0 7.0 8.0 9.0 10.0 10.59 12.0 14.0 17.0 20.0 23.0 25.0)
#wind_speeds=(5.0 8.0 10.59 14.0)
#wind_speeds=(10.59 14.0)
for w in "${wind_speeds[@]}"; do
  echo "Setting up directory for wind speed $w"
  ./setup_case.sh -m=snl-hpc -w="$w" -s=0 -p=1 -c=1 -n=90 -l=80.0
done
  
