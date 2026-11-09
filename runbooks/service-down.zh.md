# 运维手册：服务不可用

**告警：** `AIOpsAvailabilityLow` / `AIOpsErrorRateHigh` / 健康检查失败  
**级别：** 严重  
**SLO：** 可用性 ≥ 99.5%

## 现象
- `/healthz` 非 200 或超时
- Grafana 可用性面板变红
- 客户端无法调用 `/analyze`

## 5 分钟内先做
1. 确认影响范围：单机还是整网/DNS？
2. 本机探测：
   ```bash
   ./scripts/smoke_test.sh http://HOST:8000
   curl -sv http://HOST:8000/healthz
   ```
3. SSH 上机看容器：
   ```bash
   cd /opt/aiops
   docker compose -p aiops ps
   docker compose -p aiops logs --tail=200 app
   ```

## 常见原因与动作
| 原因 | 动作 |
|------|------|
| app 容器退出 | `docker compose -p aiops up -d app`，再查健康 |
| 磁盘写满 | `df -h`；谨慎清理 `docker system prune -af` |
| 安全组 / UFW 端口未放行 | 对照 terraform 安全组与 `ufw status` |
| 错误发布 | `ansible-playbook ... playbooks/rollback.yml -e rollback_stamp=...` |

## 升级
- 回滚两次仍失败：在工单注明规则兜底仍可用，并通知应用负责人
- 继续改动前先保存 `docker compose logs` 与 Prometheus 截图

## 复盘
- 若是配置问题，把冒烟检查补进 CI
- 把真实根因写回本手册（学习记录）
