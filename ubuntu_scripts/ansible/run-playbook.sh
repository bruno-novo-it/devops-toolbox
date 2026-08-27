#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENV_FILE="${SCRIPT_DIR}/.env"
if [[ -f "${ENV_FILE}" ]]; then
  # Export variables from .env so ansible-playbook can consume them.
  set -a
  # shellcheck source=/dev/null
  source "${ENV_FILE}"
  set +a
fi

PLAYBOOK_NAME="${PLAYBOOK_NAME:-ubuntu.yaml}"
TAILSCALE_AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"
TAILSCALE_ADVERTISE_EXIT_NODE="${TAILSCALE_ADVERTISE_EXIT_NODE:-false}"
ANSIBLE_DEPRECATION_WARNINGS="${ANSIBLE_DEPRECATION_WARNINGS:-False}"

if [[ -z "${TAILSCALE_AUTH_KEY}" ]]; then
  echo "Error: TAILSCALE_AUTH_KEY is empty. Set it in ansible/.env or in your environment."
  exit 1
fi

cmd=(
  ansible-playbook
  -v
  -i "${SCRIPT_DIR}/inventory.ini"
  "${SCRIPT_DIR}/playbooks/${PLAYBOOK_NAME}"
  -e "ansible_deprecation_warnings=${ANSIBLE_DEPRECATION_WARNINGS}"
  -e "tailscale_auth_key=${TAILSCALE_AUTH_KEY}"
  -e "tailscale_advertise_exit_node=${TAILSCALE_ADVERTISE_EXIT_NODE}"
)

if [[ -n "${ANSIBLE_BECOME_PASS:-}" ]]; then
  cmd+=( -e "ansible_become_password=${ANSIBLE_BECOME_PASS}" )
else
  cmd+=( --ask-become-pass )
fi

"${cmd[@]}"
