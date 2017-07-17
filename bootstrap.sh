#!/usr/bin/env bash

info_block "" 2> /dev/null ||
    SCLIB_PATH="/tmp/sclib.sh"
    SCLIB_GIT_RAW_URL="https://raw.githubusercontent.com/rajalokan/cloud-installer/master/scripts/sclib.sh"
    if [[ ! -f ${SCLIB_PATH} ]]; then
        wget ${SCLIB_GIT_RAW_URL} -O ${SCLIB_PATH}
    fi
    source ${SCLIB_PATH}

if [[ $# < 1 ]]; then
    _error "You must provide machine type to bootstap."
    exit 0
fi

_INSTANCE=${1:-}

case "${_INSTANCE}" in
    stegen | gutsdev | psocata )
        eval $(printf "%q\n" "scripts/provision/${_INSTANCE}.sh")
        ;;
    *)
        _error "Invalid option"
        ;;
esac
