# NanoClaw Startup Script - waits for network + Docker then starts NanoClaw
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $ProjectRoot "logs\startup.log"

New-Item -ItemType Directory -Force -Path (Join-Path $ProjectRoot "logs") | Out-Null

function Log($msg) {
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$ts $msg" | Out-File -FilePath $LogFile -Append -Encoding utf8
}

Log "Startup script launched"

# Wait for Docker Desktop to be ready (max 3 minutes)
$maxWait = 180
$waited = 0
Log "Waiting for Docker..."
while ($waited -lt $maxWait) {
    try {
        $result = & docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            Log "Docker is ready"
            break
        }
    } catch {}
    Start-Sleep -Seconds 5
    $waited += 5
}

if ($waited -ge $maxWait) {
    Log "WARNING: Docker not ready after $maxWait seconds, starting NanoClaw anyway"
}

# Wait for internet connectivity (max 3 minutes)
$maxWait = 180
$waited = 0
Log "Waiting for internet connectivity..."
while ($waited -lt $maxWait) {
    try {
        $null = [System.Net.Dns]::GetHostAddresses("web.whatsapp.com")
        Log "Network is ready"
        break
    } catch {}
    Start-Sleep -Seconds 5
    $waited += 5
}

if ($waited -ge $maxWait) {
    Log "WARNING: Network not ready after $maxWait seconds, starting NanoClaw anyway"
}

# Ensure dependencies are installed
Log "Running npm install..."
$npmResult = & npm install --prefix "$ProjectRoot" 2>&1
Log "npm install done: $($npmResult | Select-Object -Last 1)"

# Start NanoClaw
Log "Starting NanoClaw..."
& "$ProjectRoot\start-nanoclaw.ps1"
Log "NanoClaw start script completed"
