#!/bin/bash

CONDA_ENV_NAME=$1

conda install -y -n "$CONDA_ENV_NAME" -c anaconda django
conda install -y -n "$CONDA_ENV_NAME" -c conda-forge python-dotenv
conda install -y -n "$CONDA_ENV_NAME" -c anaconda requests
conda install -y -n "$CONDA_ENV_NAME" -c anaconda psycopg2