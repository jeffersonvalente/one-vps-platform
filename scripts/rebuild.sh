#!/usr/bin/env bash
# Full rebuild after reinstalling the OS via hPanel.
# Prereq: hosts.yml pointing to the public IP as root; vault.sops.yml decryptable (age key).
set -euo pipefail
cd "$(dirname "$0")/.."

echo "▶ 1/4 terraform (hostinger / cloudflare / tailscale / oci)"
for d in terraform/hostinger terraform/cloudflare terraform/tailscale terraform/oci; do
  (cd "$d" && terraform init -input=false >/dev/null && terraform apply -auto-approve -input=false)
done

echo "▶ 2/4 ansible base + tailscale"
(cd ansible && ansible-playbook playbooks/base.yml playbooks/tailscale.yml)

echo "   → now switch ansible_host to the Tailscale IP and ansible_user=ops in inventory/hosts.yml"
read -rp "   press Enter when ready..."

echo "▶ 3/4 ansible users + k3s + backup"
(cd ansible && ansible-playbook playbooks/users.yml playbooks/k3s.yml playbooks/backup.yml)

echo "▶ 4/4 argocd"
scripts/bootstrap-argocd.sh

echo "✅ rebuild complete. Remember: close 22/tcp in the Hostinger firewall."
