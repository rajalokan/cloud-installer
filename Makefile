#!/bin/bash

load:
	pew ls | grep -e 'bmc' 2>&1 >/dev/null && pew workon bmc || pew new bmc

install:
	pip install -r requirements.txt

boot_okanbox:
	currdir=`pwd`
	cd ansible \
		&& ansible-playbook playbooks/okanbox.yml
	cd ${currdir}
