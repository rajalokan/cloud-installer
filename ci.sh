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
        ansible-playbook -e deployment_type=${DEPLOYMENT_INSTNACE} playbooks/prepare.yml
        if [[ $# > 2 ]]; then
            ansible-playbook --tags $3 playbooks/instances/${DEPLOYMENT_INSTNACE}.yml
        else
            ansible-playbook playbooks/instances/${DEPLOYMENT_INSTNACE}.yml
        fi
    popd
else
    # Launches VM and then runs playbooks on remote hosts under tmux session `bootstrap`
    TAGS_OPTIONS=""
    if [[ ${DEPLOYMENT_INSTNACE} == "blankbox" ]]; then
        TAGS_OPTIONS="--tags blankbox"
    fi
    pushd "ansible"
        ansible-playbook ${TAGS_OPTIONS} -e instance_name=${DEPLOYMENT_INSTNACE} ${VAULT_OPTIONS} playbooks/management/${DEPLOYMENT_ACTION}.yml
    popd
fi
