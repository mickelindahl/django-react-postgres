FROM node:16.14.2

#ARG CONDA_ENV_NAME=django-react-postgres
ARG CONDA_ENV_NAME
ARG CONDA_BASE_PATH
ARG CONDA_BIN_PATH=$CONDA_BASE_PATH/condabin

RUN echo $CONDA_BIN_PATH $CONDA_ENV_NAME

# Install conda, create env and activate it. Also install nano
RUN curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg && \
    install -o root -g root -m 644 conda.gpg /usr/share/keyrings/conda-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/conda-archive-keyring.gpg] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" > /etc/apt/sources.list.d/conda.list && \
    apt-get update -y && \
    apt-get -y install conda && \
    PATH=$PATH:$CONDA_BIN_PATH && \
    export PATH && \
    conda update -n base -c defaults conda && \
    conda create --name $CONDA_ENV_NAME python=3.7 && \
    /bin/bash -c conda activate $CONDA_ENV_NAME && \
    apt-get -y install nano

#ADD conda-activate.sh conda-activate.sh

#RUN

ADD install-python-dependencies.sh install-python-dependencies.sh
RUN PATH=$PATH:$CONDA_BIN_PATH && \
    export PATH && \
    ./install-python-dependencies.sh $CONDA_ENV_NAME

ARG HOME=/home/app
# Add app user
RUN useradd --user-group --create-home --shell /bin/false app

USER app

#RUN  ./install-python-dependencies.sh
#CMD tail -f /dev/null
#CMD ["sleep", "100000"]
#EXPOSE 3000


#ADD entrypoint entrypoint

# Add package.json
ADD package.json $HOME/package.json
ADD package-lock.json $HOME/package-lock.json

# Install packages and add aliases
RUN  mkdir -p $HOME/src && \
     mkdir -p $HOME/storage && \
     cp $HOME/package.json $HOME/src/package.json && \
     cp $HOME/package-lock.json $HOME/src/package-lock.json && \
     cd $HOME/src && \
     npm install && \
     echo 'alias ll="ls -la"' > $HOME/.bash_aliases


ADD .env-tmp $HOME/src/.env
ADD gulpfile.js manage.py tsconfig.json webpack.js $HOME/src/
ADD ./shell/scripts/start-django.sh $HOME/src/shell/scripts/start-django.sh
ADD --chown=app:app ./server $HOME/src/server
ADD --chown=app:app ./frontend-react $HOME/src/frontend-react


#CMD tail -f /dev/null
#
## Bundle app source
#COPY --chown=app:app . $HOME/src

WORKDIR $HOME/src
