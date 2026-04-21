$ProjectRoot = $PSScriptRoot
$PidFile = Join-Path $ProjectRoot "nanoclaw.pid"

if (Test-Path $PidFile) {
    $pid = Get-Content $PidFile
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    Write-Host "NanoClaw stopped (PID $pid)"
} else {
    # Fallback: find by port 3001
    $conn = Get-NetTCPConnection -LocalPort 3001 -ErrorAction SilentlyContinue
    if ($conn) {
        Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
        Write-Host "NanoClaw stopped (PID $($conn.OwningProcess))"
    } else {
        Write-Host "NanoClaw is not running"
    }
}
