# Inventory (template)

> IDs and names only. **No secrets**: those live in `*.sops.yml`.

## VPS
| Field | Value |
|---|---|
| Provider / plan | Hostinger KVM 4 (4 vCPU · 16 GB · 200 GB NVMe), any KVM VPS works |
| Region | closest to you |
| VPS ID | `YOUR_VPS_ID` |
| Public IP | `203.0.113.10` (used only during bootstrap) |
| Tailscale IP | `100.64.0.10` |
| Hostname | `vps.lab.example.com` (resolves to the Tailscale IP) |
| OS | Ubuntu LTS |

## DNS (Cloudflare, public zone, private targets)
| Name | Type | Target | Proxy |
|---|---|---|---|
| `lab.example.com` | A | Tailscale IP | no |
| `*.lab.example.com` | A | Tailscale IP | no |

Records point at a 100.x address: public DNS, unreachable targets. They exist so cert-manager can pass
DNS-01 and the hosts have names.

## Users
| User | Role | GitHub |
|---|---|---|
| `ops` | admin (sudo), never works | none |
| `personal` | lab owner, kubeconfig | your personal account |
| `client-a` | workspace + rootless Docker | your client-A account |
| `client-b` | workspace | your client-B account |

## Backup
| Target | Bucket |
|---|---|
| S3-compatible object storage (OCI Always Free in the original) | `onevps-backup` |
