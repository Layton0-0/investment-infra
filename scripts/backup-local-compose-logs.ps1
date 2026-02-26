# 로컬 Docker Compose 풀스택 로그 일일 백업
# 사용: .\scripts\backup-local-compose-logs.ps1  (investment-infra 또는 프로젝트 루트에서 실행)
# 권장: Windows 작업 스케줄러로 매일 새벽 03:00 KST 실행 (부하 적은 시간). register-log-backup-task.ps1 참조.
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir = Split-Path -Parent $ScriptDir
$ComposeFile = Join-Path $InfraDir "docker-compose.local-full.yml"
$BackupRoot = Join-Path $InfraDir "logs-backup"
$RetentionDays = 30

# docker-compose.local-full.yml 에 정의된 서비스명 (volumes/networks 제외)
$Services = @(
    "timescaledb",
    "redis",
    "backend",
    "prediction-service",
    "data-collector",
    "frontend",
    "nginx"
)

Set-Location $InfraDir
if (-not (Test-Path $ComposeFile)) {
    Write-Error "Compose file not found: $ComposeFile"
    exit 1
}

$Today = (Get-Date).ToLocalTime().ToString("yyyyMMdd")
$TodayDir = Join-Path $BackupRoot $Today
$LogPath = Join-Path $BackupRoot "backup.log"

function Write-BackupLog {
    param([string]$Message)
    $Line = "{0:yyyy-MM-dd HH:mm:ss} {1}" -f (Get-Date), $Message
    Add-Content -Path $LogPath -Value $Line -Encoding UTF8 -ErrorAction SilentlyContinue
    Write-Host $Line
}

if (-not (Test-Path $TodayDir)) {
    New-Item -ItemType Directory -Path $TodayDir -Force | Out-Null
}

Write-BackupLog "Backup started: $TodayDir"

# 현재 디렉터리(InfraDir) 기준 상대 경로로 저장. cmd /c 리다이렉트 사용
$RelBackupDir = "logs-backup\$Today"
foreach ($svc in $Services) {
    $relLog = "$RelBackupDir\$svc.log"
    $outFile = Join-Path $InfraDir $relLog
    try {
        $redirectCmd = "docker compose -f docker-compose.local-full.yml logs --no-log-prefix $svc > `"$relLog`" 2>&1"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $redirectCmd -WorkingDirectory $InfraDir -NoNewWindow -Wait
        $size = (Get-Item $outFile -ErrorAction SilentlyContinue).Length
        Write-BackupLog "OK: $svc ($size bytes)"
    }
    catch {
        Write-BackupLog "ERROR: $svc - $_"
    }
}

# 보관 일수 초과 분 삭제 (선택)
$Cutoff = (Get-Date).AddDays(-$RetentionDays)
Get-ChildItem -Path $BackupRoot -Directory -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match '^\d{8}$' -and [datetime]::ParseExact($_.Name, "yyyyMMdd", $null) -lt $Cutoff
} | ForEach-Object {
    Remove-Item -Path $_.FullName -Recurse -Force
    Write-BackupLog "Purged old backup: $($_.Name)"
}

Write-BackupLog "Backup finished."
