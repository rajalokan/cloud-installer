#!/usr/bin/env bash

[[ $# < 1 ]] && echo "not enough params" && exit 0

BOXNAME=${1:-}
BOXFILE_PATH="${HOME}/opt/vagrantboxes/rajalokan_${BOXNAME}.box"
REG_NAME="rajalokan/${BOXNAME}"

# Ensure ansible is installed
type ansible >/dev/null 2>&1 || { echo "Please ensure that ansible is installed. Aborting.."; exit 1; }

# Check status
VM_STATUS=$(vagrant status ${BOXNAME} --machine-readable | grep ",state," | cut -d',' -f4)

# `vagrant destroy` if VM is `running` or `poweroff`
([[ "${VM_STATUS}" == "running" ]] || [[ "${VM_STATUS}" == "poweroff" ]]) && { echo "Destroying ${BOXNAME}"; vagrant destroy -f ${BOXNAME}; }

# `vagrant up` with provision if VM is `not_created`
[[ "${VM_STATUS}" == "not_created" ]] && { echo "Booting ${BOXNAME}"; vagrant up ${BOXNAME} --provision; }

# # Delete any existing old rajalokan-${BOXNAME}.box in vagrantboxes/ path
[[ -f ${BOXFILE_PATH} ]] && { echo "Deleting old box file ${BOXFILE_PATH}"; rm -rf ${BOXFILE_PATH}; }

# Pacakge current running box
vagrant package --output ${BOXFILE_PATH} ${BOXNAME}

# Delete box rajalokan/${BOXNAME} if present in vagrant registry
( vagrant box list --machine-readable | grep ${REG_NAME} > /dev/null ) && { echo "Deleting box ${REG_NAME} from vagrant list"; vagrant box remove -f ${REG_NAME}; }

# Add box to vagrant registry
vagrant box add ${REG_NAME} ${BOXFILE_PATH}
