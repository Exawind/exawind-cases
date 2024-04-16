#!/bin/bash -l
{SCHEDULER_ARGS}

set -e

cmd() {
  echo "+ $@"
  eval "$@"
}

{if(SUBMIT_EXPORTS)}
{SUBMIT_EXPORTS}
{endif}

cmd "export EXAWIND_MANAGER=${MY_EXAWIND_MANAGER}"
cmd "source ${EXAWIND_MANAGER}/start.sh && spack-start"
cmd "spack env activate ${SPACK_ENV_NAME}"
cmd "spack load ${EXAWIND_EXE}"
cmd "which exawind"

{RUN_COMMAND_OPENFAST}
{RUN_COMMAND_EXAWIND}
