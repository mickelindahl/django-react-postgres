#!/bin/bash

CURRENT_SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CREDENTIALS_PATH=$CURRENT_SCRIPT_PATH/credentials-local.txt
DOCKER_COMPOSE_FILE=local.docker-compose.yml

SAMPLES_PATH=samples

# Import helper function add_envs_from_file
. "$CURRENT_SCRIPT_PATH/shell/lib/add_envs_from_file.sh"

#if [[ ! "${BASH_SOURCE[0]}" != "${0}" ]]; then
#
#   echo "script needs to be run with source as: 'source ${BASH_SOURCE[0]} ...'"
#   exit
#
#fi

OS=$1
case "$OS" in
       linux ) echo "Installing for linux";;
       mac ) echo "Installing for mac" && SED_FIX=.orginal;;
       * ) echo "Need to provide argument for os type: linux | mac" && exit;;
esac
echo ""

add_envs_from_file "$CREDENTIALS_PATH" "DOCKER_BASE_NAME" "DB_IMAGE" "DB_PASS" "DB_PORT_EXTERNAL"

arrIN=(${DOCKER_BASE_NAME//_/ })

if [ "${#arrIN[@]}" -gt 1 ]; then
    echo "DOCKER_BASE_NAME cant not contain underscore _ since. Please change to -"
    echo "This is because docker makes this substitution anyway upon container and"
    echo "volume creation"
    exit
fi


DB_USER=${DOCKER_BASE_NAME}-local
DB_CONTAINER_NAME=${DOCKER_BASE_NAME}-local-db
DOCKER_PROJECT=${DOCKER_BASE_NAME}-local

# Split on .
arrIN=(${DB_IMAGE//./ })

# Pick out first element db image name + major version tag
TMP=${arrIN[0]}

# Create short and long name for db. When compose
DB_VOLUME_NAME_COMPOSE=$(echo "$TMP" | sed -r 's/[:]+/-/g')
DB_VOLUME_NAME_FULL=${DOCKER_PROJECT}_${DB_VOLUME_NAME_COMPOSE}



# Conda
add_envs_from_file "$CREDENTIALS_PATH" "CONDA_ENV_NAME" "CONDA_BASE_PATH"
CONDA_PYTHON_PATH=$CONDA_BASE_PATH/envs/$CONDA_ENV_NAME/bin/python

# Docker network
NETWORK=default-net

# Node version
NODE_VERSION=16

NODE_CURRENT=$(node -v)
if [[ ! ${NODE_CURRENT} =~ v$NODE_VERSION+ ]]; then

  echo "Wrong node version $NODE_CURRENT. Setting default to v$NODE_VERSION.x.x"
  read -p "Press enter to continue"
  echo ""
  nvm use ${NODE_VERSION} || nvm install node $NODE_VERSION
  nvm use ${NODE_VERSION}
  nvm alias default ${NODE_VERSION}

fi

if [ -d node_modules/ ]; then

   echo "node_modules directory detected"
   read -p "Remove (y/N)?" choice
   case "$choice" in
      y|Y ) echo "Remove node_modules" && sudo rm -r node_modules;;
      n|N ) echo "Keep node_modules";;
      * ) echo "Keep node_modules";;
   esac
   echo ""

fi

read -p "Install node packages (y/N)?" choice
case "$choice" in
       y|Y ) npm install;;
       n|N ) echo "Not installing";;
       * ) echo "Not installing";;
esac
echo ""


if [ -f "$CREDENTIALS_PATH" ]; then

   add_envs_from_file "$CREDENTIALS_PATH" "CONDA_ENV_NAME" "CONDA_PYTHON_VERSION"

   TMP=$(conda env list | grep ".*${CONDA_ENV_NAME} .*")

   if [ -z "$TMP" ]; then
       echo "No conda environment, creating ..."
       ./shell/scripts/conda-create "$CONDA_ENV_NAME" "$CONDA_PYTHON_VERSION"
   fi

else

  echo "conda-settings.txt missing, please create it"
  echo "cp sample.conda-settings.txt conda-settings.txt and then edit conda-settings.txt"
  exit

fi

