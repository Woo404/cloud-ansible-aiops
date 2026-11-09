#!/usr/bin/env bash
# Run the same checks CI runs (best-effort locally).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> yamllint"
yamllint -c .yamllint ansible monitoring .github || yamllint ansible monitoring .github

echo "==> ansible-lint"
(cd ansible && ansible-lint playbooks/*.yml roles/*)

if command -v terraform >/dev/null 2>&1; then
  echo "==> terraform fmt -check"
  terraform fmt -check -recursive terraform
  for d in terraform/aliyun terraform/aws; do
    echo "==> terraform validate ($d) — init without providers if offline may fail"
    (cd "$d" && terraform init -backend=false -input=false >/dev/null && terraform validate) || \
      echo "NOTE: validate skipped/failed for $d (providers may be unavailable offline)"
  done
else
  echo "NOTE: terraform not installed; skipped fmt/validate"
fi

echo "==> markdown basic check (no empty runbooks)"
for f in runbooks/*.md docs/*.md README.md TUTORIAL_CN.md; do
  [[ -s "$f" ]] || { echo "empty: $f"; exit 1; }
done

echo "All local lint checks passed (or noted)."
