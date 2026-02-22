# 로컬 풀 스택 중지
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir = Split-Path -Parent $ScriptDir
$ComposeFile = Join-Path $InfraDir "docker-compose.local-full.yml"
Set-Location $InfraDir
docker compose -f $ComposeFile down
Write-Host "Local full stack stopped."
