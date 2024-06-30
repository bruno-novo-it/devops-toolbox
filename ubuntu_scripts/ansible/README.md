# Ansible scripts


## How to execute
Add the host infomation in the inventory.ini file, edit the playbook info, then execute:

```shell
export PLAYBOOK_NAME=ubuntu.yaml
ansible-playbook -i inventory.ini playbooks/${PLAYBOOK_NAME}  --ask-become-pass
```
