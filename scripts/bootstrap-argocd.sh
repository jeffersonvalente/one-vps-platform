#!/usr/bin/env bash
# Phase 4b, installs ArgoCD core and the root app. Runs on the VPS as personal (has kubeconfig)
# or from any machine on the tailnet with the kubeconfig pointing to the 100.x.
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl get ns argocd >/dev/null 2>&1 || kubectl create ns argocd
kubectl apply --server-side --force-conflicts -k k8s/bootstrap/argocd  # CRDs too large for client-side

echo "⏳ waiting for CRDs and controllers..."
kubectl wait --for=condition=Established crd/applications.argoproj.io --timeout=120s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=180s
kubectl -n argocd rollout status deploy/argocd-repo-server --timeout=180s

# Repo is private: ArgoCD needs a read credential.
# Create a fine-grained PAT (Contents: read) on the YOUR_GITHUB_USER account and export GITHUB_TOKEN.
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  kubectl -n argocd create secret generic repo-one-vps-platform \
    --from-literal=type=git \
    --from-literal=url=https://github.com/YOUR_GITHUB_USER/one-vps-platform.git \
    --from-literal=username=YOUR_GITHUB_USER \
    --from-literal=password="$GITHUB_TOKEN" \
    --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n argocd label secret repo-one-vps-platform argocd.argoproj.io/secret-type=repository --overwrite
else
  echo "⚠️  GITHUB_TOKEN not set, the root app will not be able to read the private repo."
fi

kubectl apply -f k8s/bootstrap/argocd/project-default.yaml
kubectl apply -f k8s/bootstrap/argocd/root-app.yaml

echo "✅ ArgoCD core is up. Apps: kubectl -n argocd get applications"
echo "   UI on demand: argocd admin dashboard -n argocd"
