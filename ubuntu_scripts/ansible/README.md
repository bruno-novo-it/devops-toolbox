# Ansible scripts

## How to execute

Add the host infomation in the inventory.ini file, edit the playbook info, then execute:

```sh
export PLAYBOOK_NAME=ubuntu.yaml
ansible-playbook -i inventory.ini playbooks/${PLAYBOOK_NAME}  --ask-become-pass
```

Need to create a .credentials file in order to use the NAS step, and populate with user/password informarion like this:

```sh
username=NAS_USERNAME
password=NAS_PASSWORD
```
