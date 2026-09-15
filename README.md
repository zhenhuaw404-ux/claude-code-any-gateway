# Claude Code / Codex 接任意网关 · 一条命令

把 **Claude Code** 和 **Codex** 接到**你自己选的任何 API 网关**上 —— 不用改代码、不用记一堆环境变量,填三行配置、跑一条命令。

> 这个工具**不绑定任何一家服务**:你在 `.env` 里填哪个网关,它就把请求发到哪个网关。
> 仓库里的示例用 [deCloud](https://macdecloud.com)(我们维护的网关),你完全可以换成别家或自建的。

```
┌──────────────┐   ANTHROPIC_BASE_URL   ┌───────────┐   /v1/messages   ┌────────────┐
│ Claude Code  │ ─────────────────────► │  你的网关  │ ───────────────► │ 上游模型商  │
└──────────────┘                        └───────────┘                  └────────────┘
   Codex 同理,走 /v1/responses
```

---

## 先对齐三个词

| 词 | 指什么 | 例子 |
|---|---|---|
| **客户端** | 装在你这边的程序,发起请求 | Claude Code、Codex、Cherry Studio、NextChat |
| **网关** | 中间那一层,转发请求、记账 | 你在 `.env` 里填的那个(或自建 LiteLLM) |
| **上游** | 真正跑模型的一方 | DeepSeek、OpenAI、Anthropic 等原厂 |

流程:**客户端 → 网关 → 上游**。这个仓库解决的是"客户端怎么连上网关"这一段。

## 为什么需要它

Claude Code 默认只连 Anthropic 官方,Codex 默认只连 OpenAI。想接别家,你要自己处理:

- 环境变量到底该设哪几个(`ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_MODEL`…);
- 模型名到底填什么(简称一律 404,必须写完整 ID);
- 哪些模型**能跑 Agent**(不支持工具调用的模型一定会报 400);
- Codex 还要手写 `config.toml` 描述供应商。

这个仓库把这些都收进**一个 `.env` + 一条命令**,并且把常见报错怎么修写在 [troubleshoot.md](troubleshoot.md) 里。

## 30 秒上手

```bash
git clone https://github.com/zhenhuaw404-ux/claude-code-any-gateway.git
cd claude-code-any-gateway

cp config.example .env
# 打开 .env 填三行:GATEWAY_BASE_URL / GATEWAY_API_KEY / MODEL

./run.sh                      # 启动 Claude Code
./run.sh "帮我看下这个仓库"      # 顺便带上第一个任务
```

想要 Codex:

```bash
./run-codex.sh                                  # 交互式
./run-codex.sh exec "只回复两个字:通了"           # 非交互,适合验证配置
```

Windows(PowerShell)见 [run.ps1](run.ps1)。

## 配置就三行

```ini
GATEWAY_BASE_URL=https://macdecloud.com     # 网关地址,结尾不要带 /v1
GATEWAY_API_KEY=dcld-sk-...                 # 你的 Key
MODEL=deepseek/deepseek-v4-pro              # 完整 ID(带厂商前缀)
```

**要求**:网关要提供 **Anthropic 兼容接口**(`POST /v1/messages`),Claude Code 才能接。
只有 OpenAI 兼容接口(`/v1/chat/completions`)的网关,需要额外适配层。

## 选模型的三个要点(最容易踩的坑)

1. **必须写完整 ID** —— `deepseek-chat` 会 404,`deepseek/deepseek-v4-pro` 才行;
2. **要跑 Agent / Claude Code,模型必须支持「工具调用」** —— 写作、角色扮演类模型(名字里带 `magnum`、`dolphin` 这类)**不支持工具调用**,一用就报 `400 the upstream provider rejected this request`;
3. **余额要够** —— 很多网关是预扣计费,余额为 0 时连免费模型也会返回 `402`。

实测可用的模型(2026-09 在 deCloud 上逐个试过,供参考,以你网关的模型页为准):

| 场景 | 模型 |
|---|---|
| 通用 / 便宜 | `deepseek/deepseek-v4-pro`、`deepseek/deepseek-v4-flash` |
| 代码 | `qwen/qwen3-coder`、`qwen/qwen3-coder-next` |
| 其他已验证支持工具调用 | `moonshotai/kimi-k3`、`z-ai/glm-5.2`、`openai/gpt-5`、`anthropic/claude-sonnet-4.5` |
| ❌ 不支持工具调用 | `anthracite-org/magnum-v4-72b`(写作向) |

## 其它网关怎么填

见 [providers.md](providers.md)(自建 LiteLLM、其它 Anthropic 兼容服务等)。

## 图形客户端(任何 OpenAI 兼容客户端都行)

NextChat、Chatbox、LobeChat、Open WebUI、Cherry Studio…… 任何 OpenAI 兼容的客户端做法都一样,只填两个字段:

| 字段 | 填什么 |
|---|---|
| 服务商类型 | OpenAI(或"OpenAI 兼容") |
| 接口地址 / Base URL | `<你的网关地址>/v1`(要带 `/v1`) |
| API Key | 你自己的 Key |
| 模型名 | 完整 ID,例如 `deepseek/deepseek-v4-pro` |

> ⚠️ 不要改客户端自带的「OpenAI」那一项(它的地址固定是 api.openai.com),要**新加一个自定义服务商**。

**图形客户端的便利助手**:`clients/` 目录按客户端收录"少填几个字段"的小工具 —— 目前有 Cherry Studio 的 `clients/cherry-studio/generator.html`(粘贴 Key 生成一条一键配置链接,Key 只在本地浏览器里)与配套说明 `clients/cherry-studio/guide.html`;其它客户端后续按需增加。**这些都不是必须的**,上面的表格填一遍就够了。

## 常见问题

**Q:这算不算给某家打广告?**
不是。脚本对任何网关一视同仁,`.env` 里填谁就用谁;示例默认用 deCloud(本仓库维护方),你改成别家照样能跑。

**Q:Claude Code 提示 "isn't described by this version's model catalog" 怎么办?**
不影响使用。想安静点可以在 `.env` 里加 `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1`;模型支持更长上下文时,也可以给模型名加后缀(如 `[1m]`)。

**Q:Codex 提示 "Model metadata ... not found"?**
同样不影响,Codex 会退回默认元数据。

**Q:为什么不是改 Claude Code 的配置文件?**
环境变量更安全也更干净:这个脚本只在本次运行生效,不写进你的全局配置,也不会把 Key 留在仓库里(见 `.gitignore`)。

**Q:Key 会被上传吗?**
不会。这个仓库只是一堆本地脚本,不联网、不收集任何东西;`.env` 已被 `.gitignore` 排除。

## 免责声明

本仓库是独立工具,与 Anthropic、OpenAI 均无关联。使用任何第三方网关前请自行确认其条款;不要在代码或仓库里硬编码密钥。

## License

MIT
