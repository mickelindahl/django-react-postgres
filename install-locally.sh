#!/bin/bash

if [[ ! "${BASH_SOURCE[0]}" != "${0}" ]]; then

   echo "script needs to be run with source as: 'source ${BASH_SOURCE[0]} ...'"
   exit

fi

OS=$1
case "$OS" in
       linux ) echo "Installing for linux";;
       mac ) echo "Installing for mac" && SED_FIX=.orginal;;
       * ) echo "Need to provide argument for os type: linux | mac" && return;;
esac
echo ""


BASE_NAME=django_react_postgres

DB_USER=django_react_postgres
DB_PASS=secret
DB_PORT_EXTERNAL=5420

# Should always be 5432
DB_PORT_INTERNAL=5432
DB_CONTAINER_NAME=${BASE_NAME}_db

DB_VOLUME_NAME_COMPOSE=db-14
DB_VOLUME_NAME=${BASE_NAME}_${DB_VOLUME_NAME_COMPOSE}

DJANGO_SUPERUSER_PASSWORD=secret
DJANGO_SUPERUSER_USERNAME=admin
DJANGO_SUPERUSER_EMAIL=admin@mail.com

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



if [ -f conda-settings.txt ]; then

   export $(cat conda-settings.txt | xargs)

   TMP=$(conda env list | grep ".*${CONDA_ENV_NAME} .*")

   if [ -z "$TMP" ]; then
       echo "No conda environment, creating ..."
       ./conda-create "$CONDA_ENV_NAME" "$CONDA_PYTHON_VERSION"
   fi

   echo "Activating conda environment ..."
   conda activate "$CONDA_ENV_NAME"
else

  echo "conda-settings.txt missing, please create it"
  echo "cp sample.conda-settings.txt conda-settings.txt and then edit conda-settings.txt"
  exit

fi

TMP=$(conda list | grep ".*django .*")
if [ -z "$TMP" ]; then
   echo "No django detected. Need to install requirements"
   read -p "Press enter to continue"
   ./install-python-dependencies.sh;
else
  read -p "Install python packages (y/N)?" choice
  case "$choice" in
         y|Y ) ./install-python-dependencies.sh;;
         n|N ) echo "Not installing";;
         * ) echo "Not installing";;
  esac
  echo ""
fi

echo "Install django superuser if it does not exist"
read -p "Press enter to continue"
python manage.py create_superuser_if_none_exists --user=$DJANGO_SUPERUSER_USERNAME --password=$DJANGO_SUPERUSER_PASSWORD --email=$DJANGO_SUPERUSER_EMAIL


TMP=$(docker ps -a | grep ".* $DB_CONTAINER_NAME.*" | wc -l)

if [ "$TMP" = 1 ]; then
    echo "Remove previous postgres container  $DB_CONTAINER_NAME"
    read -p "Press enter to continue"
    echo ""
    docker-compose stop
    docker-compose rm -f
fi


TMP=$(docker volume ls | grep ".* $DB_VOLUME_NAME_COMPOSE.*")
if [[ -n $TMP ]]; then

    echo "DB data volume $DB_VOLUME_NAME_COMPOSE exists"
    read -p "Remove (y/N)?" choice
    case "$choice" in
       y|Y ) echo "Remove db" && docker volume rm $DB_VOLUME_NAME_COMPOSE;;
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
echo ""
cp sample.db.docker-compose.yml db.docker-compose.yml
sed -i ${SED_FIX} "s/{postgres-user}/$DB_USER/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{postgres-pass}/$DB_PASS/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{postgres-port-external}/$DB_PORT_EXTERNAL/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{postgres-port-internal}/$DB_PORT_INTERNAL/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{network}/$NETWORK/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{db-container-name}/$DB_CONTAINER_NAME/g" db.docker-compose.yml
sed -i ${SED_FIX} "s/{db-volume-name}/$DB_VOLUME_NAME_COMPOSE/g" db.docker-compose.yml


echo "Generating volume.docker-compose.yml"
read -p "Press enter to continue"
echo ""
cp sample.volumes.docker-compose.yml volumes.docker-compose.yml
sed -i ${SED_FIX} "s/{db-volume-name}/$DB_VOLUME_NAME_COMPOSE/g" volumes.docker-compose.yml


echo "Generating network.docker-compose.yml"
read -p "Press enter to continue"
echo ""
cp sample.network.docker-compose.yml network.docker-compose.yml
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
           n|N ) echo "Not installing";;
           * ) echo "Not installing";;
   esac
   echo ""
fi

if [ ! -f .env ]; then

   DJANGO_SECRET_KEY=$(tr -dc 'a-z0-9!@#$%^&*(-_=+)' < /dev/urandom | head -c50)

   echo "DJANGO_SECRET_KEY: $DJANGO_SECRET_KEY"

   echo "Create .env"
   read -p "Press enter to continue"
   echo ""
   cp sample.env .env
   sed -i ${SED_FIX} "s/{django-secret-key}/\"$DJANGO_SECRET_KEY\"/g" .env
   sed -i ${SED_FIX} "s/{db-user}/$DB_USER/g" .env
   sed -i ${SED_FIX} "s/{db-name}/$DB_USER/g" .env
   sed -i ${SED_FIX} "s/{db-pass}/$DB_PASS/g" .env
   sed -i ${SED_FIX} "s/{db-port}/$DB_PORT_EXTERNAL/g" .env
   sed -i ${SED_FIX} "s/{db-host}/localhost/g" .env


   if [[ (-f .env${SED_FIX}) && ( ! "$SED_FIX" = "" ) ]]; then

      rm .env${SED_FIX}
   fi
fi

echo "Generate docker-compose.yml"
read -p "Press enter to continue"
echo ""
cat db.docker-compose.yml network.docker-compose.yml volumes.docker-compose.yml > docker-compose.yml

echo "Install db docker container $DB_CONTAINER_NAME"
read -p "Press enter to continue"
echo ""
docker-compose up -d

DB_DOCKER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DB_CONTAINER_NAME)


export $(cat .env | xargs)

echo "Done!"
echo ""
echo "  ************"
echo "  Django"
echo "  ************"
echo "  Secret key: $DJANGO_SECRET_KEY"
echo ""
echo "  Password: $PGADMIN_PASS"
echo ""
echo "  ********************"
echo "  Db credentials"
echo "  ********************"
echo "  Host: $DB_HOST"
echo "  Host ip: $DB_DOCKER_IP (can change when docker service restarts)"
echo "  Name: $DB_NAME"
echo "  Port: $DB_PORT"
echo "  Maintenace database: $DB_USER"
echo "  Username: $DB_USER"
echo "  Password: $DB_PASS"
echo ""