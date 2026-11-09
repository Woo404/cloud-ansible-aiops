# Monitoring overlays

These files complement the sibling project's Prometheus/Grafana stack:

- `alertmanager/alertmanager.yml` — routing skeleton (no secrets)
- `alertmanager/aiops_rules.yml` — SLO + LLM alerts (availability, p95, error rate)
- `grafana/aiops_slo_dashboard.json` — importable dashboard

Metric names (`http_requests_total`, `http_request_duration_seconds_bucket`,
`llm_requests_total`) match common Prometheus client conventions used by the
sibling FastAPI app. Adjust label names if your fork differs.
