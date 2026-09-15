# Claude Code → any gateway (Windows PowerShell)
#
# Usage:
#   Copy-Item config.example .env   # then fill GATEWAY_BASE_URL / GATEWAY_API_KEY / MODEL
#   ./run.ps1
#   ./run.ps1 "summarize this repo"
$ErrorActionPreference = "Stop"
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = if ($env:ENV_FILE) { $env:ENV_FILE } else { Join-Path $dir ".env" }

if (-not (Test-Path $envFile)) {
  Write-Host "x .env not found. Run: Copy-Item config.example .env  then fill it in."
  exit 1
}

Get-Content $envFile | ForEach-Object {
  $line = $_.Trim()
  if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
    $k, $v = $line.Split("=", 2)
    Set-Item -Path ("Env:" + $k.Trim()) -Value $v.Trim()
  }
}

if (-not $env:GATEWAY_BASE_URL) { Write-Host "x GATEWAY_BASE_URL missing"; exit 1 }
if (-not $env:GATEWAY_API_KEY)  { Write-Host "x GATEWAY_API_KEY missing";  exit 1 }
if (-not $env:MODEL)            { Write-Host "x MODEL missing";            exit 1 }

$env:ANTHROPIC_BASE_URL   = $env:GATEWAY_BASE_URL.TrimEnd("/")
$env:ANTHROPIC_AUTH_TOKEN = $env:GATEWAY_API_KEY
$env:ANTHROPIC_MODEL      = $env:MODEL

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Host "x claude not found. Install: npm install -g @anthropic-ai/claude-code"
  exit 1
}

Write-Host "----------------------------------------------"
Write-Host " Claude Code -> custom gateway"
Write-Host " base url : $env:ANTHROPIC_BASE_URL"
Write-Host " model    : $env:ANTHROPIC_MODEL"
Write-Host "----------------------------------------------"

if ($args.Count -gt 0) { & claude @args } else { & claude }
