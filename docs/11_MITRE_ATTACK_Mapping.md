# MITRE ATT&CK Mapping - Insider Threat Detection Lab

## Coverage Matrix

| Tactic | ID | Technique | Detection Method | Rule ID | Status |
|--------|-----|-----------|------------------|---------|--------|
| **Initial Access** | T1078 | Valid Accounts | After-hours login correlation | 100500-100502 | ✅ Detected |
| **Execution** | T1059.001 | PowerShell | Script block logging + Sysmon | 100300-100304 | ✅ Detected |
| **Execution** | T1059.003 | Windows Command Shell | Sysmon process create | Sysmon EID 1 | ✅ Covered |
| **Persistence** | T1053.005 | Scheduled Task | Security event 4698 | 100800 | ✅ Detected |
| **Persistence** | T1547.001 | Registry Run Keys | Sysmon EID 13 + FIM | FIM + Sysmon | ✅ Covered |
| **Priv Escalation** | T1078 | Valid Accounts | Privilege logon (4672) | 100602 | ✅ Detected |
| **Priv Escalation** | T1548.002 | UAC Bypass | Sysmon process monitoring | Sysmon EID 1 | 🟡 Partial |
| **Defense Evasion** | T1070.001 | Clear Windows Event Logs | Security event 1102 | 100400-100402 | ✅ Detected |
| **Defense Evasion** | T1070.006 | Timestomp | Sysmon EID 2 | Sysmon | ✅ Covered |
| **Defense Evasion** | T1027 | Obfuscated Files | PS encoded command detection | 100302 | ✅ Detected |
| **Defense Evasion** | T1562.001 | Disable Security Tools | PS Defender disable pattern | 100304 | ✅ Detected |
| **Credential Access** | T1003.001 | LSASS Memory | Sysmon EID 10 + rule | 100900-100901 | ✅ Detected |
| **Credential Access** | T1552.001 | Credentials In Files | PS file search pattern | 100303 | 🟡 Partial |
| **Discovery** | T1083 | File and Directory Discovery | PS Get-ChildItem monitoring | Sysmon EID 1 | ✅ Covered |
| **Discovery** | T1082 | System Info Discovery | systeminfo execution | Sysmon EID 1 | ✅ Covered |
| **Discovery** | T1016 | System Network Config | ipconfig/netstat monitoring | Sysmon EID 1 | ✅ Covered |
| **Discovery** | T1087 | Account Discovery | net user command monitoring | Sysmon EID 1 | ✅ Covered |
| **Lateral Movement** | T1021.001 | Remote Desktop Protocol | RDP logon (Type 10) + off-hours | 100600 | ✅ Detected |
| **Lateral Movement** | T1021.002 | SMB/Windows Admin Shares | Network logon (Type 3) + admin | 100601 | ✅ Detected |
| **Collection** | T1005 | Data from Local System | FIM on sensitive dirs | 100200-100202 | ✅ Detected |
| **Collection** | T1074.001 | Local Data Staging | PS Copy-Item monitoring | 100303 | ✅ Detected |
| **Collection** | T1560.001 | Archive Collected Data | Compress-Archive / 7z detection | 100702 | ✅ Detected |
| **Exfiltration** | T1052.001 | Exfil Over USB | USB device + registry monitoring | 100100-100103 | ✅ Detected |
| **Exfiltration** | T1567.002 | Exfil to Cloud Storage | DNS + network connection monitoring | 100700-100701 | ✅ Detected |
| **Exfiltration** | T1048 | Exfil Over Alt Protocol | certutil/bitsadmin monitoring | 100700 | ✅ Detected |
| **Command & Control** | T1105 | Ingress Tool Transfer | LOLBin download detection | 100700 | 🟡 Partial |

## Coverage Statistics

- **Total Techniques Mapped**: 26
- **Fully Detected**: 20 (77%)
- **Covered (logged but no custom rule)**: 3 (12%)
- **Partially Covered**: 3 (12%)
- **Tactics Covered**: 10/14 (71%)

## Detection Layers

```
Layer 1: Windows Event Logs    → Authentication, Account Management
Layer 2: Sysmon                → Process, Network, File, Registry
Layer 3: PowerShell Logging    → Script Block, Transcription, Module
Layer 4: Wazuh FIM             → File Integrity, Registry Changes
Layer 5: Wazuh Custom Rules    → Insider Threat Specific (100xxx)
Layer 6: Splunk Correlations   → Multi-event, Behavioral Analysis
Layer 7: SIGMA Rules           → Vendor-agnostic Detection
Layer 8: Logstash Enrichment   → Risk Scoring, MITRE Tagging
```
