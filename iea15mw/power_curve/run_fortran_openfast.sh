#!/bin/bash
cd $1/openfast_run
srun --exclusive openfast IEA-15-240-RWT-Monopile.fst &> log
