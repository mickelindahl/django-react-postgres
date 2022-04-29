#!/bin/bash

export $(cat .env | xargs)

$CONDA_PYTHON_PATH manage.py makemigrations server
$CONDA_PYTHON_PATH manage.py migrate --check

TMP=$($CONDA_PYTHON_PATH manage.py migrate --check | grep ".* No migrations to apply.*" | wc -l)
if [ "$TMP" = 0 ]; then


  $CONDA_PYTHON_PATH manage.py migrate

fi

#conda init bash
#conda activate "$CONDA_ENV_NAME"
#cd $CURRENT
#
$CONDA_PYTHON_PATH manage.py runserver 0.0.0.0:8000
