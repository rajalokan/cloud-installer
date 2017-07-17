#!/usr/bin/env bash

is_sclib_imported 2> /dev/null ||
    SCLIB_PATH="/tmp/sclib.sh"
    SCLIB_GIT_RAW_URL="https://raw.githubusercontent.com/rajalokan/cloud-installer/master/scripts/sclib.sh"
    if [[ ! -f ${SCLIB_PATH} ]]; then
        wget ${SCLIB_GIT_RAW_URL} -O ${SCLIB_PATH}
    fi
    source ${SCLIB_PATH}

_log "Bootstrapping gutsdev"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

_source_file dotfiles/main.sh
_setup_dotfiles

# _source_file common.sh
# _bootstrap_dotfiles

# _update_and_upgrade


# # # preconfigure for openstack installation
# # _source_file openstack/common.sh
# # _preconfigure_installation
# # _setup_mysql
# # _setup_rabbitmq
# # _setup_memcached

# # _source_file openstack/keystone.sh
# # _setup_keystone
