# Architecture & runbook

Long-form companion to the [README](../README.md): the problem in detail, every design choice with its reason, the memory budget, daily use and operational notes.

## The problem

I do platform/DevOps work for two separate clients plus my own projects, all from one Windows PC.
That meant:

- **Everything competed for the same 32 GB.** WSL2 is capped at 50 % of host RAM, Docker Desktop idled at
  ~8 GB, and a game or a browser pushed the machine to 79 % before I opened a single lab.
- **Credentials and identities lived side by side.** Three GitHub accounts on one `gh` login; a wrong
  `git push` was one typo away. Client data separated by discipline, not by design.
- **Nothing was reachable away from the desk.** No laptop, no phone, no "check the lab from the train".
- **No reproducibility.** The setup lived in my head and in `%AppData%`.

Constraints: no new hardware, a single cheap VPS (16 GB), **no public attack surface**, and a client's
data must never sit next to another client's.

## The solution

| Layer | Choice | Why |
|---|---|---|
| **Network** | Tailscale; VPS firewall default-deny, only UDP 41641 optional | The server is an intranet node, not a website. SSH, API server and ingress listen on the tailnet interface only. |
| **TLS without exposure** | cert-manager + Let's Encrypt **DNS-01** via Cloudflare | Valid certificates for hosts nobody on the internet can reach. |
| **Tenant isolation** | One Linux user per client, home `0700`, no sudo, own `gh`/git identity | Impossible to commit as the wrong company. Workspace ≠ environment: no client service runs here as production. |
| **Containers for one tenant** | Docker **rootless**, scoped to a single user; root daemon masked | A client's `docker compose` dev stack without touching the cluster or the other tenants. |
| **Orchestration** | k3s single-node (`--disable traefik,servicelb`), ingress-nginx, `local-path` | CNCF-conformant Kubernetes, ~1 GB overhead, portable charts. |
| **Delivery** | ArgoCD **core** (no UI) + app-of-apps from `k8s/apps/` | Everything in the cluster is a commit. UI on demand via `argocd admin dashboard`. |
| **Observability** | SigNoz, shared; tenants separated by `service.name` / `deployment.environment`; per-tenant service accounts (viewer for runtime, editor for automation) | One ClickHouse, many senders, least privilege per key. |
| **Secrets** | SOPS + age; `.example` files versioned, real vault encrypted | Nothing in plain text, ever. |
| **Provisioning** | Terraform (VPS import, DNS, Tailscale ACL, backup bucket) · Ansible (host, users, k3s, docker, backup) | `scripts/rebuild.sh` = Terraform → Ansible → ArgoCD bootstrap. |

Detailed decisions live in [`docs/decisions/`](docs/decisions/) as short ADRs.

## The result

- **PC freed.** Work moved off the desktop entirely; the PC went from 79 % RAM to 60 % *with a AAA game
  running* and the Claude Code session still alive on the server.
- **Server headroom.** 19 % RAM idle with the full stack; **44 %** under a real load test
  (14-service OpenTelemetry demo shop + SigNoz + k3s + client app).
- **Zero public surface.** `nmap` from the internet sees nothing but a UDP port that does not answer.
- **Three identities, no leaks.** Each client's code, credentials and Claude Code context live in a home
  nobody else on the box can read.
- **Reproducible.** Fresh OS → `scripts/rebuild.sh` → working platform in ~30 min.
- **One incident, documented.** A load test OOM-killed SigNoz's ZooKeeper (limits sized for an idle lab);
  35 minutes of lost ingestion, root cause found, limits fixed, postmortem in
  [`docs/decisions/0004-incident-signoz-zookeeper-oom.md`](docs/decisions/0004-incident-signoz-zookeeper-oom.md).

## Repository layout

```
terraform/      hostinger (import only, destroy cancels the subscription!) · cloudflare · tailscale · oci
ansible/        base · tailscale · users · k3s · docker-rootless · backup   (site.yml runs all)
k8s/            bootstrap/argocd (core + app-of-apps) · apps/ (ingress-nginx, cert-manager, signoz)
scripts/        bootstrap-argocd.sh · rebuild.sh
docs/           decisions/ (ADRs + postmortem) · inventory template · ssh_config example
```

## Runbook (abridged)

1. **Provider**: fresh Ubuntu LTS, SSH key, firewall `22/tcp` only (temporary), snapshot.
2. `terraform/`, import the VPS (`terraform import hostinger_vps.lab <ID>`), apply DNS, Tailscale ACL, bucket.
3. `ansible-playbook playbooks/base.yml playbooks/tailscale.yml` → note the 100.x IP → switch inventory
   to it → **close 22/tcp at the provider** → `tailscale.yml -e close_public_ssh=true`.
4. `users.yml` · `k3s.yml` · `docker-rootless.yml` · `backup.yml`.
5. `scripts/bootstrap-argocd.sh`, apps sync from Git.
6. Open SigNoz, **create the admin account first** (without an org the collector never opens its
   receivers), then invite tenants / create service accounts.

Full procedure, memory budget, SigNoz quirks and the reboot checklist are in the sections below.

## Memory budget (16 GB)

| Component | Reserve |
|---|---|
| OS + sshd + tailscale | ~0.7 GB |
| k3s server | ~1.0 GB |
| ingress-nginx + cert-manager + ArgoCD core | ~0.8 GB |
| SigNoz (ClickHouse 3 GB · ZooKeeper 1 GB · collector/UI) | ~5.5 GB |
| Rootless Docker dev stack (one tenant) | ~3.5 GB |
| **Headroom for workspaces (Claude Code, builds)** | **~4 GB** (+ 4 GB swap) |

## Daily use

VS Code **Remote-SSH**, one window per tenant (`docs/client/ssh_config.example`). Terminal, Claude Code,
git and docker all execute on the VPS; the laptop only draws pixels. For sessions that must survive a
dropped connection: `cc` (= `tmux new -As claude`).

## Operational notes

**Reboot** (kernel updates): tenants' services run as `systemd --user` with linger, so they return by
themselves. Still, announce it. `cat /var/run/reboot-required.pkgs` → `sudo reboot` → verify
`kubectl get nodes` and `systemctl --user` units.

**SigNoz**
- No admin account → no org → the otel-collector gets `cannot create agent without orgId` over OpAMP
  and **opens no receivers** (OTLP returns 502 through ingress). Create the account right after first sync.
- Some buttons in the 0.135 UI don't respond (overlay bug). Open the action by URL:
  `/settings/members?invite=true`, `/settings/service-accounts?create-sa=true`,
  `/settings/service-accounts?account=<id>&tab=keys&add-key=true`.
- "OTLP answers 200" ≠ "data stored". Check `kubectl -n signoz logs deploy/signoz-otel-collector | grep -c "Exporting failed"`
  and `RESTARTS` on the storage pods before blaming the sender.

## License

MIT. Use it, fork it, send a PR if you make it better.
