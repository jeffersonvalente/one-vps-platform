# Configure for your installation

Everything that differs per installation is a `YOUR_*` placeholder or a `*.example` file. Nothing
else needs editing to get a working platform. Run `scripts/check-placeholders.sh` at any time; it
lists what is still unset.

## 1. Copy the example files

```bash
cp terraform/hostinger/terraform.tfvars.example  terraform/hostinger/terraform.tfvars
cp terraform/cloudflare/terraform.tfvars.example terraform/cloudflare/terraform.tfvars
cp ansible/inventory/hosts.yml.example           ansible/inventory/hosts.yml
cp ansible/inventory/group_vars/all/vault.sops.yml.example ansible/inventory/group_vars/all/vault.sops.yml
```

`terraform.tfvars`, `hosts.yml` and the decrypted vault are git-ignored. The encrypted
`vault.sops.yml` is meant to be committed.

## 2. Fill in the placeholders

| Placeholder | Where | What it is |
|---|---|---|
| `YOUR_DOMAIN.example` | `ansible/.../vars.yml`, `k8s/apps/**`, `terraform/*/terraform.tfvars` | Your apex domain in Cloudflare (e.g. `example.com`). Private hosts become `<name>.lab.<domain>`. |
| `YOUR_EMAIL` | `vars.yml`, `k8s/apps/cert-manager/cluster-issuer.yaml` | Git identity for the `personal` user and the Let's Encrypt account contact. |
| `YOUR_CLIENT_A_EMAIL`, `YOUR_CLIENT_B_EMAIL` | `vars.yml` | Git identity per tenant. |
| `YOUR_GITHUB_USER`, `YOUR_CLIENT_*_GITHUB_USER` | `vars.yml`, `k8s/bootstrap/argocd/root-app.yaml`, `k8s/apps/*.yaml`, `scripts/bootstrap-argocd.sh` | GitHub accounts. The repo URL in ArgoCD must point at **your fork**. |
| `YOUR_VPS_ID` | `terraform/hostinger/terraform.tfvars` | Provider's ID of the VPS (for `terraform import`). |
| `YOUR_VPS_PUBLIC_IP` | `ansible/inventory/hosts.yml` | Only for the bootstrap phase; replaced by the Tailscale IP afterwards. |
| `YOUR_VPS_TAILSCALE_IP` | `terraform/cloudflare/terraform.tfvars`, `hosts.yml` | Printed by `playbooks/tailscale.yml`. |
| `YOUR_CLOUDFLARE_ZONE_ID` | `terraform/cloudflare/terraform.tfvars` | Cloudflare dashboard → zone → Overview → API. |
| `age1REPLACE_WITH_YOUR_PUBLIC_KEY` | `.sops.yaml` | `age-keygen -o ~/.config/sops/age/keys.txt`, paste the public part. |
| `<your-tfstate-bucket>` | `terraform/*/versions.tf` (commented) | Optional remote state. Local state works. |

Users are defined once, in `ansible/inventory/group_vars/all/vars.yml` (`work_users`). Rename
`client-a`/`client-b`, add or remove tenants there; every playbook loops over that list.

## 3. Secrets (never plain text)

```bash
sops ansible/inventory/group_vars/all/vault.sops.yml
```

| Key | Source |
|---|---|
| `tailscale_authkey` | `terraform -chdir=terraform/tailscale output -raw server_authkey` |
| `cloudflare_api_token` | Cloudflare → My Profile → API Tokens → "Edit zone DNS" scoped to your zone |
| `restic_repository`, `restic_password`, `aws_*` | `terraform -chdir=terraform/oci output -raw restic_repository`, a random password, an S3-compatible key pair |

## 4. Verify

```bash
scripts/check-placeholders.sh      # exits 1 while any YOUR_* remains in tracked files
```
