# Architecture

This repository is the **cloud delivery / ops** companion to
[`aiops-log-assistant`](https://github.com/Woo404/aiops-log-assistant).

```mermaid
flowchart TB
  subgraph Laptop[Operator laptop]
    TF[Terraform example<br/>Aliyun ECS / AWS EC2]
    ANS[Ansible playbooks<br/>deploy / healthcheck / rollback]
    CI[GitHub Actions<br/>yamllint ansible-lint terraform fmt]
  end

  subgraph Cloud[Cloud VM]
    SG[Security Group / UFW]
    Docker[Docker Engine + Compose]
    App[aiops-log-assistant<br/>FastAPI]
    LLM[Ollama optional]
    Prom[Prometheus + rules]
    Graf[Grafana SLO dashboard]
    AM[Alertmanager]
  end

  TF -->|creates VM + SG| Cloud
  ANS -->|SSH roles: common docker aiops_app monitoring hardening| Docker
  Docker --> App
  Docker --> LLM
  Docker --> Prom
  Docker --> Graf
  Docker --> AM
  Prom -->|scrape /metrics| App
  Prom --> AM
  Graf --> Prom
  CI -->|lint on PR| ANS
  Oncall[On-call] -->|runbooks| AM
  Smoke[scripts/smoke_test.sh] -->|/healthz /analyze| App
```

## Deploy flow

1. **Provision** (optional): `terraform apply` in `terraform/aliyun` or `terraform/aws` → public IP.
2. **Inventory**: copy `ansible/inventory/*.example.ini` → set `ansible_host`.
3. **Deploy**: `ansible-playbook ... playbooks/deploy.yml` runs roles in order:
   `common` → `docker` → `aiops_app` → `monitoring` → `hardening`.
4. **Verify**: `playbooks/healthcheck.yml` or `scripts/smoke_test.sh`.
5. **Incident**: follow `runbooks/*`; rollback via `playbooks/rollback.yml`.

## JD skill mapping (learning)

| Theme | Where in this repo |
|-------|--------------------|
| Alibaba Cloud / AWS | `terraform/aliyun`, `terraform/aws`, inventory examples |
| Ansible | `ansible/roles/*`, playbooks |
| CI/CD | `.github/workflows/ci.yml` |
| Monitoring / SLO | `monitoring/`, Grafana dashboard JSON |
| Incident response | `runbooks/` |
| Responsible AI | sibling app redaction + `runbooks/llm-unavailable*` |
