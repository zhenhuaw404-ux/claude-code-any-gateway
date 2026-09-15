# 其它网关怎么填

`GATEWAY_BASE_URL` 只要满足**一个条件**:该网关提供 **Anthropic 兼容接口**(`POST /v1/messages`)。
脚本会用 `<GATEWAY_BASE_URL>/v1/messages` 发请求,所以**结尾不要带 `/v1`**。

下面都是示例写法,以各家**当前文档**为准(本页不评价任何服务的好坏)。

## deCloud(本仓库维护方,示例默认值)

```ini
GATEWAY_BASE_URL=https://macdecloud.com
GATEWAY_API_KEY=dcld-sk-...
MODEL=deepseek/deepseek-v4-pro
```

- 同时提供 Anthropic(`/v1/messages`)、OpenAI(`/v1/chat/completions`)、Responses(`/v1/responses`)三套协议;
- 一个 Key 同时覆盖对话 / 图像 / 视频 / 语音 / 转写 / 向量;
- 接入指引(通用):见本仓库 [README](README.md) 的"图形客户端"一节;Cherry Studio 的专属助手在 `clients/cherry-studio/`。

## 自建 LiteLLM 代理

```ini
GATEWAY_BASE_URL=https://你的-litellm-域名
GATEWAY_API_KEY=你的-litellm-master-key
MODEL=你为上游模型起的别名
```

LiteLLM 代理提供 Anthropic 兼容端点(以它当前文档为准);模型名用你在 LiteLLM 里配置的**别名**。

## 其它 Anthropic 兼容服务

```ini
GATEWAY_BASE_URL=https://服务商给你的地址
GATEWAY_API_KEY=服务商给你的Key
MODEL=服务商文档里写的完整模型 ID
```

要点:
- 地址结尾**不要**自带 `/v1`(脚本会自己拼);
- 模型名**照服务商文档抄完整**,不要自己缩写;
- 拿不准就先跑一次非交互命令验证(见下方"先验证再进交互")。

## 只提供 OpenAI 协议的网关

Claude Code 走的是 Anthropic 协议,所以只提供 `/v1/chat/completions` 的网关**不能直接接**,需要一层协议适配(社区里有若干开源适配器,可自行搜索比较)。

如果你的网关同时提供 `/v1/responses`,那 **Codex 可以直接用**(`./run-codex.sh`),不需要适配层。

## 先验证再进交互

不确定配置对不对时,不要直接开交互界面,先用一次最小调用确认:

```bash
# Claude Code:进入交互后发一句最短的话即可(它自己会暴露错误)
./run.sh "只回复两个字:通了"

# Codex:非交互跑一次,报错信息更直白
./run-codex.sh exec "只回复两个字:通了"
```

报错怎么修见 [troubleshoot.md](troubleshoot.md)。
