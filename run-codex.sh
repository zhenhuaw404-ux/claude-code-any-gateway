#!/usr/bin/env bash
# 把 Codex 接到任意 OpenAI 兼容网关(一条命令)
#
# 用法:复制 config.example 为 .env 填好,然后 ./run-codex.sh
#       ./run-codex.sh exec "只回复两个字:通了"   → 非交互跑一次(适合验证配置)
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-$DIR/.env}"
[ -f "$ENV_FILE" ] || { echo "✗ 先 cp config.example .env 并填好"; exit 1; }

set -a; . "$ENV_FILE"; set +a
: "${GATEWAY_BASE_URL:?填 GATEWAY_BASE_URL}"
: "${GATEWAY_API_KEY:?填 GATEWAY_API_KEY}"
: "${MODEL:?填 MODEL}"

# Codex 用 config.toml 描述供应商;这里动态生成一份,放在本目录的 .codex/ 下,不污染你的全局配置
CODEX_HOME="${CODEX_HOME:-$DIR/.codex}"
mkdir -p "$CODEX_HOME"
cat > "$CODEX_HOME/config.toml" <<TOML
model = "$MODEL"
model_provider = "gateway"

[model_providers.gateway]
name = "Gateway"
base_url = "${GATEWAY_BASE_URL%/}/v1"
env_key = "GATEWAY_API_KEY"
wire_api = "responses"
TOML
export CODEX_HOME
export GATEWAY_API_KEY

if ! command -v codex >/dev/null 2>&1; then
  echo "✗ 没找到 codex 命令。先安装:npm install -g @openai/codex"; exit 1
fi

echo "──────────────────────────────────────────────"
echo " Codex → 自定义网关"
echo " 接口地址:${GATEWAY_BASE_URL%/}/v1"
echo " 模型    :$MODEL"
echo " 配置目录:$CODEX_HOME"
echo "──────────────────────────────────────────────"

# 不在 git 仓库里跑时,Codex 会要求加 --skip-git-repo-check;非交互模式同理
if [ "$#" -gt 0 ]; then exec codex "$@"; else exec codex; fi
