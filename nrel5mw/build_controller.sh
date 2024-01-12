#!/usr/bin/env spack-python

"""
Call this script with the spack env used to compile openfast active in your
shell to compile the controller
"""
import os
import spack.cmd
import spack.main

build_env = spack.main.SpackCommand("build-env", subprocess=True)

spack.cmd.require_active_env(cmd_name="this script")
print("Compile openfast servo")
os.chdir("5MW_Baseline/ServoData")
args = ["openfast", "fc", "-shared", "-fPIC", "-o", "libdiscon.so", "DISCON/DISCON.F90"]
print("spack", build_env.command_name, *args)
print(build_env(*args, fail_on_error=False))
