#!/usr/bin/env bash

# This script should be executed from the root directory of the cloned repo
cd "$(dirname "${0}")/.."

instance_name=$1

PLAYBOOK_PATH="playbooks/${instance_name}.yml"

source /opt/ansible-runtime/bin/activate

pushd ansible
    ansible-playbook ${PLAYBOOK_PATH}
popd
