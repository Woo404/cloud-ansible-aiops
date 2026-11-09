# Runbook: High Latency

**Alert:** `AIOpsHighLatencyP95`  
**Severity:** Warning  
**SLO:** p95 latency ≤ 2s

## Symptoms
- Grafana p95 panel yellow/red
- `/analyze` slow; health may still be green

## Checks
1. Confirm whether latency is LLM-bound or network-bound:
   ```bash
   curl -w 'ttfb=%{time_starttransfer} total=%{time_total}\n' -o /dev/null -s \
     http://HOST:8000/healthz
   curl -s -X POST http://HOST:8000/analyze \
     -H 'Content-Type: application/json' \
     -d '{"text":"disk full","force_fallback":true}' | jq .
   ```
2. On host: CPU / memory / IO
   ```bash
   docker stats --no-stream
   free -h; uptime
   ```
3. Prometheus: compare `http_request_duration_seconds` vs `llm_*` metrics.

## Actions
| Cause | Action |
|-------|--------|
| LLM cold start / model pull | Keep `force_fallback` for urgent traffic; warm model off-peak |
| Host undersized | Scale instance type (Terraform var) or disable Ollama on small VMs |
| Noisy neighbor / CPU steal | Check cloud monitoring; move to dedicated instance |
| Downstream timeout too high | Lower `LLM_TIMEOUT_SECONDS` so requests fail fast into rules |

## Follow-up
- Add load test numbers to the README after you measure them yourself.
