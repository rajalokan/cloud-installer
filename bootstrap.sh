#!/usr/bin/env bash

if [[ $# < 1 ]]; then
    echo "You must provide at least one instance to bootstrap"
    exit 0
fi

INSTANCE=${1:-}

ansible_bin="ansible-playbook"

vault_options="--vault-password-file ~/.vault_password"
var_options="-e instance_name=${INSTANCE}"

boot_playbook_path="playbooks/management/boot.yml"
instance_playbook_path="playbooks/instances/${INSTANCE}.yml"

function validate_dev_run {
    #statements
    echo "validate_dev_run"
}

case "${INSTANCE}" in
    jumpbox )
        if [[ "${HOSTNAME}" != 'leo' ]]; then echo "Bootstrapping jumpbox only from local laptop"; fi
        pushd "ansible"
            ${ansible_bin} ${var_options} --tags jumpbox ${vault_options} ${boot_playbook_path}
        popd
        ;;
    stegen )
        pushd "ansible"
            ${ansible_bin} ${var_options} --tags stegen ${vault_options} ${boot_playbook_path}
        popd
        ;;
    playbox|keystone|guts )
        echo "inside rest"
        ;;
    *)
        echo "Invalid option"
        ;;
esac
