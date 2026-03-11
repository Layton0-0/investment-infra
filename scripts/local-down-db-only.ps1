# local-db-only Compose 중지 (timescaledb + redis + prediction-service + data-collector)
# 사용: .\scripts\local-down-db-only.ps1  (investment-infra에서 실행)
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir = Split-Path -Parent $ScriptDir
Set-Location $InfraDir
docker compose -f docker-compose.local-db-only.yml down
