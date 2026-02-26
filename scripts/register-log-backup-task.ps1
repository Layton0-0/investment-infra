# Windows 작업 스케줄러에 "로컬 Docker Compose 로그 백업" 등록
# 매일 새벽 03:00 (KST, 부하 적은 시간) 실행. PC 재시작 후에도 작업은 유지됨.
# 관리자 권한 필요: PowerShell "관리자 권한으로 실행" 후 .\scripts\register-log-backup-task.ps1
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir = Split-Path -Parent $ScriptDir
$BackupScript = Join-Path $ScriptDir "backup-local-compose-logs.ps1"
$TaskName = "Investment-Local-Compose-LogBackup"
# 03:00 KST. Windows 작업 스케줄러는 시스템 로컬 시간 사용 (사용자 PC가 KST면 03:00)
$RunAt = "03:00"

if (-not (Test-Path $BackupScript)) {
    Write-Error "Backup script not found: $BackupScript"
    exit 1
}

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$BackupScript`"" -WorkingDirectory $InfraDir
$Trigger = New-ScheduledTaskTrigger -Daily -At $RunAt
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Force | Out-Null
Write-Host "Registered scheduled task: $TaskName"
Write-Host "  Run daily at $RunAt (local time). Script: $BackupScript"
Write-Host "  To remove: Unregister-ScheduledTask -TaskName $TaskName"
