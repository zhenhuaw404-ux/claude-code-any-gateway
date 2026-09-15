# 报错对照表(照着查)

先做一次最小验证,再进交互界面 —— 报错信息更直白:

```bash
./run.sh "只回复两个字:通了"                 # Claude Code
./run-codex.sh exec "只回复两个字:通了"       # Codex(非交互)
```

## 一、网关返回的错误

| 返回 | 含义 | 怎么办 |
|---|---|---|
| `401` | Key 无效 | 检查有没有多空格/换行;确认用的是这一家的 Key |
| `402` | 余额不足 | 先充值。**注意:很多网关余额为 0 时,连免费模型也会返回 402** |
| `403` | 该模型未开通 / 额度用尽 | 换个模型,或去控制台看该模型是否启用 |
| `404` `model_not_found` | 模型名不对 | **必须写完整 ID(带厂商前缀)**,例如 `deepseek/deepseek-v4-pro`;只写简称一律 404 |
| `429` | 请求太频繁 | 等几秒重试;免费档最容易遇到 |
| `400` `the upstream provider rejected this request` | 上游不接受这个请求 | **九成是模型不支持工具调用**(Agent 场景必需),换成支持工具调用的模型;也可能是该模型不支持某个参数 |
| `502` `upstream_model_missing` | 上游没有这个模型 | 换模型;或该模型尚未在该网关开通 |
| `504` `upstream_timeout` | 上游超时 | 换模型/重试;免费档或冷门模型容易超时 |

## 二、地址(最常见的自伤)

- 地址**结尾不要带 `/v1`**:脚本自己会拼 `/v1/messages`。写成 `https://x.com/v1` 会变成 `https://x.com/v1/v1/messages` → 404。
- 地址**必须有 http(s)://** 前缀。
- 换网关时记得**同时换 Key 和模型名**:不同网关的模型 ID 常常不一样。

## 三、Claude Code 自己的提示

| 提示 | 要不要管 |
|---|---|
| `"...isn't described by this version's model catalog..."` | **不影响使用**。想安静点:在 `.env` 里加 `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1`;若模型上下文更大,可在模型名后加后缀(如 `[1m]`) |
| 让它干活时它只回答问题、不动文件 | 该模型**不支持工具调用**。换成支持工具调用的模型(见 README 的模型表) |

## 四、Codex 自己的提示

| 提示 | 怎么办 |
|---|---|
| `Model metadata for "xxx" not found. Defaulting to fallback metadata` | **不影响使用** |
| `Not inside a trusted directory and --skip-git-repo-check was not specified` | 在 git 仓库里跑,或加参数:`./run-codex.sh exec --skip-git-repo-check "任务"` |
| `Reading additional input from stdin...` | 非交互跑时把 stdin 关掉:`./run-codex.sh exec "任务" < /dev/null` |

## 五、还不行?给我这三样

提 issue 时把下面三样贴上,基本能一眼定位:

1. 你跑的**完整命令**(Key 打码);
2. **报错原文**(整段,别截断);
3. `curl` 一次最小请求的结果:

```bash
curl -sS -o - -w '\nHTTP %{http_code}\n' \
  "${GATEWAY_BASE_URL}/v1/messages" \
  -H "Authorization: Bearer $GATEWAY_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"$MODEL\",\"max_tokens\":50,\"messages\":[{\"role\":\"user\",\"content\":\"回复:ok\"}]}"
```

> 顺手提醒:任何情况下**不要把 Key 贴到公开 issue 里**。
