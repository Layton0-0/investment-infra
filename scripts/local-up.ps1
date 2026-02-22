# 로컬 풀 스택 기동 (배포 3대: Osaka + Korea + AWS, Mumbai 제외)
# 사용: .\scripts\local-up.ps1  (investment-infra 또는 프로젝트 루트에서 실행)
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir = Split-Path -Parent $ScriptDir
$RootDir = Split-Path -Parent $InfraDir
$ComposeFile = Join-Path $InfraDir "docker-compose.local-full.yml"
$EnvFile = Join-Path $InfraDir ".env"

Set-Location $InfraDir

if (-not (Test-Path $ComposeFile)) {
    Write-Error "Not found: $ComposeFile"
    exit 1
}

# .env 없으면 로컬용 기본값으로 생성
if (-not (Test-Path $EnvFile)) {
    Write-Host "Creating .env with local defaults..."
    @"
# Local full stack (do not commit secrets in prod)
POSTGRES_USER=local_pg
POSTGRES_PASSWORD=local_pg_pass
POSTGRES_DB=investment_portfolio
"@ | Set-Content -Path $EnvFile -Encoding UTF8
}
$env:POSTGRES_USER = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "local_pg" }
$env:POSTGRES_PASSWORD = if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { "local_pg_pass" }
$env:POSTGRES_DB = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "investment_portfolio" }

# Backend JAR: Dockerfile가 build/libs/*.jar 를 요구
$BackendDir = Join-Path $RootDir "investment-backend"
if (Test-Path $BackendDir) {
    $jarExists = Get-ChildItem -Path (Join-Path $BackendDir "build\libs\*.jar") -ErrorAction SilentlyContinue
    if (-not $jarExists) {
        Write-Host "Building backend JAR (bootJar)..."
        Push-Location $BackendDir
        try {
            & .\gradlew.bat bootJar --no-daemon -q
        } finally {
            Pop-Location
        }
    }
}

Write-Host "Starting local full stack (Oracle1 + Oracle2-edge + AWS API)..."
docker compose -f $ComposeFile up -d --build

Write-Host "Done. Services:"
docker compose -f $ComposeFile ps
Write-Host ""
Write-Host "Access: http://localhost (frontend), http://localhost/api (backend API)"
