#!/usr/bin/env bash

BASE_DIR="/opt"
PROJECT_DIR="${BASE_DIR}/cloud-installer"

SCRIPTS_LIBRARY_PATH="/tmp/scripts-library.sh"
SCRIPTS_LIBRARY_GIT_RAW_PATH="https://raw.githubusercontent.com/rajalokan/cloud-installer/master/scripts/scripts-library.sh"

CLOUD_INSTALLER_GIT_REPO="https://github.com/rajalokan/cloud-installer.git"

info_block "Running ...." 2> /dev/null ||
    if [[ ! -f ${SCRIPTS_LIBRARY_PATH} ]]; then
        echo "fetching"
        wget ${SCRIPTS_LIBRARY_GIT_RAW_PATH} -O ${SCRIPTS_LIBRARY_PATH} 2> /dev/null
    fi
    source ${SCRIPTS_LIBRARY_PATH}

# Install git
is_package_installed git || install_package git

sudo chown -R ${USER}:${USER} /opt

# clone cloud-installer if not present
if [ ! -d ${PROJECT_DIR} ]; then
    info_block "Close cloud-installer at ${PROJECT_DIR}"
    git clone ${CLOUD_INSTALLER_GIT_REPO} ${PROJECT_DIR}
fi

# bootstrap ansible
info_block "Bootstrapping System with Ansible executable"
eval $(printf "%q\n" "${PROJECT_DIR}/scripts/bootstrap-ansible.sh")
info_block "System is bootstrapped with ansible and ready to run playbooks."

# # Run playbook
# info_block "Running playbook for playbox"
# eval $(printf "%q\n" "${PROJECT_DIR}/scripts/bootstrap.sh" "playbox")
