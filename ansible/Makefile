
boot_playbox:
	ansible-playbook -e action="boot" playbox.yml
provision_playbox:
	ansible-playbook -e
delete_playbox:
	ansible-playbook -e action="delete" playbox.yml


boot_keystone:
	ansible-playbook -e action="boot" keystone.yml
delete_keystone:
	ansible-playbook -e action="delete" keystone.yml


boot_ney11:
	ansible-playbook -e instance_name="ney11" --vault-password-file ~/.vault_password --tags "boot" boot.yml
provision_ney11:
	ansible-playbook -e instance_name="ney11" --vault-password-file ~/.vault_password --tags "provision" boot.yml
delete_ney11:
	ansible-playbook -e instance_name="ney11" delete.yml


fetch_ansible_roles:
	ansible-galaxy install -r requirements.yml -p roles/
