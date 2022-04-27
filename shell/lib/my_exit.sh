#!/bin/bash


my_exit () {

    if [[ ! "${BASH_SOURCE[0]}" != "${0}" ]]; then

        echo 'Exit shell script that been executed'
        exit

    else

      echo 'Exit shell script that has been sourced' && return

    fi

}
