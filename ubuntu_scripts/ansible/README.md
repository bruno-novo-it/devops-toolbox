# Ansible scripts

## How to execute

Add the host infomation in the inventory.ini file, edit the playbook info, then execute:

```sh
export PLAYBOOK_NAME=ubuntu.yaml
ansible-playbook -i inventory.ini playbooks/${PLAYBOOK_NAME}  --ask-become-pass
```

### Using the helper script with .env (recommended)

1. Create your `.env` from the example:

```sh
cp .env.example .env
```

2. Edit `.env` and set at least `TAILSCALE_AUTH_KEY`.

3. Run:

```sh
./run-playbook.sh
```

This script loads `.env`, uses `PLAYBOOK_NAME` (default is `ubuntu.yaml`), and executes `ansible-playbook` with the same variables you were passing manually.

Need to create a .credentials file in order to use the NAS step, and populate with user/password informarion like this:

```sh
username=NAS_USERNAME
password=NAS_PASSWORD
```

## Avoid typing password every time

You have 3 options:

1. Best practice: configure passwordless sudo (`NOPASSWD`) for the remote user only for the needed commands or for your automation context.
2. Keep password prompts: default behavior from `./run-playbook.sh` when `ANSIBLE_BECOME_PASS` is not set.
3. Store become password in `.env` as `ANSIBLE_BECOME_PASS` (less secure, but avoids prompt).

If you use option 3, make sure `.env` is not committed to git.
