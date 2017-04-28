#!/usr/bin/env bash

## Shell Opts ----------------------------------------------------------------
# set -e -u -x

## Vars ----------------------------------------------------------------------
# Base
BASE_DIR="${BASE_DIR:-/opt}"
BOOTSTRAP_DIR="${BOOTSTRAP_DIR:-${BASE_DIR}/bootstrap}"
PROJECT_DIR="${BOOTSTRAP_DIR}/cloud-installer"
# Temp
TEMP_DIR="${TEMP_DIR:-/tmp}"
TEMP_LIBRARY_SCRIPT_PATH="${TEMP_LIBRARY_SCRIPT_PATH:-${TEMP_DIR}/library.sh}"

ANSIBLE_ROLE_FILE_TYPE="DEFAULT"
ANSIBLE_ROLE_FILE_DOTFILES="https://github.com/rajalokan/dotfiles"

# Default deployment is playbox setup.
DEPLOYMENT_TYPE="${1:-playbox}"

# TODO: Quickfix
rm -rf ${BOOTSTRAP_DIR}

# Source library.sh if cloud-installer directory exists
if [[ -d ${PROJECT_DIR} ]]; then
    source ${PROJECT_DIR}/scripts/library.sh
fi

function source_library {
    if [[ ! -f ${TEMP_LIBRARY_SCRIPT_PATH} ]]; then
        wget -q https://raw.githubusercontent.com/rajalokan/cloud-installer/master/scripts/library.sh -O ${TEMP_LIBRARY_SCRIPT_PATH}
    fi
    source ${TEMP_LIBRARY_SCRIPT_PATH}
    info_block "Bootstrapping ${DEPLOYMENT_TYPE} --- Start"
}

info_block "Bootstrapping ${DEPLOYMENT_TYPE} --- Start" 2> /dev/null ||
    source_library

sudo chown -R ${USER}:${USER} ${BASE_DIR}
mkdir -p ${BOOTSTRAP_DIR}

is_package_installed git || install_package git

if [[ ! -d ${PROJECT_DIR} ]]; then
    git clone https://github.com/rajalokan/cloud-installer.git ${PROJECT_DIR}
fi

# Check if ansible is installed, if not bootstrap ansible
ansible-playbook --help > /dev/null 2>&1 ||
    eval $(printf "%q\n" "${PROJECT_DIR}/scripts/bootstrap_ansible.sh")

# Run playbook
pushd "${PROJECT_DIR}/ansible"
    ansible-playbook -e deployment_type=${DEPLOYMENT_TYPE} playbooks/prepare.yml
    ansible-playbook playbooks/instances/${DEPLOYMENT_TYPE}.yml
popd

info_block "Bootstrapping ${DEPLOYMENT_TYPE} --- END"
