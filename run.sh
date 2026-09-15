#!/usr/bin/env bash
# 把 Claude Code 接到任意 OpenAI 兼容网关(一条命令)
#
# 用法:
#   1) 复制 config.example 为 .env,填好 GATEWAY_BASE_URL / GATEWAY_API_KEY / MODEL
#   2) ./run.sh              → 用 .env 里的配置启动 Claude Code
#      ./run.sh "帮我看看这个仓库"   → 启动并带上第一个任务
#
# 支持的网关:任何提供 Anthropic 兼容接口(/v1/messages)的服务,
# 或者提供 OpenAI 兼容接口但带 Anthropic 适配的服务(见 README 的说明)。
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-$DIR/.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "✗ 没找到配置文件:$ENV_FILE"
  echo "  先复制一份:cp config.example .env  然后填好里面三项"
  exit 1
fi

# 读取配置(忽略注释与空行)
set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

: "${GATEWAY_BASE_URL:?请在 .env 里填 GATEWAY_BASE_URL,例如 https://your-gateway.example.com}"
: "${GATEWAY_API_KEY:?请在 .env 里填 GATEWAY_API_KEY}"
: "${MODEL:?请在 .env 里填 MODEL,例如 vendor/model-name(要写完整 ID)}"

# Claude Code 走的是 Anthropic 协议:它会把请求发到 $ANTHROPIC_BASE_URL/v1/messages
export ANTHROPIC_BASE_URL="${GATEWAY_BASE_URL%/}"
export ANTHROPIC_AUTH_TOKEN="$GATEWAY_API_KEY"
export ANTHROPIC_MODEL="$MODEL"

# 有些网关/模型不在 Claude Code 自带的模型目录里,它会打一行提示并假设 200k 上下文。
# 想安静点可以打开下面这行(可选):
# export CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1

# 找 claude:优先用 .env 里的 CLAUDE_BIN(本地安装),否则用 PATH 里的
CLAUDE_BIN="${CLAUDE_BIN:-}"
if [ -z "$CLAUDE_BIN" ]; then
  if command -v claude >/dev/null 2>&1; then
    CLAUDE_BIN="$(command -v claude)"
  else
    echo "✗ 没找到 claude 命令。先安装 Claude Code:"
    echo "    npm install -g @anthropic-ai/claude-code"
    echo "  (或者本地装好后,在 .env 里写 CLAUDE_BIN=/路径/to/claude)"
    exit 1
  fi
fi

echo "──────────────────────────────────────────────"
echo " Claude Code → 自定义网关"
echo " 接口地址:$ANTHROPIC_BASE_URL"
echo " 模型    :$ANTHROPIC_MODEL"
echo "──────────────────────────────────────────────"

if [ "$#" -gt 0 ]; then
  exec "$CLAUDE_BIN" "$@"
else
  exec "$CLAUDE_BIN"
fi
