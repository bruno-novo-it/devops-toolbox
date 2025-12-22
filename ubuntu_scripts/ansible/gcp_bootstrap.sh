#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENV_FILE_DEFAULT="${SCRIPT_DIR}/gcp.env"

usage() {
  cat <<'EOF'
Usage:
  ./gcp_bootstrap.sh [--env ./gcp.env] [--apply-ansible]

This script bootstraps a GCP project + VM and prepares Ansible inventory.

Prereqs:
  - gcloud installed and authenticated: gcloud auth login
  - A billing account already exists in your Google Cloud account

IMPORTANT:
  - Project billing linking may require an interactive/manual step if your account policies restrict it.

Flags:
  --env <path>        Path to env file (default: ./gcp.env)
  --apply-ansible      Run ansible-playbook after provisioning
EOF
}

ENV_FILE="$ENV_FILE_DEFAULT"
APPLY_ANSIBLE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENV_FILE="$2"
      shift 2
      ;;
    --apply-ansible)
      APPLY_ANSIBLE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Env file not found: $ENV_FILE" >&2
  echo "Create it from gcp.env.example" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

required_vars=(
  GCP_PROJECT_ID
  GCP_PROJECT_NAME
  GCP_BILLING_ACCOUNT_ID
  GCP_REGION
  GCP_ZONE
  VM_NAME
  VM_MACHINE_TYPE
  VM_IMAGE_FAMILY
  VM_IMAGE_PROJECT
  VM_DISK_SIZE_GB
  VM_NETWORK_TAGS
  SSH_USERNAME
)

for v in "${required_vars[@]}"; do
  if [[ -z "${!v:-}" ]]; then
    echo "Missing required var: $v" >&2
    exit 1
  fi
done

if ! command -v gcloud >/dev/null 2>&1; then
  echo "gcloud not found. Install Google Cloud SDK first." >&2
  exit 1
fi

if ! gcloud auth list --filter=status:ACTIVE --format='value(account)' | head -n 1 | grep -q .; then
  echo "No active gcloud auth found. Run: gcloud auth login" >&2
  exit 1
fi

# Optional: tighten SSH exposure
ALLOW_SSH_CIDR="${ALLOW_SSH_CIDR:-0.0.0.0/0}"

# For this playbook, NAS mount and docker stacks should default off on a cloud VM.
ANSIBLE_ENABLE_NAS_MOUNT="${ANSIBLE_ENABLE_NAS_MOUNT:-false}"
ANSIBLE_ENABLE_DOCKER_STACKS="${ANSIBLE_ENABLE_DOCKER_STACKS:-false}"

# Determine SSH public key
SSH_PUBKEY_PATH="${SSH_PUBKEY_PATH:-$HOME/.ssh/id_ed25519.pub}"
if [[ ! -f "$SSH_PUBKEY_PATH" ]]; then
  SSH_PUBKEY_PATH="$HOME/.ssh/id_rsa.pub"
fi
if [[ ! -f "$SSH_PUBKEY_PATH" ]]; then
  echo "No SSH public key found. Set SSH_PUBKEY_PATH in env file." >&2
  exit 1
fi
SSH_PUBKEY_CONTENT="$(cat "$SSH_PUBKEY_PATH")"

TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

USERDATA_FILE="$TMPDIR/user-data.yaml"
cat >"$USERDATA_FILE" <<EOF
#cloud-config
users:
  - default
  - name: ${SSH_USERNAME}
    groups: [sudo]
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_authorized_keys:
      - ${SSH_PUBKEY_CONTENT}
package_update: false
package_upgrade: false
EOF

# Create project if needed
if ! gcloud projects describe "$GCP_PROJECT_ID" >/dev/null 2>&1; then
  echo "Creating project: $GCP_PROJECT_ID"
  gcloud projects create "$GCP_PROJECT_ID" --name="$GCP_PROJECT_NAME"
else
  echo "Project already exists: $GCP_PROJECT_ID"
fi

# Link billing
# Note: this may fail depending on org policies/permissions; user may need to do it in console.
set +e
BILLING_LINK_OUT=$(gcloud beta billing projects link "$GCP_PROJECT_ID" --billing-account="$GCP_BILLING_ACCOUNT_ID" 2>&1)
BILLING_LINK_RC=$?
set -e
if [[ $BILLING_LINK_RC -ne 0 ]]; then
  echo "Billing link did not succeed automatically. Output:" >&2
  echo "$BILLING_LINK_OUT" >&2
  echo "You may need to link billing manually in Cloud Console, then re-run this script." >&2
else
  echo "Billing linked."
fi

# Set active project
gcloud config set project "$GCP_PROJECT_ID" >/dev/null

# Enable required APIs
REQUIRED_APIS=(
  compute.googleapis.com
  iam.googleapis.com
  cloudresourcemanager.googleapis.com
)

echo "Enabling APIs..."
gcloud services enable "${REQUIRED_APIS[@]}" >/dev/null

