# ADR 0002 — k3s single-node + ArgoCD core

**Status:** accepted

## Decision
- **k3s** (CNCF-conformant Kubernetes distribution) with `--disable traefik,servicelb`. ingress-nginx and
  cert-manager are installed via Helm/ArgoCD so the charts stay portable to any managed Kubernetes.
  Storage: `local-path` — one node, NVMe; a distributed storage layer would be waste.
- **ArgoCD core** (no UI/Dex/notifications, ~300 MB) rather than the full install (~1 GB) or Flux.
  It is the GitOps model I already operate daily; the UI is available on demand via
  `argocd admin dashboard`.
- kubeadm/Talos rejected: zero gain on a single node, extra RAM and upkeep.

## Consequences
- Everything in the cluster enters through a commit in `k8s/apps/`.
- Sync-waves: ingress-nginx (0) → cert-manager (1) → signoz (2) → tenant apps (3).
