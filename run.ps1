<#
.SYNOPSIS
    Starts CampusAI Database and PHP Server, then opens the browser.
    Fully compatible with VS Code PowerShell Terminal and VS Code Tasks.
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Join-Path $ScriptDir "chetan-project"

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "       CAMPUSAI - SMART COLLEGE ASSISTANT          " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# 1. Locate PHP
$PhpExe = Join-Path $ProjectDir "php\php.exe"
if (-not (Test-Path $PhpExe)) {
    if (Test-Path "C:\xampp\php\php.exe") {
        $PhpExe = "C:\xampp\php\php.exe"
    } else {
        $PhpCmd = Get-Command php -ErrorAction SilentlyContinue
        if ($PhpCmd) {
            $PhpExe = $PhpCmd.Source
        } else {
            Write-Host "[ERROR] PHP not found in $ProjectDir\php or C:\xampp\php." -ForegroundColor Red
            exit 1
        }
    }
}
Write-Host "[INFO] Using PHP: $PhpExe" -ForegroundColor Green

# 2. Check and start MariaDB on port 3307
$MysqldExe = Join-Path $ProjectDir "mysql\bin\mysqld.exe"
$MysqlData = Join-Path $ProjectDir "mysql\data"
$DbListening = $false
try {
    $tcp = Get-NetTCPConnection -LocalPort 3307 -State Listen -ErrorAction SilentlyContinue
    if ($tcp) { $DbListening = $true }
} catch {
    $conn = Test-NetConnection -ComputerName 127.0.0.1 -Port 3307 -WarningAction SilentlyContinue
    if ($conn.TcpTestSucceeded) { $DbListening = $true }
}

if ($DbListening) {
    Write-Host "[INFO] MariaDB is already running on port 3307." -ForegroundColor Green
} elseif (Test-Path $MysqldExe) {
    Write-Host "[INFO] Starting portable MariaDB on port 3307..." -ForegroundColor Yellow
    Start-Process -FilePath $MysqldExe -ArgumentList "--port=3307 --datadir=`"$MysqlData`" --console" -WindowStyle Hidden
    Start-Sleep -Seconds 3
    Write-Host "[INFO] MariaDB started." -ForegroundColor Green
} else {
    Write-Host "[WARNING] MariaDB binary not found at $MysqldExe. Using existing MySQL if configured." -ForegroundColor Yellow
}

# 3. Check and start PHP server on port 8000
$ServerListening = $false
try {
    $tcp8000 = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue
    if ($tcp8000) { $ServerListening = $true }
} catch {
    $conn8000 = Test-NetConnection -ComputerName 127.0.0.1 -Port 8000 -WarningAction SilentlyContinue
    if ($conn8000.TcpTestSucceeded) { $ServerListening = $true }
}

if ($ServerListening) {
    Write-Host "[INFO] CampusAI PHP Server is already running on port 8000." -ForegroundColor Green
} else {
    Write-Host "[INFO] Starting PHP Server on port 8000..." -ForegroundColor Yellow
    Start-Process -FilePath $PhpExe -ArgumentList "-S localhost:8000" -WorkingDirectory $ProjectDir -WindowStyle Hidden
    Start-Sleep -Seconds 2
    Write-Host "[INFO] PHP Server started." -ForegroundColor Green
}

# 4. Open Application in Default Browser
$AppUrl = "http://localhost:8000/login.php"
Write-Host "[INFO] Opening browser at $AppUrl..." -ForegroundColor Cyan
Start-Process $AppUrl

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host " CampusAI is RUNNING! You can now use the website. " -ForegroundColor Green
Write-Host " To stop: run .\stop.bat or .\stop.ps1               " -ForegroundColor Yellow
Write-Host "===================================================" -ForegroundColor Cyan
