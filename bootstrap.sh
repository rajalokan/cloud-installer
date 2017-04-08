#!/usr/bin/env bash

bootstrap_ansible 2> /dev/null ||
    # if [[ ! -f /tmp/bootstrap-ansible.sh ]]; then
    #     # wget https://raw.githubusercontent.com/rajalokan/cloud-installer/master/scripts/scripts-library.sh -O /tmp/bootstrap-ansible.sh 2>/dev/null
    #     rm -rf /tmp/bootstrap-ansible.sh
    #     cp scripts/bootstrap-ansible.sh /tmp/bootstrap-ansible.sh
    # fi
    # source /tmp/bootstrap-ansible.sh
    source scripts/bootstrap-ansible.sh
    bootstrap_ansible

info_block "Start running playbook"
ansible -m ping localhost
