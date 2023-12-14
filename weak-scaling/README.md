# Weak scaling studies

This directory tracks weak scaling studies. It contains the run scripts and input files for amr-wind, as well as a yaml input file for [Job Scholar](https://github.com/jrood-nrel/job-scholar). Use the `spack.yaml` to build an amr-wind environment with [spack-manager](https://github.com/sandialabs/spack-manager), then one can:

$ git clone https://github.com/jrood-nrel/job-scholar.git
$ cd job-scholar
$ python3 submit_jobs.py amrwind-frontier.yaml
