# Point Claude Code / Codex at any gateway — one command

Use **Claude Code** and **Codex** with **any API gateway you choose** — no code changes, no pile of environment variables. Three lines of config, one command.

> This tool is **not tied to any provider**: whatever gateway you put in `.env` is where the requests go.
> The example config uses [deCloud](https://macdecloud.com) (maintained by this repo's author); swapping in another gateway or your own is a one-line change.

```
┌──────────────┐   ANTHROPIC_BASE_URL   ┌───────────┐   /v1/messages   ┌────────────┐
│ Claude Code  │ ─────────────────────► │  gateway  │ ───────────────► │  upstream  │
└──────────────┘                        └───────────┘                  └────────────┘
  Codex works the same way over /v1/responses
```

## Why

Claude Code only talks to Anthropic by default; Codex only talks to OpenAI. Pointing them elsewhere means figuring out which env vars matter, what the model ID must look like, which models can actually drive an agent (tool calling), and — for Codex — hand-writing a `config.toml` provider block.

This repo puts all of that behind **one `.env` and one command**, and documents the error messages you will hit in [troubleshoot.md](troubleshoot.md).

## Quick start

```bash
git clone https://github.com/zhenhuaw404-ux/claude-code-any-gateway.git
cd claude-code-any-gateway
cp config.example .env      # fill GATEWAY_BASE_URL / GATEWAY_API_KEY / MODEL
./run.sh                    # start Claude Code
./run.sh "summarize this repo"
./run-codex.sh exec "say ok"   # Codex, non-interactive
```

Windows: see [run.ps1](run.ps1).

## The three lines

```ini
GATEWAY_BASE_URL=https://macdecloud.com     # no trailing /v1
GATEWAY_API_KEY=dcld-sk-...
MODEL=deepseek/deepseek-v4-pro              # full ID, vendor prefix included
```

The gateway must expose an **Anthropic-compatible endpoint** (`POST /v1/messages`) for Claude Code. OpenAI-only gateways need an adapter layer in between; gateways that also expose `/v1/responses` work with Codex directly.

## Three things that bite everyone

1. **Model IDs are namespaced** — `deepseek-chat` returns 404, `deepseek/deepseek-v4-pro` works.
2. **Agent use requires tool calling** — writing/roleplay fine-tunes (names containing `magnum`, `dolphin`, …) do not support tools and will fail with `400 the upstream provider rejected this request`.
3. **Balance matters** — many gateways pre-authorise spend, so even free models return `402` when the balance is zero.

Models verified to work with tool calling (tested 2026-09; check your gateway's model page): `deepseek/deepseek-v4-pro`, `deepseek/deepseek-v4-flash`, `qwen/qwen3-coder`, `moonshotai/kimi-k3`, `z-ai/glm-5.2`, `openai/gpt-5`, `anthropic/claude-sonnet-4.5`.

## Other gateways

See [providers.md](providers.md) (self-hosted LiteLLM, other Anthropic-compatible services).

## GUI clients

`cherry-studio/generator.html` is an offline helper bundled here: paste your key, get a `cherrystudio://` link that configures [Cherry Studio](https://github.com/CherryHQ/cherry-studio) in one click. See `cherry-studio/guide.html` (Chinese).

## FAQ

**Is this an ad for one provider?** No — the scripts treat every gateway the same; the default example just happens to be deCloud (this repo's author). Change `.env` and it works with anyone.

**Claude Code says the model "isn't described by this version's model catalog".** Harmless. Optionally set `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1`, or append `[1m]` for a 1M-context model.

**Does it upload my key?** No. It's a set of local scripts; `.env` is git-ignored.

## Disclaimer

Independent tooling; not affiliated with Anthropic or OpenAI. Check your gateway's terms before use, and never hard-code keys in a repo.

## License

MIT
