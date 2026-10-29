# ADR 0003, One Linux user per tenant

**Status:** accepted

## Context
Code, credentials and commit identity for two unrelated clients plus personal work. On the PC the
separation was a matter of discipline; a wrong `gh auth switch` away from a leak.

## Decision
Linux users `client-a`, `client-b`, `personal` (+ `ops` as admin). Each has:
- its own SSH key, `gh auth` on the right account, `.gitconfig` with the company name/e-mail;
- `~/.claude`, `~/.kube` (only where allowed), tmux and repos in a `0700` home;
- **no sudo** (except `ops`). Only `personal` holds the k3s kubeconfig.

Where a tenant needs containers for development, it gets **rootless Docker** scoped to that user
(own daemon, subuid/subgid range, `systemctl --user`, linger). The root Docker daemon is masked.

No client service runs on this box as production. The server is a **workspace**, not an environment.

## Consequences
- Physically impossible to commit with the wrong identity.
- A clean answer to "where does my company's data sit?": isolated user, encrypted disk, behind a
  mesh VPN, nothing served publicly.
- Everything that touches the cluster goes through `personal` (or the platform owner), by design.
