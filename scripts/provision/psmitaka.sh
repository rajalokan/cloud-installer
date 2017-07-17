#!/usr/bin/env bash

info_block "" 2> /dev/null ||
    SCLIB_PATH="/tmp/sclib.sh"
    SCLIB_GIT_RAW_URL="https://raw.githubusercontent.com/rajalokan/cloud-installer/master/scripts/sclib.sh"
    if [[ ! -f ${SCLIB_PATH} ]]; then
        wget ${SCLIB_GIT_RAW_URL} -O ${SCLIB_PATH}
    fi
    source ${SCLIB_PATH}

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${CURRENT_DIR}/../cloud_common.sh

_log "Bootstrapping psmitaka"

# _bootstrap_dotfiles

info_block "Preconfigure packstack installation"
