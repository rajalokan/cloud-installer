#!/usr/bin/env bash
if [[ $# < 1 ]]; then
    echo "You must provide at least one instance to delete"
    exit 0
fi

INSTANCE=${1:-}

ansible_bin="ansible-playbook"

var_options="-e instance_name=${INSTANCE}"

delete_playbook_path="playbooks/management/delete.yml"

# TODO: Must run from local laptop
case "${INSTANCE}" in
    jumpbox|stegen )
        pushd "ansible"
            ${ansible_bin} ${var_options} ${delete_playbook_path}
        popd
        ;;
    playbox|keystone|guts )
        echo "deleting rest"
        ;;
    * )
        echo "Invalide option for deletion"
        ;;
esac
