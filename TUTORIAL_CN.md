# 一晚上手指南（中文）

目标：用 **Ansible** 把兄弟项目
[aiops-log-assistant](https://github.com/Woo404/aiops-log-assistant)
部署到 **阿里云 ECS 或 AWS EC2**，挂上监控与告警，并会按手册处理三类故障。

> 这是**学习参考实现**。请在你自己的云账号上跑通，改成你的配置，再用你自己的
> Git 提交推到你的仓库。不要把未改动的拷贝说成生产项目，也不要编造个人业绩数字。

## 和汇丰类 JD 的对应关系

| JD 主题 | 你今晚练到的东西 | 面试可讲的点（跑通后） |
|---------|------------------|------------------------|
| 阿里云 / AWS | `terraform/*` 建一台机 + 安全组；inventory 区分两朵云 | 能说清 SG 端口、公网 IP、密钥登录 |
| Ansible | 五个 role：common / docker / aiops_app / monitoring / hardening | 会讲角色拆分、幂等、rollback 快照 |
| CI/CD | `.github/workflows/ci.yml` 做 yamllint + ansible-lint + terraform validate | PR 即质量门禁，而不是只在本机点一下 |
| 监控 | Prometheus 规则 + Grafana SLO 看板 JSON | 可用性 / p95 / 错误率三条 SLO |
| 事故响应 | `runbooks/` 中英手册 | 按现象 → 排查 → 动作 → 复盘讲 |
| AI / 负责任 AI | 兄弟项目脱敏 + 本仓库 `llm-unavailable` 手册 | 先脱敏再进模型；模型挂了走规则兜底 |

## 今晚时间盒（约 2–3 小时）

### 第 0 步（15 分钟）— 环境

```bash
git clone <你的 fork 或本仓库>
cd cloud-ansible-aiops
python -m venv .venv && source .venv/bin/activate
pip install ansible-core ansible-lint yamllint
cd ansible && ansible-galaxy collection install -r requirements.yml
../scripts/lint_local.sh
```

### 第 1 步（30–45 分钟）— 弄到一台 Ubuntu 22.04

两条路任选：

1. **控制台手建**（更快）：阿里云 ECS 或 AWS EC2，开 22/8000/3000/9090/9093，记下公网 IP。
2. **Terraform 示例**：`terraform/aliyun` 或 `terraform/aws`，复制 `*.tfvars.example`，填自己的 VPC/子网/密钥，`plan` 看懂后再 `apply`。

把 IP 写进：

```bash
cp inventory/aliyun.example.ini inventory/aliyun.ini   # 或 aws
# 编辑 ansible_host / ansible_user
```

### 第 2 步（45–60 分钟）— Ansible 部署

```bash
ansible-playbook -i inventory/aliyun.ini playbooks/deploy.yml \
  -e grafana_admin_password=admin
```

角色顺序：

1. **common** — 基础包、时区、目录  
2. **docker** — Docker Engine + Compose 插件  
3. **aiops_app** — 拉取兄弟仓库、写 `.env`、`docker compose up`、做 rollback 快照  
4. **monitoring** — 下发 Alertmanager / 规则 / Grafana SLO JSON 到 overlay 目录  
5. **hardening** — UFW 放行端口、自动安全更新  

验证：

```bash
ansible-playbook -i inventory/aliyun.ini playbooks/healthcheck.yml
../scripts/smoke_test.sh http://你的公网IP:8000
```

### 第 3 步（20 分钟）— 看监控与手册

- 打开 Grafana（默认 3000），导入或查看 `monitoring/grafana/aiops_slo_dashboard.json`
- 打开三条手册，对照告警名读一遍：服务挂、高延迟、LLM 不可用

### 第 4 步（15 分钟）— 故意演练一次回滚

```bash
# 在机器上看快照目录
ssh user@IP 'ls /opt/aiops/.rollback'

ansible-playbook -i inventory/aliyun.ini playbooks/rollback.yml \
  -e rollback_stamp=<某个时间戳>
```

## 面试 1 分钟讲法（跑通后再背）

> 我有一个 AI 日志分析服务（兄弟项目），本地用 Docker Compose 跑 FastAPI + Ollama，
> 请求进模型前会做 PII 脱敏，模型挂了走规则兜底。  
> 这个仓库是它的云交付层：Terraform 示例拉起 ECS/EC2 和安全组，Ansible 五个角色
> 装 Docker、拉代码、部署、挂 Prometheus/Grafana SLO、做基础加固；CI 里跑
> ansible-lint 和 terraform validate。  
> 出故障按手册：先 smoke test 和 compose logs，必要时按时间戳 rollback。

## 简历条目模板（必须你自己跑通后再用）

```text
- Built an Ansible-based delivery kit (roles + deploy/rollback/healthcheck) to
  deploy a containerized AIOps API to Alibaba Cloud ECS / AWS EC2, with
  Terraform example for VM + security group and GitHub Actions lint gates.
- Added Prometheus SLO alerts (availability, p95 latency, error rate) and
  bilingual incident runbooks covering service-down, high latency, and LLM outage.
```

把具体云厂商、你真实用过的实例规格、你自己截的 Grafana 图补进去；**不要写没测过的数字**。

## 常见坑

- `grafana_admin_password` 仍是 `CHANGE_ME`：学习环境用 `-e` 覆盖，正式环境用 vault。
- 安全组没放行：Terraform / 控制台 / UFW 三处要一致。
- 小规格机器拉 7B 模型 OOM：先 `pull_ollama_model=false`，只用规则兜底演示。
- 指标名对不上：兄弟项目若改了 metric 名，同步改 `monitoring/alertmanager/aiops_rules.yml`。

## 下一步（周末加分）

1. 给 Alertmanager 接上真实 webhook（仍不要把 webhook URL 提交进 git）。  
2. 给 deploy 加 Ansible Molecule 或 molecule-like 的 check mode 演练。  
3. 把 smoke_test 做成 GitHub Action 对 staging 的定时拨测。  
