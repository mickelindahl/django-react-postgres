#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/print_stack.sh"
#. ./jenkins-ci/lib/print_stack.sh

add_envs_from_file () {

    FILE_NAME=$1

#    echo "Add envs from file"

    if [ ! -f "$FILE_NAME" ]; then
        print_stack "Missing file $FILE_NAME. Please add it."
#        echo "Exit"
#        sleep 10
        exit 1
    fi

    export $(cat $FILE_NAME | xargs)

    for arg in "${@:2}"; do

        if [ "${!arg}" = "" ];then
            print_stack "Missing env $arg in file $FILE_NAME"
#             sleep 10
#             echo "Exit"
            exit 1
        fi

    done

}