TMP=$(conda list -n "$CONDA_ENV_NAME"  | grep ".*django .*")
if [ -z "$TMP" ]; then
   echo "No django detected. Need to install requirements"
   read -p "Press enter to continue"
   ./install-python-dependencies.sh "$CONDA_ENV_NAME";
else
  read -p "Install python packages (y/N)?" choice
  case "$choice" in
         y|Y ) ./install-python-dependencies.sh "$CONDA_ENV_NAME";;
         n|N ) echo "Not installing";;
         * ) echo "Not installing";;
  esac
  echo ""
fi

TMP=$(docker ps -a | grep ".* $DB_CONTAINER_NAME.*" | wc -l)

if [ "$TMP" = 1 ]; then
    echo "Stop and remove previous postgres container  $DB_CONTAINER_NAME"
    read -p "Press enter to continue"
    echo ""
    docker-compose --file $DOCKER_COMPOSE_FILE -p "$DOCKER_PROJECT" stop
    docker-compose --file $DOCKER_COMPOSE_FILE -p "$DOCKER_PROJECT" rm -f
fi


TMP=$(docker volume ls | grep ".* $DB_VOLUME_NAME_FULL.*")
if [[ -n $TMP ]]; then

    echo "DB data volume $DB_VOLUME_NAME_FULL exists"
    read -p "Remove (y/N)?" choice
    case "$choice" in
       y|Y ) echo "Remove db" && docker volume rm "$DB_VOLUME_NAME_FULL";;
       n|N ) echo "Keep db";;
       * ) echo "Keep db";;
    esac
    echo ""

fi


TMP=$(docker network ls | grep $NETWORK)
if [ -z "$TMP" ]; then

   echo "Create external network"
   docker network create -d bridge $NETWORK

fi

echo "Generating db.docker-compose.yml"
#echo "$SED_FIX"
read -p "Press enter to continue"

add_envs_from_file "$CREDENTIALS_PATH" "DB_IMAGE" "DB_PASS" "DB_PORT_EXTERNAL"

echo ""
cp $SAMPLES_PATH/sample.db.docker-compose.yml db.docker-compose.yml
sed -i ${SED_FIX} "s/{db-container-name}/$DB_CONTAINER_NAME/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{db-volume-name}/$DB_VOLUME_NAME_COMPOSE/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{db-image}/$DB_IMAGE/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{network}/$NETWORK/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{postgres-user}/$DB_USER/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{postgres-pass}/$DB_PASS/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{postgres-port-external}/$DB_PORT_EXTERNAL/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{postgres-port-internal}/5432/g" db.docker-compose.yml


echo "Generating volume.docker-compose.yml"
read -p "Press enter to continue"
echo ""
cp $SAMPLES_PATH/sample.volumes.docker-compose.yml volumes.docker-compose.yml
sed -i ${SED_FIX} "s/{db-volume}/$DB_VOLUME_NAME_COMPOSE:/g" volumes.docker-compose.yml
sed -i ${SED_FIX} "s/{server-volume}//g" volumes.docker-compose.yml

echo "Generating network.docker-compose.yml"
read -p "Press enter to continue"
echo ""
cp $SAMPLES_PATH/sample.network.docker-compose.yml network.docker-compose.yml
sed -i ${SED_FIX} "s/{network}/$NETWORK/g" network.docker-compose.yml

if [ "$OS" = "mac" ]; then
  rm db.docker-compose.yml$SED_FIX
  rm network.docker-compose.yml$SED_FIX
  rm volumes.docker-compose.yml$SED_FIX
fi

if [ -f .env ]; then
   echo "Secret file .env exist remove and create new?"
   read -p "Remove (y/N)?" choice
   case "$choice" in
           y|Y ) rm -f .env;;
           n|N ) echo "Not removing";;
           * ) echo "Not removing";;
   esac
   echo ""
fi

