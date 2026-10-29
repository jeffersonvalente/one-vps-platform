# Inventory (template)

Copy this file, fill in your values, keep it **out of Git** if you prefer (it holds no secrets, only IDs).
Everything marked `YOUR_*` is specific to your installation; `scripts/check-placeholders.sh` lists what is still unset.

## VPS
| Field | Value |
|---|---|
| Provider / plan | any KVM VPS with ~16 GB (the original: Hostinger KVM 4) |
| Region | `YOUR_REGION` |
| VPS ID | `YOUR_VPS_ID` (needed for the Terraform import) |
| Public IP | `YOUR_VPS_PUBLIC_IP` (used only during bootstrap) |
| Tailscale IP | `YOUR_VPS_TAILSCALE_IP` (100.x.y.z, printed by `playbooks/tailscale.yml`) |
| Hostname | `vps.lab.YOUR_DOMAIN` (resolves to the Tailscale IP) |
| OS | Ubuntu LTS |

## DNS (Cloudflare: public zone, private targets)
| Name | Type | Target | Proxy |
|---|---|---|---|
| `lab.YOUR_DOMAIN` | A | Tailscale IP | no |
| `*.lab.YOUR_DOMAIN` | A | Tailscale IP | no |

The records point at a 100.x address: public DNS, unreachable targets. They exist so cert-manager can
pass DNS-01 and the hosts have names.

## Users
| User | Role | GitHub |
|---|---|---|
| `ops` | admin (sudo), never works | none |
| `personal` | lab owner, kubeconfig | `YOUR_GITHUB_USER` |
| `client-a` | workspace + rootless Docker | `YOUR_CLIENT_A_GITHUB_USER` |
| `client-b` | workspace | `YOUR_CLIENT_B_GITHUB_USER` |

## Backup
| Target | Bucket |
|---|---|
| S3-compatible object storage (OCI Always Free in the original) | `YOUR_BACKUP_BUCKET` |
