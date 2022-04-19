#!/bin/bash
# NOTE!!! needs to be run as sources
# Example: . ./conda-activate.sh (uses NAME in .cond_env)

export $(cat .conda_env | xargs)

conda activate $NAME
