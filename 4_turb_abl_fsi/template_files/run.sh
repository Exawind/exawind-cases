#!/bin/bash -l
{SCHEDULER_ARGS}

#source $EXAWIND_MANAGER/start.sh
#spack load exawind

{if(SUBMIT_EXPORTS)}
{SUBMIT_EXPORTS}
{endif}

{RUN_COMMAND_OPENFAST}
{RUN_COMMAND_EXAWIND}
