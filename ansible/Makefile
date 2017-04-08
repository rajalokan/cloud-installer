
boot_playbox:
	cd ansible && ansible-playbook -e instance_name="playbox"  --vault-password-file ~/.vault_password --tags="boot" playbooks/boot.yml
provision_playbox:
	ansible-playbook -e instance_name="playbox" --vault-password-file ~/.vault_password --tags="provision" boot.yml
delete_playbox:
	ansible-playbook -e instance_name="playbox" delete.yml


boot_keystone:
	ansible-playbook -e instance_name="keystone" --vault-password-file ~/.vault_password --tags="boot" boot.yml
provision_keystone:
	ansible-playbook -e instance_name="keystone" --vault-password-file ~/.vault_password --tags "provision" boot.yml
delete_keystone:
	ansible-playbook -e instance_name="keystone" delete.yml


boot_ney11:
	ansible-playbook -e instance_name="ney11" --vault-password-file ~/.vault_password --tags "boot" boot.yml
provision_ney11:
	ansible-playbook -e instance_name="ney11" --vault-password-file ~/.vault_password --tags "provision" boot.yml
delete_ney11:
	ansible-playbook -e instance_name="ney11" delete.yml



boot_newton:
	ansible-playbook -e instance_name="newton" --vault-password-file ~/.vault_password --tags "boot" boot.yml
provision_newton:
	ansible-playbook -e instance_name="newton" --vault-password-file ~/.vault_password --tags "provision" boot.yml
delete_newton:
	ansible-playbook -e instance_name="newton" delete.yml


fetch_ansible_roles:
	ansible-galaxy install -r requirements.yml -p roles/