# Create firewall rule (SSH)
FW_SSH_RULE="${FW_SSH_RULE:-allow-ssh-to-${VM_NAME}}"
if ! gcloud compute firewall-rules describe "$FW_SSH_RULE" >/dev/null 2>&1; then
  echo "Creating firewall rule: $FW_SSH_RULE (tcp:22 from $ALLOW_SSH_CIDR)"
  gcloud compute firewall-rules create "$FW_SSH_RULE" \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges="$ALLOW_SSH_CIDR" \
    --target-tags="$VM_NETWORK_TAGS" >/dev/null
else
  echo "Firewall rule already exists: $FW_SSH_RULE"
fi

# Optional: open web ports for docker stacks if you explicitly enable them
if [[ "$ANSIBLE_ENABLE_DOCKER_STACKS" == "true" ]]; then
  FW_WEB_RULE="${FW_WEB_RULE:-allow-web-to-${VM_NAME}}"
  if ! gcloud compute firewall-rules describe "$FW_WEB_RULE" >/dev/null 2>&1; then
    echo "Creating firewall rule: $FW_WEB_RULE (web ports)"
    gcloud compute firewall-rules create "$FW_WEB_RULE" \
      --direction=INGRESS \
      --priority=1000 \
      --network=default \
      --action=ALLOW \
      --rules=tcp:80,tcp:81,tcp:443,tcp:8080,tcp:5055,tcp:6767,tcp:7878,tcp:8989,tcp:9002,tcp:9091,tcp:9117,tcp:9696,tcp:8191,tcp:62609 \
      --source-ranges="${ALLOW_WEB_CIDR:-0.0.0.0/0}" \
      --target-tags="$VM_NETWORK_TAGS" >/dev/null
  else
    echo "Firewall rule already exists: $FW_WEB_RULE"
  fi
fi

# Create VM
if ! gcloud compute instances describe "$VM_NAME" --zone "$GCP_ZONE" >/dev/null 2>&1; then
  echo "Creating VM: $VM_NAME"
  gcloud compute instances create "$VM_NAME" \
    --zone "$GCP_ZONE" \
    --machine-type "$VM_MACHINE_TYPE" \
    --boot-disk-size "${VM_DISK_SIZE_GB}GB" \
    --image-family "$VM_IMAGE_FAMILY" \
    --image-project "$VM_IMAGE_PROJECT" \
    --tags "$VM_NETWORK_TAGS" \
    --metadata-from-file user-data="$USERDATA_FILE" \
    --scopes="https://www.googleapis.com/auth/cloud-platform" >/dev/null
else
  echo "VM already exists: $VM_NAME"
fi

# Fetch external IP
VM_IP="$(gcloud compute instances describe "$VM_NAME" --zone "$GCP_ZONE" --format='value(networkInterfaces[0].accessConfigs[0].natIP)')"
if [[ -z "$VM_IP" ]]; then
  echo "Failed to determine VM external IP." >&2
  exit 1
fi

echo "VM external IP: $VM_IP"

# Update inventory.ini
INVENTORY_FILE="${SCRIPT_DIR}/inventory.ini"
HOST_ALIAS="${INVENTORY_HOST_ALIAS:-${VM_NAME}}"

LINE_TO_ADD="${HOST_ALIAS} ansible_host=${VM_IP} ansible_user=${SSH_USERNAME} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python3"

if [[ -f "$INVENTORY_FILE" ]] && grep -qE "^${HOST_ALIAS} " "$INVENTORY_FILE"; then
  echo "Inventory already has host alias '${HOST_ALIAS}'. Not modifying inventory.ini."
else
  echo "Adding host to inventory.ini: ${HOST_ALIAS}"
  printf "\n%s\n" "$LINE_TO_ADD" >> "$INVENTORY_FILE"
fi

if [[ "$APPLY_ANSIBLE" == "true" ]]; then
  if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "ansible-playbook not found. Install Ansible, then re-run with --apply-ansible" >&2
    exit 1
  fi

  PLAYBOOK_NAME="${PLAYBOOK_NAME:-ubuntu.yaml}"
  echo "Running Ansible playbook: playbooks/${PLAYBOOK_NAME}"

  EXTRA_VARS=(
    "enable_nas_mount=${ANSIBLE_ENABLE_NAS_MOUNT}"
    "enable_docker_stacks=${ANSIBLE_ENABLE_DOCKER_STACKS}"
  )

  # tailscale_auth_key is optional. If set in env file, pass it.
  if [[ -n "${TAILSCALE_AUTH_KEY:-}" ]]; then
    EXTRA_VARS+=("tailscale_auth_key=${TAILSCALE_AUTH_KEY}")
  fi

  ansible-playbook -i "$INVENTORY_FILE" "${SCRIPT_DIR}/playbooks/${PLAYBOOK_NAME}" -e "${EXTRA_VARS[*]}"
fi

cat <<EOF

Done.

Next steps:
  - SSH: gcloud compute ssh ${SSH_USERNAME}@${VM_NAME} --zone ${GCP_ZONE}
  - Ansible:
      export PLAYBOOK_NAME=ubuntu.yaml
      ansible-playbook -i inventory.ini playbooks/${PLAYBOOK_NAME}

Notes:
  - By default NAS mount and docker stacks are disabled for cloud VMs.
  - To enable them, set ANSIBLE_ENABLE_NAS_MOUNT=true and/or ANSIBLE_ENABLE_DOCKER_STACKS=true in gcp.env
EOF
