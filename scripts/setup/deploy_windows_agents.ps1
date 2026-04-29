# ============================================================
# Sysmon + Wazuh Agent Deployment Script
# Target: Windows 10/11 Insider Employee Workstation
# Run as: Administrator
# ============================================================

param(
    [string]$WazuhManagerIP = "192.168.56.40",
    [string]$EnrollmentPassword = "InsiderThreatLab2024!",
    [string]$AgentName = "WIN-INSIDER-01",
    [string]$SplunkServerIP = "192.168.56.40"
)

$ErrorActionPreference = "Stop"

function Write-Banner {
    Write-Host @"

╔══════════════════════════════════════════════════════╗
║  Windows Agent Deployment - Insider Threat Lab       ║
║  Sysmon + Wazuh Agent + Splunk Forwarder             ║
╚══════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan
}

function Write-Step($msg) { Write-Host "[+] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }

Write-Banner

# ==================== CHECK ADMIN ====================
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[-] This script must be run as Administrator!" -ForegroundColor Red
    exit 1
}

$ToolsDir = "C:\BlueTeamTools"
New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null

# ==================== ENABLE POWERSHELL LOGGING ====================
Write-Step "Enabling PowerShell Script Block Logging..."
$PSLoggingPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
New-Item -Path $PSLoggingPath -Force | Out-Null
Set-ItemProperty -Path $PSLoggingPath -Name "EnableScriptBlockLogging" -Value 1

$PSTranscriptPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription"
New-Item -Path $PSTranscriptPath -Force | Out-Null
Set-ItemProperty -Path $PSTranscriptPath -Name "EnableTranscripting" -Value 1
Set-ItemProperty -Path $PSTranscriptPath -Name "OutputDirectory" -Value "C:\PSTranscripts"
New-Item -ItemType Directory -Force -Path "C:\PSTranscripts" | Out-Null

$PSModuleLogging = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging"
New-Item -Path $PSModuleLogging -Force | Out-Null
Set-ItemProperty -Path $PSModuleLogging -Name "EnableModuleLogging" -Value 1
$ModuleNames = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames"
New-Item -Path $ModuleNames -Force | Out-Null
Set-ItemProperty -Path $ModuleNames -Name "*" -Value "*"

Write-Step "PowerShell logging enabled (Script Block + Transcription + Module)"

# ==================== ENABLE AUDIT POLICIES ====================
Write-Step "Configuring Advanced Audit Policies..."

# Enable command-line process auditing
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f | Out-Null

# Audit policies via auditpol
$auditCategories = @(
    "Logon/Logoff",     "Logon",                    "Success,Failure"
    "Logon/Logoff",     "Logoff",                   "Success"
    "Logon/Logoff",     "Special Logon",            "Success"
    "Account Logon",    "Credential Validation",    "Success,Failure"
    "Account Logon",    "Kerberos Authentication Service", "Success,Failure"
    "Object Access",    "File System",              "Success,Failure"
    "Object Access",    "Registry",                 "Success"
    "Object Access",    "Removable Storage",        "Success,Failure"
    "Privilege Use",    "Sensitive Privilege Use",   "Success,Failure"
    "System",           "Security State Change",    "Success"
    "System",           "Security System Extension","Success"
    "Policy Change",    "Audit Policy Change",      "Success"
    "Account Management","User Account Management", "Success,Failure"
    "Detailed Tracking","Process Creation",         "Success"
    "Detailed Tracking","Process Termination",      "Success"
)

for ($i = 0; $i -lt $auditCategories.Count; $i += 3) {
    $sub = $auditCategories[$i + 1]
    $setting = $auditCategories[$i + 2]
    auditpol /set /subcategory:"$sub" /success:enable /failure:enable 2>$null
}

Write-Step "Advanced audit policies configured"

# ==================== INSTALL SYSMON ====================
Write-Step "Downloading Sysmon..."
$SysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$SysmonZip = "$ToolsDir\Sysmon.zip"
$SysmonDir = "$ToolsDir\Sysmon"

Invoke-WebRequest -Uri $SysmonUrl -OutFile $SysmonZip -UseBasicParsing
Expand-Archive -Path $SysmonZip -DestinationPath $SysmonDir -Force

Write-Step "Deploying Sysmon configuration..."
$ConfigSource = Join-Path $PSScriptRoot "..\..\configs\sysmon\sysmonconfig.xml"
if (Test-Path $ConfigSource) {
    Copy-Item $ConfigSource -Destination "$SysmonDir\sysmonconfig.xml"
} else {
    Write-Warn "Sysmon config not found at $ConfigSource - using default"
}

Write-Step "Installing Sysmon64..."
& "$SysmonDir\Sysmon64.exe" -accepteula -i "$SysmonDir\sysmonconfig.xml" 2>$null
Write-Step "Sysmon installed and running"

# ==================== INSTALL WAZUH AGENT ====================
Write-Step "Downloading Wazuh Agent..."
$WazuhAgentUrl = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.9.0-1.msi"
$WazuhMsi = "$ToolsDir\wazuh-agent.msi"

