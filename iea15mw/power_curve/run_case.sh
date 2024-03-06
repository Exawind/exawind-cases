#!/bin/bash 

#SBATCH -A FY190020
#SBATCH -t 96:00:00
#SBATCH --qos=long

#SBATCH -o ws8_log_%j.out
#SBATCH -J ws8_iea15mw
#SBATCH -N 1

# load the modules with exawind executable/setup the run env
# MACHINE_NAME will get populated via aprepro
source /Users/psakiev/scratch/hfm_fy23_q1/fy23_q2/snl-hpc_setup_env.sh

nodes=$SLURM_JOB_NUM_NODES
rpn=$(ranks_per_node)
ranks=$(( $rpn*$nodes ))

nalu_ranks=$(( ($ranks*50)/100 ))
amr_ranks=$(( $ranks-$nalu_ranks ))



# isolate run artifacts to make it easier to automate restarts in the future
# if necessary
mkdir run_$SLURM_JOBID
mv *.log run_$SLURM_JOBID
mv *_log_* run_$SLURM_JOBID
mv timings.dat run_$SLURM_JOBID
mv forces*dat run_$SLURM_JOBID

chown $USER:wg-sierra-users .
chmod g+s .

