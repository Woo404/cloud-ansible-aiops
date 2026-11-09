# 运维手册：高延迟

**告警：** `AIOpsHighLatencyP95`  
**级别：** 警告  
**SLO：** p95 延迟 ≤ 2s

## 现象
- Grafana p95 面板变黄/红
- `/analyze` 变慢，健康检查可能仍绿

## 排查
1. 区分是大模型慢还是网络慢：
   ```bash
   curl -w 'ttfb=%{time_starttransfer} total=%{time_total}\n' -o /dev/null -s \
     http://HOST:8000/healthz
   curl -s -X POST http://HOST:8000/analyze \
     -H 'Content-Type: application/json' \
     -d '{"text":"disk full","force_fallback":true}' | jq .
   ```
2. 上机看资源：
   ```bash
   docker stats --no-stream
   free -h; uptime
   ```
3. 在 Prometheus 对比 HTTP 延迟与 `llm_*` 指标。

## 动作
| 原因 | 动作 |
|------|------|
| 模型冷启动 / 正在拉取 | 紧急流量用 `force_fallback`；低峰预热模型 |
| 规格太小 | Terraform 调大机型，或小机器关掉 Ollama |
| 争抢 / CPU steal | 看云监控，换独享型 |
| 下游超时过长 | 调低 `LLM_TIMEOUT_SECONDS`，快速落入规则兜底 |

## 复盘
- 自己压测后把数字写进 README，不要编造。
