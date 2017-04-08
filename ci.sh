#!/usr/bin/env bash

if [[ $# < 2 ]]; then
    echo "Provide more that two intput"
    exit 0
fi

DEPLOYMENT_ACTION=${1:-}
DEPLOYMENT_INSTNACE=${2:-}

VAULT_OPTIONS="--vault-password-file ~/.vault_password"

pushd "ansible"
    ansible-playbook -e instance_name=${DEPLOYMENT_INSTNACE} ${VAULT_OPTIONS} --tags=${DEPLOYMENT_ACTION} playbooks/boot/boot.yml
popd
