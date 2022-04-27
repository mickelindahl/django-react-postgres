#!/bin/bash

CURRENT_SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CREDENTIALS_PATH=$CURRENT_SCRIPT_PATH/credentials.txt
SAMPLES_PATH=samples

# Import helper function add_envs_from_file
. "$CURRENT_SCRIPT_PATH/shell/lib/add_envs_from_file.sh"

add_envs_from_file "$CREDENTIALS_PATH" "DOCKER_BASE_NAME" "DB_IMAGE" "DB_PASS" "DB_PORT_EXTERNAL"

arrIN=(${DOCKER_BASE_NAME//_/ })

if [ "${#arrIN[@]}" -gt 1 ]; then
    echo "DOCKER_BASE_NAME cant not contain underscore _ since. Please change to -"
    echo "This is because docker makes this substitution anyway upon container and"
    echo "volume creation"
    exit
fi

DB_USER=${DOCKER_BASE_NAME}
DB_CONTAINER_NAME=${DOCKER_BASE_NAME}-db

# Split on .
arrIN=(${DB_IMAGE//./ })

# Pick out first element db image name + major version tag
TMP=${arrIN[0]}

# Create short and long name for db. When compose
DB_VOLUME_NAME_COMPOSE=$(echo "$TMP" | sed -r 's/[:]+/-/g')
DB_VOLUME_NAME_FULL=${DOCKER_BASE_NAME}_${DB_VOLUME_NAME_COMPOSE}

# Conda
add_envs_from_file "$CREDENTIALS_PATH" "CONDA_ENV_NAME" "CONDA_BASE_PATH"
CONDA_PYTHON_PATH=$CONDA_BASE_PATH/envs/$CONDA_ENV_NAME/bin/python

# Docker network
NETWORK=default-net

# Server
SERVER_CONTAINER_NAME=${DOCKER_BASE_NAME}-server
SERVER_VOLUME_NAME_COMPOSE=storage
SERVER_VOLUME_NAME=${DOCKER_BASE_NAME}_$SERVER_VOLUME_NAME


echo "Generating server.docker-compose.yml"
echo ""
add_envs_from_file "$CREDENTIALS_PATH" "CONDA_ENV_NAME" "CONDA_BASE_PATH" "DB_IMAGE" "DB_PASS" "DB_PORT_EXTERNAL" "VIRTUAL_HOST"
cp $SAMPLES_PATH/sample.server.docker-compose.yml server.docker-compose.yml
sed -i "s/{conda-env-name}/$CONDA_ENV_NAME/g" server.docker-compose.yml
sed -i "s|{conda-base-path}|$CONDA_BASE_PATH|g" server.docker-compose.yml
sed -i "s/{db-container-name}/$DB_CONTAINER_NAME/g" server.docker-compose.yml
sed -i "s/{image-name}/$SERVER_CONTAINER_NAME/g" server.docker-compose.yml
sed -i "s/{image-tag}/latest/g" server.docker-compose.yml
sed -i "s/{network}/$NETWORK/g" server.docker-compose.yml
sed -i "s/{server-container-name}/$SERVER_CONTAINER_NAME/g" server.docker-compose.yml
sed -i "s/{server-volume-name}/$SERVER_VOLUME_NAME_COMPOSE/g" server.docker-compose.yml
sed -i "s/{virtual-host}/$VIRTUAL_HOST/g" server.docker-compose.yml

echo "Generating db.docker-compose.yml"
echo ""
add_envs_from_file "$CREDENTIALS_PATH" "DB_IMAGE" "DB_PASS" "DB_PORT_EXTERNAL"
cp $SAMPLES_PATH/sample.db.docker-compose.yml db.docker-compose.yml
sed -i "s/{db-container-name}/$DB_CONTAINER_NAME/g" db.docker-compose.yml
sed -i "s/{db-volume-name}/$DB_VOLUME_NAME_COMPOSE/g" db.docker-compose.yml
sed -i "s/{db-image}/$DB_IMAGE/g" db.docker-compose.yml
sed -i "s/{network}/$NETWORK/g" db.docker-compose.yml
sed -i "s/{postgres-user}/$DB_USER/g" db.docker-compose.yml
sed -i "s/{postgres-pass}/$DB_PASS/g" db.docker-compose.yml
sed -i "s/{postgres-port-external}/$DB_PORT_EXTERNAL/g" db.docker-compose.yml
sed -i "s/{postgres-port-internal}/5432/g" db.docker-compose.yml


echo "Generating volume.docker-compose.yml"
echo ""
cp $SAMPLES_PATH/sample.volumes.docker-compose.yml volumes.docker-compose.yml
sed -i "s/{db-volume}/$DB_VOLUME_NAME_COMPOSE:/g" volumes.docker-compose.yml
sed -i "s/{server-volume}/$SERVER_VOLUME_NAME_COMPOSE:/g" volumes.docker-compose.yml


echo "Generating network.docker-compose.yml"
echo ""
cp $SAMPLES_PATH/sample.network.docker-compose.yml network.docker-compose.yml
sed -i "s/{network}/$NETWORK/g" network.docker-compose.yml


echo "Generate docker-compose.yml"
echo ""
cat $SAMPLES_PATH/sample.pre.docker-compose.yml server.docker-compose.yml db.docker-compose.yml network.docker-compose.yml volumes.docker-compose.yml > docker-compose.yml


echo "Removing staging files server.docker-compose.yml db.docker-compose.yml network.docker-compose.yml volumes.docker-compose.yml"
echo ""
rm server.docker-compose.yml db.docker-compose.yml network.docker-compose.yml volumes.docker-compose.yml


echo "Create .env-server"
echo ""
add_envs_from_file "$CREDENTIALS_PATH" "CONDA_PYTHON_PATH" "DB_HOST" "DB_PASS" "DB_PORT_EXTERNAL" "DJANGO_SECRET_KEY"
cp $SAMPLES_PATH/sample.env .env-tmp
sed -i "s|{conda-python-path}|$CONDA_PYTHON_PATH|g" .env-tmp
sed -i "s|{django-secret-key}|\'$DJANGO_SECRET_KEY\'|g" .env-tmp
sed -i "s/{db-user}/$DB_USER/g" .env-tmp
sed -i "s/{db-name}/$DB_USER/g" .env-tmp
sed -i "s/{db-pass}/$DB_PASS/g" .env-tmp
sed -i "s/{db-port}/5432/g" .env-tmp
sed -i "s/{db-host}/$DB_CONTAINER_NAME/g" .env-tmp

#rm .env-tmp

TMP=$(docker ps -a | grep ".* $DB_CONTAINER_NAME.*" | wc -l)

if [ "$TMP" = 1 ]; then
    echo "Stop and remove previous containers"
    read -p "Press enter to continue"
    echo ""
    docker-compose stop
    docker-compose  rm -f
fi

echo "Install docker containers"
read -p "Press enter to continue"
echo ""

docker-compose build
docker-compose up -d
