# Runbook: Service Down

**Alert:** `AIOpsAvailabilityLow` / `AIOpsErrorRateHigh` / healthcheck fail  
**Severity:** Critical  
**SLO:** Availability ≥ 99.5%

## Symptoms
- `/healthz` returns non-200 or times out
- Grafana availability panel red
- Clients cannot POST `/analyze`

## Immediate checks (5 minutes)
1. Confirm blast radius: only this host, or shared network/DNS?
2. From your laptop:
   ```bash
   ./scripts/smoke_test.sh http://HOST:8000
   curl -sv http://HOST:8000/healthz
   ```
3. SSH to the host and inspect containers:
   ```bash
   cd /opt/aiops
   docker compose -p aiops ps
   docker compose -p aiops logs --tail=200 app
   ```

## Likely causes & actions
| Cause | Action |
|-------|--------|
| App container exited | `docker compose -p aiops up -d app` then re-check health |
| Host disk full | `df -h`; clean Docker: `docker system prune -af` (careful) |
| Port blocked by SG/UFW | Compare terraform SG + `ufw status` with `open_ports` |
| Bad deploy | Run `ansible-playbook ... playbooks/rollback.yml -e rollback_stamp=...` |

## Escalation
- If rollback fails twice, leave rule-fallback notes in the ticket and page the owner of the sibling app.
- Capture `docker compose logs` and Prometheus screenshot before further changes.

## Follow-up
- Add regression test or smoke step in CI if a config bug caused the outage.
- Update this runbook with the real root cause (learning note).
