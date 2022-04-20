#!/bin/bash
# NOTE!!! needs to be run as sources
# Example: . ./conda-activate.sh (uses NAME in .cond_env)

if [[ ! "${BASH_SOURCE[0]}" != "${0}" ]]; then

   echo "script needs to be run with source as: 'source ${BASH_SOURCE[0]} ...'"
   exit

fi

export $(cat .conda_env | xargs)

conda activate $NAME
