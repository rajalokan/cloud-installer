#!/usr/bin/env bash

## Shell Opts ----------------------------------------------------------------
# set -e -u -x

## Vars ----------------------------------------------------------------------
BASE_DIR="${BASE_DIR:-/opt}"
PROJECT_DIR="${BASE_DIR}/cloud-installer"

ANSIBLE_ROLE_FILE_TYPE="DEFAULT"
ANSIBLE_ROLE_FILE_DOTFILES="https://github.com/rajalokan/dotfiles"

# Default deployment is playbox setup.
DEPLOYMENT_TYPE="${1:-playbox}"

# Source library.sh if cloud-installer directory exists
if [[ -d ${PROJECT_DIR} ]]; then
    source ${PROJECT_DIR}/scripts/library.sh
fi

function source_library {
    if [[ ! -f /tmp/llibrary.sh ]]; then
        wget https://raw.githubusercontent.com/rajalokan/cloud-installer/scripts/master/library.sh -O /tmp/library.sh
    fi
    source /tmp/library.sh
    info_block "Bootstrapping ${DEPLOYMENT_TYPE} --- Start"
}

info_block "Bootstrapping ${DEPLOYMENT_TYPE} --- Start" 2> /dev/null ||
    source_library

sudo chown -R ${USER}:${USER} /opt


is_package_installed git || install_package git

if [[ ! -d /opt/cloud-installer ]]; then
    git clone https://github.com/rajalokan/cloud-installer.git ${PROJECT_DIR}
fi

# Check if ansible is installed, if not bootstrap ansible
ansible-playbook --help > /dev/null 2>&1 ||
    eval $(printf "%q\n" "${PROJECT_DIR}/scripts/bootstrap_ansible.sh")

# Run playbook
pushd "${PROJECT_DIR}/ansible"
    ansible-playbook -e deployment_type=${DEPLOYMENT_TYPE} playbooks/prepare.yml
    ansible-playbook playbooks/${DEPLOYMENT_TYPE}.yml
popd

info_block "Bootstrapping ${DEPLOYMENT_TYPE} --- END"
