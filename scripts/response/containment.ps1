# Incident Response - Containment Script
# Run as: Administrator on target machine
param(
    [Parameter(Mandatory=$true)][string]$TargetUser,
    [string]$TargetComputer = $env:COMPUTERNAME,
    [switch]$DisableAccount, [switch]$IsolateNetwork,
    [switch]$KillSessions, [switch]$BlockUSB,
    [switch]$CollectEvidence, [switch]$All
)

$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$IRDir = "C:\IncidentResponse\IR_$Timestamp"
New-Item -ItemType Directory -Force -Path $IRDir | Out-Null
function Write-IR($a,$m) {
    $e = "[$(Get-Date -Format 'HH:mm:ss')] [$a] $m"
    Write-Host $e -ForegroundColor Cyan
    Add-Content "$IRDir\ir.log" -Value $e
}

if ($All) { $DisableAccount=$true;$IsolateNetwork=$true;$KillSessions=$true;$BlockUSB=$true;$CollectEvidence=$true }

# 1. Disable Account
if ($DisableAccount) {
    Write-IR "CONTAIN" "Disabling $TargetUser..."
    try {
        Import-Module ActiveDirectory -EA Stop
        Disable-ADAccount -Identity $TargetUser
        $pw = ConvertTo-SecureString "IR_Lock_$(Get-Random)!" -AsPlainText -Force
        Set-ADAccountPassword -Identity $TargetUser -NewPassword $pw -Reset
        Write-IR "CONTAIN" "AD account disabled + password reset"
    } catch { net user $TargetUser /active:no 2>$null; Write-IR "CONTAIN" "Local account disabled" }
}

# 2. Kill Sessions
if ($KillSessions) {
    Write-IR "CONTAIN" "Terminating sessions..."
    query user /server:$TargetComputer 2>$null | ForEach-Object {
        if ($_ -match $TargetUser) { $sid = ($_ -split '\s+')[3]; logoff $sid /server:$TargetComputer 2>$null }
    }
}

# 3. Network Isolation
if ($IsolateNetwork) {
    Write-IR "CONTAIN" "Applying network isolation..."
    New-NetFirewallRule -DisplayName "IR-Block-All-Outbound" -Direction Outbound -Action Block -RemoteAddress "0.0.0.0/0" -Enabled True 2>$null
    New-NetFirewallRule -DisplayName "IR-Allow-SOC" -Direction Outbound -Action Allow -RemoteAddress "192.168.56.40" -Enabled True 2>$null
    Write-IR "CONTAIN" "Network isolated - SOC server only"
}

# 4. Block USB
if ($BlockUSB) {
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name Start -Value 4
    Write-IR "CONTAIN" "USB storage disabled"
}

# 5. Evidence Collection
if ($CollectEvidence) {
    $ev = "$IRDir\evidence"; New-Item -ItemType Directory -Force -Path $ev | Out-Null
    Get-Process | Export-Csv "$ev\processes.csv" -NoTypeInformation
    Get-NetTCPConnection | Export-Csv "$ev\netconn.csv" -NoTypeInformation
    Get-DnsClientCache | Export-Csv "$ev\dns_cache.csv" -NoTypeInformation
    Get-ScheduledTask | Where-Object State -ne Disabled | Export-Csv "$ev\tasks.csv" -NoTypeInformation
    Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\*\*" 2>$null | Export-Csv "$ev\usb.csv" -NoTypeInformation
    wevtutil epl Security "$ev\Security.evtx" 2>$null
    wevtutil epl System "$ev\System.evtx" 2>$null
    wevtutil epl "Microsoft-Windows-Sysmon/Operational" "$ev\Sysmon.evtx" 2>$null
    Get-ChildItem $ev -File | ForEach-Object { $h=Get-FileHash $_.FullName -Algorithm SHA256; "$($h.Hash) $($_.Name)" } | Out-File "$ev\hashes.sha256"
    Write-IR "EVIDENCE" "Evidence collected + hashed at $ev"
}

Write-Host "`n[+] IR containment complete. Case: IR-$Timestamp" -ForegroundColor Green
Write-Host "[+] Evidence: $IRDir" -ForegroundColor Green