if [ ! -f .env ]; then

   add_envs_from_file "$CREDENTIALS_PATH" "DJANGO_ALLOWED_HOSTS" "DJANGO_STORAGE_PATH" "DB_HOST" "DB_PASS" "DB_PORT_EXTERNAL" "DJANGO_SECRET_KEY"

   echo "Create .env"
   read -p "Press enter to continue"
   echo ""
   cp $SAMPLES_PATH/sample.env .env
   sed -i ${SED_FIX} "s|{conda-python-path}|$CONDA_PYTHON_PATH|g" .env
   sed -i ${SED_FIX} "s|{django-allowed-hosts}|$DJANGO_ALLOWED_HOSTS|g" .env
   sed -i ${SED_FIX} "s|{django-secret-key}|\'$DJANGO_SECRET_KEY\'|g" .env
   sed -i ${SED_FIX} "s|{django-storage-path}|$DJANGO_STORAGE_PATH|g" .env
   sed -i ${SED_FIX} "s/{db-user}/$DB_USER/g" .env
   sed -i ${SED_FIX} "s/{db-name}/$DB_USER/g" .env
   sed -i ${SED_FIX} "s/{db-pass}/$DB_PASS/g" .env
   sed -i ${SED_FIX} "s/{db-port}/$DB_PORT_EXTERNAL/g" .env
   sed -i ${SED_FIX} "s/{db-host}/$DB_HOST/g" .env

   if [[ (-f .env${SED_FIX}) && ( ! "$SED_FIX" = "" ) ]]; then

      rm .env${SED_FIX}
   fi
fi

echo "Generate local.docker-compose.yml"
read -p "Press enter to continue"
echo ""
cat $SAMPLES_PATH/sample.pre.docker-compose.yml db.docker-compose.yml network.docker-compose.yml volumes.docker-compose.yml > local.docker-compose.yml

echo "Removing staging files db.docker-compose.yml network.docker-compose.yml volumes.docker-compose.yml"
echo ""
rm db.docker-compose.yml network.docker-compose.yml volumes.docker-compose.yml

echo "Install db docker container $DB_CONTAINER_NAME"
read -p "Press enter to continue"
echo ""
docker-compose --file $DOCKER_COMPOSE_FILE -p "$DOCKER_PROJECT" up -d

echo "Wait 10 sec for db to start"
sleep 10

add_envs_from_file "$CREDENTIALS_PATH" "DJANGO_SUPERUSER_USERNAME" "DJANGO_SUPERUSER_PASSWORD" "DJANGO_SUPERUSER_EMAIL"

TMP=$($CONDA_PYTHON_PATH manage.py migrate --check | grep ".* No migrations to apply.*" | wc -l)
if [ "$TMP" = 0 ]; then
  echo "Migrate django db"
  read -p "Press enter to continue"
  $CONDA_PYTHON_PATH manage.py migrate
fi

echo "Install django superuser if it does not exist"
read -p "Press enter to continue"

"$CONDA_PYTHON_PATH" manage.py create_superuser_if_none_exists --user=$DJANGO_SUPERUSER_USERNAME --password=$DJANGO_SUPERUSER_PASSWORD --email=$DJANGO_SUPERUSER_EMAIL


DB_DOCKER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DB_CONTAINER_NAME)

export $(cat .env | xargs)

echo "Done!"
echo ""
echo "  ************"
echo "  Django"
echo "  ************"
echo "  Secret key: $DJANGO_SECRET_KEY"
echo ""
echo "  Django superuser: $DJANGO_SUPERUSER_USERNAME"
echo "  Django superuser email: $DJANGO_SUPERUSER_EMAIL"
echo "  Django superuser password: $DJANGO_SUPERUSER_PASSWORD"
echo ""
echo "  ********************"
echo "  Db credentials"
echo "  ********************"
echo "  Host external: $DB_HOST (use when connecting from outside container)"
echo "  Host internal: $DB_CONTAINER_NAME (use when connecting from another container on the same docker network e.g. from pgadmin4)"
echo "  Host internal ip: $DB_DOCKER_IP (can change when docker service restarts)"
echo "  Name: $DB_NAME"
echo "  Port: $DB_PORT"
echo "  Maintenance database: $DB_USER"
echo "  Username: $DB_USER"
echo "  Password: $DB_PASS"
echo ""
echo "  Connect from docker host os to db container with localhost and from"
echo "  another container on the same docker network with $DB_HOST"
echo ""
echo "To start server run 'npm start'"