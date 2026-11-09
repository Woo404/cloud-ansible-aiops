# 运维手册：大模型不可用

**告警：** `AIOpsLLMUnavailable`  
**级别：** 警告（规则兜底开启时业务可能仍可用）

## 现象
- LLM 错误比例升高；Ollama 不健康
- `ENABLE_RULE_FALLBACK=true` 时 `/analyze` 仍可返回
- 负责任 AI：发往模型前必须完成脱敏

## 排查
1. 确认兜底路径：
   ```bash
   curl -s -X POST http://HOST:8000/analyze \
     -H 'Content-Type: application/json' \
     -d '{"text":"Out of memory: Kill process","force_fallback":true}' | jq .
   ```
2. 看 Ollama：
   ```bash
   docker compose -p aiops ps ollama
   docker compose -p aiops logs --tail=100 ollama
   curl -s http://127.0.0.1:11434/api/tags | jq .
   ```
3. 检查模型权重占用的磁盘与内存。

## 动作
| 原因 | 动作 |
|------|------|
| 模型未拉取 | `docker compose exec ollama ollama pull qwen2.5:7b` |
| Ollama OOM | 加大内存或换更小模型 |
| `LLM_BASE_URL` 配错 | 改 Ansible 模板里的 `.env` 后重发 |
| 云端 LLM 密钥/配额 | 用 vault 轮换；密钥绝不进 git |

## 负责任 AI 提醒
- 保持 `ENABLE_REDACTION=true`
- 敏感运维日志优先本地模型；若走云端 API，写明数据处理方式
- 规则兜底是安全网，不是静默降级——兜底比例持续偏高要升级
