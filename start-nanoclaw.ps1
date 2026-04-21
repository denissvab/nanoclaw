$ProjectRoot = $PSScriptRoot
$Node = "C:\Program Files\nodejs\node.exe"
$Script = Join-Path $ProjectRoot "dist\index.js"
$LogFile = Join-Path $ProjectRoot "logs\nanoclaw.log"
$ErrFile = Join-Path $ProjectRoot "logs\nanoclaw.error.log"
$PidFile = Join-Path $ProjectRoot "nanoclaw.pid"

# Stop existing instance
if (Test-Path $PidFile) {
    $oldPid = Get-Content $PidFile
    Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Ensure logs dir
New-Item -ItemType Directory -Force -Path (Join-Path $ProjectRoot "logs") | Out-Null

# Start process
$proc = Start-Process -FilePath $Node -ArgumentList $Script `
    -WorkingDirectory $ProjectRoot `
    -RedirectStandardOutput $LogFile `
    -RedirectStandardError $ErrFile `
    -NoNewWindow -PassThru

$proc.Id | Out-File -FilePath $PidFile -Encoding ascii

Write-Host "NanoClaw started (PID $($proc.Id))"
Write-Host "Logs: logs\nanoclaw.log"
Write-Host "Stop: .\stop-nanoclaw.ps1"
