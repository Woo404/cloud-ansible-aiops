# Runbook: LLM Unavailable

**Alert:** `AIOpsLLMUnavailable`  
**Severity:** Warning (service may still be OK via rule fallback)

## Symptoms
- LLM error ratio high; Ollama container unhealthy
- `/analyze` still returns results when `ENABLE_RULE_FALLBACK=true`
- Responsible-AI note: redaction must still run before any model call

## Checks
1. Confirm fallback path:
   ```bash
   curl -s -X POST http://HOST:8000/analyze \
     -H 'Content-Type: application/json' \
     -d '{"text":"Out of memory: Kill process","force_fallback":true}' | jq .
   ```
2. Ollama status:
   ```bash
   docker compose -p aiops ps ollama
   docker compose -p aiops logs --tail=100 ollama
   curl -s http://127.0.0.1:11434/api/tags | jq .
   ```
3. Disk / memory for model weights.

## Actions
| Cause | Action |
|-------|--------|
| Model not pulled | `docker compose exec ollama ollama pull qwen2.5:7b` (or your model) |
| Ollama OOM | Increase instance RAM or use a smaller model |
| Wrong `LLM_BASE_URL` | Fix `.env` via Ansible template and redeploy |
| Cloud LLM key/quota | Rotate key via vault; never put keys in git |

## Responsible AI reminders
- Keep PII redaction enabled (`ENABLE_REDACTION=true`).
- Prefer local models for sensitive ops logs; if using cloud LLM APIs, document data handling.
- Rule fallback is a safety net, not a silent degradation — page if fallback rate stays high.
