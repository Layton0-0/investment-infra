# IntelliJ/Cursor 직접 구동용: DB + Redis + Python(prediction-service, data-collector) 기동 (백엔드·프론트·nginx 제외)
# 사용: .\scripts\local-up-db-only.ps1  (investment-infra 또는 프로젝트 루트에서 실행)
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir = Split-Path -Parent $ScriptDir
$ComposeFile = Join-Path $InfraDir "docker-compose.local-db-only.yml"

Set-Location $InfraDir
if (-not (Test-Path $ComposeFile)) {
    Write-Error "Not found: $ComposeFile"
    exit 1
}

Write-Host "Starting timescaledb + redis + prediction-service + data-collector (for IntelliJ/Cursor direct run)..." -ForegroundColor Cyan
docker compose -f docker-compose.local-db-only.yml up -d --build
Write-Host "Done. Backend: IntelliJ (local,intellij) or investment-backend\scripts\bootRun-agent.ps1 (local,local-agent)." -ForegroundColor Green
