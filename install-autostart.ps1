# Run this script as Administrator to register NanoClaw autostart
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$User = $env:USERNAME

$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ProjectRoot\startup-nanoclaw.ps1`""

$trigger = New-ScheduledTaskTrigger -AtLogOn -User $User

$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 15) `
    -RestartCount 2 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -StartWhenAvailable

$principal = New-ScheduledTaskPrincipal `
    -UserId $User `
    -LogonType Interactive `
    -RunLevel Highest

Register-ScheduledTask `
    -TaskName 'NanoClaw Autostart' `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Force

Write-Host "NanoClaw Autostart task registered for user: $User" -ForegroundColor Green
Write-Host "Script: $ProjectRoot\startup-nanoclaw.ps1" -ForegroundColor Cyan
