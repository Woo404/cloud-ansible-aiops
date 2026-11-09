# cloud-ansible-aiops (Learning Reference)

Ansible + light Terraform delivery kit for deploying the sibling
[`aiops-log-assistant`](https://github.com/Woo404/aiops-log-assistant) stack onto an
**Alibaba Cloud ECS** or **AWS EC2** VM, with SLO-focused monitoring overlays and
incident runbooks.

> **Learning / reference only.** Study it, run it on **your own** cloud account,
> change it, then push **your own** fork and commit history.
> Do not present an untouched copy as original production work, and do not invent
> personal metrics or incident outcomes.

## Why this repo exists

It fills the cloud / DevOps practice gaps that a pure application repo leaves open:

| Skill | This repo |
|-------|-----------|
| Alibaba Cloud / AWS VM + SG | `terraform/aliyun`, `terraform/aws` |
| Ansible roles & playbooks | `ansible/roles/*`, `deploy` / `rollback` / `healthcheck` |
| CI lint pipeline | `.github/workflows/ci.yml` |
| Monitoring & SLO alerts | `monitoring/` + Grafana dashboard JSON |
| Incident response | `runbooks/` (EN + 中文) |
| Responsible AI ops | Points at sibling PII redaction + LLM fallback runbook |

## Architecture

See [docs/architecture.md](docs/architecture.md) (includes a Mermaid deploy-flow diagram).

```text
Terraform (optional) → ECS/EC2 + Security Group
        ↓
Ansible roles: common → docker → aiops_app → monitoring → hardening
        ↓
Docker Compose stack (sibling app + Prometheus + Grafana + Ollama)
        ↓
smoke_test.sh / healthcheck.yml / Alertmanager rules / runbooks
```

## Quick start

### 0) Prerequisites on your laptop

- Python 3.10+, `ansible-core`, SSH key access to a Ubuntu 22.04 VM
- Optional: Terraform 1.5+, cloud credentials (never commit them)
- Sibling repo available as git URL (default) or local checkout

```bash
python -m venv .venv && source .venv/bin/activate
pip install ansible-core ansible-lint yamllint
cd ansible && ansible-galaxy collection install -r requirements.yml
```

### 1) (Optional) Provision a VM

```bash
cd terraform/aliyun   # or terraform/aws
cp terraform.tfvars.example terraform.tfvars   # edit; keep secrets out of git
terraform init && terraform plan
# terraform apply
```

Copy the `public_ip` output into an inventory file.

### 2) Inventory

```bash
cp ansible/inventory/aliyun.example.ini ansible/inventory/aliyun.ini
# set ansible_host=... and ansible_user=...
```

### 3) Deploy

```bash
cd ansible
ansible-playbook -i inventory/aliyun.ini playbooks/deploy.yml \
  -e grafana_admin_password=admin
# learning tip: change that password immediately on first login
```

### 4) Verify

```bash
ansible-playbook -i inventory/aliyun.ini playbooks/healthcheck.yml
../scripts/smoke_test.sh http://YOUR_IP:8000
```

### 5) Rollback

Snapshots live under `/opt/aiops/.rollback/<timestamp>/` on the host:

```bash
ansible-playbook -i inventory/aliyun.ini playbooks/rollback.yml \
  -e rollback_stamp=20260101T120000Z
```

## Layout

```text
ansible/           roles + playbooks + example inventories
terraform/         optional single-VM examples (Aliyun + AWS)
monitoring/        Alertmanager + Prometheus rules + Grafana SLO JSON
runbooks/          service-down / high-latency / llm-unavailable (EN+ZH)
scripts/           smoke_test.sh, lint_local.sh
docs/              architecture with Mermaid
.github/workflows  yamllint, ansible-lint, terraform fmt/validate
```

## Local lint

```bash
./scripts/lint_local.sh
```

## Security notes

- No real secrets in this tree. Use `ansible-vault` / env vars / cloud IAM.
- Tighten `allowed_cidr` in Terraform before any public deploy.
- Change Grafana admin password; do not leave `CHANGE_ME` in production.

## License

MIT — see [LICENSE](LICENSE).
