#!/usr/bin/env bash

if [[ $# < 2 ]]; then
    echo "Provide more that two intput"
    exit 0
fi

DEPLOYMENT_ACTION=${1:-}
DEPLOYMENT_INSTNACE=${2:-}

VAULT_OPTIONS="--vault-password-file ~/.vault_password"

if [[ "${DEPLOYMENT_ACTION}" == 'provision' ]]; then
    # Will run playbook locally on remote host
    pushd "ansible"
        ansible-playbook playbooks/${DEPLOYMENT_INSTNACE}.yml
    popd
else
    # Launches VM and then runs playbooks on remote hosts under tmux session `bootstrap`
    pushd "ansible"
        ansible-playbook -e instance_name=${DEPLOYMENT_INSTNACE} ${VAULT_OPTIONS} playbooks/openstack/${DEPLOYMENT_ACTION}.yml
    popd
fi
