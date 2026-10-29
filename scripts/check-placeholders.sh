#!/usr/bin/env bash
# Lists every per-installation placeholder still present in files that get applied.
# Exit 1 if any remain. Docs and *.example files are expected to keep placeholders and are skipped.
set -euo pipefail
cd "$(dirname "$0")/.."

pattern='YOUR_[A-Z_]+|age1REPLACE_WITH_YOUR_PUBLIC_KEY|<your-[a-z-]+>'

hits=$(grep -rnE "$pattern" \
  terraform ansible k8s scripts .sops.yaml \
  --exclude='*.example' --exclude='*.md' --exclude='check-placeholders.sh' \
  --exclude-dir=.terraform 2>/dev/null || true)

if [[ -z "$hits" ]]; then
  echo "ok: no placeholders left in applied files"
  exit 0
fi

echo "placeholders still set (see docs/CONFIGURE.md):"
echo "$hits" | sed 's/^/  /'
exit 1