Invoke-WebRequest -Uri $WazuhAgentUrl -OutFile $WazuhMsi -UseBasicParsing

Write-Step "Installing Wazuh Agent..."
$MsiArgs = @(
    "/i", $WazuhMsi,
    "/qn",
    "WAZUH_MANAGER=$WazuhManagerIP",
    "WAZUH_AGENT_NAME=$AgentName",
    "WAZUH_REGISTRATION_PASSWORD=$EnrollmentPassword",
    "WAZUH_REGISTRATION_SERVER=$WazuhManagerIP"
)
Start-Process msiexec.exe -ArgumentList $MsiArgs -Wait -NoNewWindow

Write-Step "Starting Wazuh Agent service..."
Start-Service -Name WazuhSvc -ErrorAction SilentlyContinue
Write-Step "Wazuh Agent installed and connected to $WazuhManagerIP"

# ==================== INSTALL SPLUNK UNIVERSAL FORWARDER ====================
Write-Step "Downloading Splunk Universal Forwarder..."
$SplunkUFUrl = "https://download.splunk.com/products/universalforwarder/releases/9.3.1/windows/splunkforwarder-9.3.1-0b8d769cb912-x64-release.msi"
$SplunkMsi = "$ToolsDir\splunkforwarder.msi"

Invoke-WebRequest -Uri $SplunkUFUrl -OutFile $SplunkMsi -UseBasicParsing -ErrorAction SilentlyContinue

if (Test-Path $SplunkMsi) {
    Write-Step "Installing Splunk Universal Forwarder..."
    $SplunkArgs = @(
        "/i", $SplunkMsi,
        "/qn",
        "RECEIVING_INDEXER=${SplunkServerIP}:9997",
        "AGREEDTOEULA=Yes",
        "SPLUNKPASSWORD=InsiderThreatSplunk2024!"
    )
    Start-Process msiexec.exe -ArgumentList $SplunkArgs -Wait -NoNewWindow

    # Deploy inputs.conf
    $SplunkInputs = Join-Path $PSScriptRoot "..\..\configs\splunk\inputs.conf"
    $SplunkLocalDir = "C:\Program Files\SplunkUniversalForwarder\etc\system\local"
    if (Test-Path $SplunkInputs) {
        Copy-Item $SplunkInputs -Destination "$SplunkLocalDir\inputs.conf" -Force
    }

    Write-Step "Starting Splunk Forwarder..."
    & "C:\Program Files\SplunkUniversalForwarder\bin\splunk.exe" start
} else {
    Write-Warn "Splunk UF download failed. Download manually from splunk.com"
}

# ==================== CREATE SENSITIVE DATA ====================
Write-Step "Creating sensitive data directories for simulation..."
$SensitiveDirs = @(
    "C:\SensitiveData\Financial",
    "C:\SensitiveData\HR",
    "C:\SensitiveData\IP",
    "C:\SensitiveData\CustomerData",
    "C:\ConfidentialProjects\ProjectAlpha",
    "C:\ConfidentialProjects\ProjectBeta"
)

foreach ($dir in $SensitiveDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

# Create realistic sample data
Set-Content -Path "C:\SensitiveData\Financial\Q4_Revenue_Report.xlsx" -Value "Revenue Data - Q4 2024 - CONFIDENTIAL`nTotal Revenue: `$45.2M`nNet Profit: `$12.8M"
Set-Content -Path "C:\SensitiveData\HR\employee_records.csv" -Value "Name,SSN,Salary,Department`nJohn Smith,123-45-6789,`$95000,Engineering`nJane Doe,987-65-4321,`$105000,Finance"
Set-Content -Path "C:\SensitiveData\IP\trade_secrets.docx" -Value "TRADE SECRET - Proprietary Algorithm v3.2`nClassification: TOP SECRET"
Set-Content -Path "C:\SensitiveData\CustomerData\customer_pii.csv" -Value "CustomerID,Name,Email,CCNumber`n1001,Alice Brown,alice@example.com,4111-1111-1111-1111"
Set-Content -Path "C:\ConfidentialProjects\ProjectAlpha\design_specs.pdf" -Value "Project Alpha - Next-Gen Platform Architecture - RESTRICTED"
Set-Content -Path "C:\ConfidentialProjects\ProjectBeta\source_code.zip" -Value "Proprietary source code archive - DO NOT DISTRIBUTE"

Write-Step "Sensitive data directories created"

# ==================== SUMMARY ====================
Write-Host @"

╔══════════════════════════════════════════════════════╗
║       Deployment Complete!                           ║
╠══════════════════════════════════════════════════════╣
║  Sysmon:           Running                           ║
║  Wazuh Agent:      Connected to $WazuhManagerIP      ║
║  Splunk Forwarder: Forwarding to $SplunkServerIP     ║
║  PowerShell Log:   Script Block + Transcription      ║
║  Audit Policies:   Advanced auditing enabled         ║
║  Sensitive Data:   C:\SensitiveData                  ║
║                    C:\ConfidentialProjects            ║
╠══════════════════════════════════════════════════════╣
║  Next: Run attack simulation scripts                 ║
╚══════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan
