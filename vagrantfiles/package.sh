#!/usr/bin/env bash

[[ $# < 1 ]] && echo "not enough params" && exit 0

# Uncomment while debugging
# set -o xtrace

BOXNAME=${1:-}

case ${BOXNAME} in
  trusty | xenial | centos)
    ;;
  *)
    echo "Invalid box type. Please retry again"
    exit 0
    ;;
esac


BOXFILE_PATH="${HOME}/opt/vagrantboxes/rajalokan_${BOXNAME}.box"
REGISTRY_NAME="rajalokan/${BOXNAME}"

trap err_trap ERR
function err_trap {
  echo "Running ${0##*/} failed. Exiting ..."
  exit 0
}

# Work on baseboxes
pushd 'baseboxes' >/dev/null
# Check status
VM_STATUS=$(vagrant status ${BOXNAME} --machine-readable | grep ",state," | cut -d',' -f4)
[[ -z ${VM_STATUS} ]] && { echo "Invalid VM status. Please check your vagrantfile. Exiting..."; exit 0; } || echo "VM status is ${VM_STATUS}"

# `vagrant destroy` if VM is `running` or `poweroff` and then `vagrant up --provision`
if [[ "${VM_STATUS}" == "running" ]] || [[ "${VM_STATUS}" == "poweroff" ]]; then
  echo "Virtual Machine ${BOXNAME} is either running or poweroff. Destroying ${BOXNAME} ..."
  vagrant destroy -f ${BOXNAME}

  echo "Booting ${BOXNAME}"
  vagrant up ${BOXNAME} --provision
# straight away `vagrant up --provision` if vm is not created
elif [[ "${VM_STATUS}" == "not_created" ]]; then
  echo "Virtual Machine ${BOXNAME} is not created. Booting ${BOXNAME}"
  vagrant up ${BOXNAME} --provision
fi

# Delete any existing old rajalokan-${BOXNAME}.box in vagrantboxes/ path
[[ -f ${BOXFILE_PATH} ]] && { echo "Deleting old box file ${BOXFILE_PATH}"; rm -rf ${BOXFILE_PATH}; }

# Pacakge current running box
vagrant package --output ${BOXFILE_PATH} ${BOXNAME}
# Come out of baseboxes
popd >/dev/null

# Delete box rajalokan/${BOXNAME} if present in vagrant registry
( vagrant box list --machine-readable | grep ${REGISTRY_NAME} > /dev/null ) && { echo "Deleting box ${REGISTRY_NAME} from vagrant list"; vagrant box remove -f ${REGISTRY_NAME}; }

# Add box to vagrant registry
vagrant box add ${REGISTRY_NAME} ${BOXFILE_PATH}

pushd 'playboxes' >/dev/null
vagrant status
vagrant up ${BOXNAME}
popd >/dev/null
