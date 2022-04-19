# Django react postgres

Django webserver with react as frontend and postgres as database
## Installation

### Python with conda environment
To install conda environment called django-react-postgres with python 3.7 run
```shell
./conda-create.sh django-react-postgres 3.7
```

Then activate by running
```shell
. ./conda-activate.sh
```

### Django

Run
```shell
conda install -c anaconda django
```

Then in root of project run
```shell
django-admin startproject server .
```

### React

Activate node 16
```shell
nvm use 16
```


