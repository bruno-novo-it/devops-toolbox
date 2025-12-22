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

## GCP VM bootstrap (project + VM + firewall)

From this folder:

```sh
cp gcp.env.example gcp.env
```

Edit `gcp.env` and set:

- **`GCP_PROJECT_ID`** (must be globally unique)
- **`GCP_BILLING_ACCOUNT_ID`**
- **`GCP_ZONE`** / **`GCP_REGION`**

Then run:

```sh
./gcp_bootstrap.sh
```

Optional (provision the VM immediately with Ansible):

```sh
./gcp_bootstrap.sh --apply-ansible
```
