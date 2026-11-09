#!/usr/bin/env bash
# Smoke-test a deployed AIOps API.
# Usage: ./scripts/smoke_test.sh http://HOST:8000
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:8000}"
BASE_URL="${BASE_URL%/}"

echo "==> GET ${BASE_URL}/healthz"
curl -fsS --max-time 10 "${BASE_URL}/healthz" | tee /tmp/aiops_health.json
echo

echo "==> POST ${BASE_URL}/analyze (force_fallback)"
curl -fsS --max-time 30 -X POST "${BASE_URL}/analyze" \
  -H 'Content-Type: application/json' \
  -d '{"text":"No space left on device on /var/lib/docker","force_fallback":true}' \
  | tee /tmp/aiops_analyze.json
echo

if command -v jq >/dev/null 2>&1; then
  echo "==> Parsed summary"
  jq '{health: input}' /tmp/aiops_health.json 2>/dev/null || true
  jq '{mode: .mode // .source // .engine // "n/a", keys: keys}' /tmp/aiops_analyze.json || true
fi

echo "OK: smoke test finished against ${BASE_URL}"
