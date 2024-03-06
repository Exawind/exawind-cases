#!/bin/bash
cd $1/openfast_run
rm *chkp *out
srun --exclusive /home/gvijayak/exawind/source/spack-manager/environments/fsi-merge-release/openfast/spack-build-l6k24la/glue-codes/openfast-cpp/openfastcpp inp.yaml &> log
