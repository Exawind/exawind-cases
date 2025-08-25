#!/bin/bash

wind_speeds=(5.0 8.0 10.59 14.0 20.0)
for w in "${wind_speeds[@]}"; do
  echo "Setting up directory for wind speed $w"
  ./setup_case.sh -m=flight -w="$w" -s=1 -p=1 -c=1 -n=30 -l=80.0
done
  
