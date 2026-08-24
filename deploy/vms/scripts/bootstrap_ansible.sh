#!/usr/bin/env bash
# Builds an Ansible inventory from the vms module's terraform outputs and runs a playbook.
# Invoked by terragrunt as an after_hook on `apply`, from the module's working directory.
set -euo pipefail

playbook="$1"
ssh_private_key_path="$2"
admin_username="$3"

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ansible-playbook not found on PATH, skipping bootstrap" >&2
  exit 0
fi

inventory_file="$(mktemp)"
trap 'rm -f "$inventory_file"' EXIT

echo "[vms]" > "$inventory_file"
terraform output -json public_ips | jq -r --arg user "$admin_username" --arg key "$ssh_private_key_path" \
  'to_entries[] | "\(.key) ansible_host=\(.value) ansible_user=\($user) ansible_ssh_private_key_file=\($key) ansible_ssh_common_args=\u0027-o StrictHostKeyChecking=no\u0027"' \
  >> "$inventory_file"

echo "Running ansible-playbook ${playbook} against:"
cat "$inventory_file"

ansible-playbook -i "$inventory_file" "$playbook"
