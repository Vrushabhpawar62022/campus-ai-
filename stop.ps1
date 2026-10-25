<#
.SYNOPSIS
    Stops CampusAI PHP Server (Port 8000) and MariaDB (Port 3307).
#>

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "       STOPPING CAMPUSAI SERVICES                  " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# 1. Stop Port 8000 (PHP Server)
$p8000 = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue
if ($p8000) {
    $pid8000 = $p8000.OwningProcess | Select-Object -Unique
    foreach ($p in $pid8000) {
        Write-Host "[INFO] Stopping PHP Server (PID: $p)..." -ForegroundColor Yellow
        Stop-Process -Id $p -Force -ErrorAction SilentlyContinue
    }
    Write-Host "[INFO] CampusAI PHP Server stopped." -ForegroundColor Green
} else {
    Write-Host "[INFO] No server running on port 8000." -ForegroundColor Gray
}

# 2. Stop Port 3307 (MariaDB)
$p3307 = Get-NetTCPConnection -LocalPort 3307 -State Listen -ErrorAction SilentlyContinue
if ($p3307) {
    $pid3307 = $p3307.OwningProcess | Select-Object -Unique
    foreach ($p in $pid3307) {
        Write-Host "[INFO] Stopping MariaDB (PID: $p)..." -ForegroundColor Yellow
        Stop-Process -Id $p -Force -ErrorAction SilentlyContinue
    }
    Write-Host "[INFO] MariaDB stopped." -ForegroundColor Green
} else {
    Write-Host "[INFO] No MariaDB running on port 3307." -ForegroundColor Gray
}

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host " All CampusAI services stopped.                     " -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan
