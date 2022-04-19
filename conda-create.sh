#!/bin/bash
# Exampel: ./create-conda my-conda-env 3.7 -> creates conda environment with python 3.7

if [ -z $1 ]; then
   echo "Missing first argument for name of conda environment you want to create"
   exit 0
fi

if [ -z $2 ]; then
   echo "Missing second argument for python version to use"
   exit 0
fi

conda create --name $1 python=$2

echo "NAME=$1" > .conda_env
echo "PYTHON_VERSION=$2" >> .conda_env
