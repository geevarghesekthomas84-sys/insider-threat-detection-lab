# Attack Simulation Guide

## Overview
The attack simulation script (`scripts/attack-simulation/run_all_attacks.ps1`) executes a 9-phase insider threat attack chain.

## Usage
```powershell
# Run all phases
.\run_all_attacks.ps1 -AllAttacks

# Run specific phases
.\run_all_attacks.ps1 -FileAccess -USBExfil -ClearLogs

# With delay between phases
.\run_all_attacks.ps1 -AllAttacks -DelaySeconds 10
```

## Attack Phases

| Phase | Technique | MITRE | Expected Alerts |
|-------|-----------|-------|-----------------|
| 1. File Access | Read sensitive dirs | T1005, T1083 | FIM alerts (100200) |
| 2. Data Staging | Copy + archive files | T1074.001, T1560.001 | PS staging alert (100303) |
| 3. USB Exfiltration | Copy to removable | T1052.001 | USB alerts (100100-103) |
| 4. Cloud Upload | DNS + curl to cloud | T1567.002 | Cloud alert (100701) |
| 5. Suspicious PS | Encoded, bypass, download | T1059.001 | PS alerts (100300-302) |
| 6. Persistence | Sched task + Run key | T1053.005, T1547.001 | Persistence (100800) |
| 7. Credential Harvest | LSASS + file search | T1003, T1552 | Cred alerts (100900) |
| 8. Log Clearing | wevtutil cl | T1070.001 | Log cleared (100400) |
| 9. Log Tampering | Timestomp + delete staging | T1070 | FIM + Sysmon alerts |

## Expected Results
- **14+ Wazuh alerts** generated
- **5 critical severity** events
- **Splunk correlation** triggers composite score
- **ELK risk score** exceeds threshold
- All events visible in SOC Dashboard
