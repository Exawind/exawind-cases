Steps to run IEA 15-MW FSI simulations

The OpenFAST setup of the IEA 15-MW turbine is based on v1.1.6 adapted to run with OpenFAST develop branch (pre 4.0 release).

Run the `setup_case.sh` script and supply a wind speed.

``` shell
./setup_case.sh -w 8.0
```


This will create a run directory `run_[name]`, populate the files, run the openfast precursor and move all the files you need into the run directory.
If you include the `-s=True` flag then it will also submit a job for you on the platform, and the `-e=[your email]` command will have slurm email you about the job.

The files are processed for each machine based on the values in the `aprepro/[machine]_aprepro.txt` file
using the environment in the `envs/[machine]_setup_env.sh` file.

You can tweak things there, but it would be best to tweak them in the run directory and open a PR if a change needs to be made to these templates.

Generalized power curve submissions for specific machines to reproduce results are available in the 
`submission_scripts/` directory.

