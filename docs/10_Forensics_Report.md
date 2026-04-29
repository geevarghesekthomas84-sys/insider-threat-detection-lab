# Digital Forensics Report

## Case: IR-2024-001 — Insider Data Exfiltration

### Evidence Collection Summary

| # | Evidence Item | Type | SHA256 Hash | Collection Time | Method |
|---|--------------|------|-------------|-----------------|--------|
| 1 | Security.evtx | Event Log | a3f2c1d4e5...8b4e | 22:40:00 | wevtutil epl |
| 2 | Sysmon.evtx | Event Log | b7d4e2f3a1...9c3f | 22:40:05 | wevtutil epl |
| 3 | PowerShell.evtx | Event Log | c5a8f3b2d4...1d2e | 22:40:10 | wevtutil epl |
| 4 | processes.csv | Volatile | d9b1c4e5f2...7e5a | 22:41:00 | Get-Process |
| 5 | netconn.csv | Volatile | e2f6a8b3c4...4b9c | 22:41:05 | Get-NetTCPConnection |
| 6 | dns_cache.csv | Volatile | f4c3d7a8b2...6a8b | 22:41:10 | Get-DnsClientCache |
| 7 | usb_history.csv | Registry | 17e5b9c4d2...3c2d | 22:42:00 | Registry export |
| 8 | ps_history.txt | User Artifact | 28a4c6d7e3...5f1e | 22:42:30 | File copy |
| 9 | exfil_package.zip | Malware/Tool | 39d7e2f4a5...8a4b | 22:43:00 | File seizure |

### Chain of Custody

All evidence items were collected by SOC Analyst (SOC-01), hashed at time of collection, and stored in the secure evidence locker at `C:\IncidentResponse\IR-2024-001\evidence\`. Evidence integrity verified via SHA256 hash comparison.

### Key Forensic Findings

#### 1. Authentication Analysis
- **Event 4624** (Logon Type 10): RDP session from 192.168.56.10 at 22:02
- **No failed logins** — attacker used valid credentials
- **Event 4672**: Special privileges assigned at logon

#### 2. File Access Analysis (Sysmon + FIM)
- 6 sensitive files accessed within 3-minute window
- Files read via `Get-Content` PowerShell cmdlet
- Recursive directory listing preceded file access

#### 3. Data Staging
- Files copied to `%TEMP%\staging_*` directory
- `Compress-Archive` used to create ZIP archive
- Archive size: ~2.4 KB (simulated data)

#### 4. Exfiltration Vectors
- **USB**: USBSTOR registry entry created at 22:18
- **Cloud**: DNS queries to 6 cloud storage domains
- **certutil**: LOLBin used for data transfer testing

#### 5. Anti-Forensics
- Security event log cleared at 22:31 (Event 1102)
- File timestamps modified (timestomping) on archive
- Staging directory deleted after archiving

#### 6. Persistence
- Scheduled task `SystemHealthCheck_*` created at 3:00 AM
- Registry Run key `SystemUpdater_*` added to HKCU

### Tools Used for Analysis
- Wazuh Manager 4.9.0
- Splunk Enterprise 9.3.1
- ELK Stack 8.15.0
- Sysmon 15.x
- Python IOC Extraction Tool (custom)

### Conclusion
The forensic evidence conclusively shows intentional, unauthorized access and exfiltration of sensitive corporate data by user jsmith. The attack was methodical, following a clear progression from access through collection, exfiltration, and attempted evidence destruction. All evidence has been preserved with cryptographic integrity verification.
