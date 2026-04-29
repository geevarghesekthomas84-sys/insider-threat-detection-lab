# Incident Response Playbook - Insider Threat

## IR Case: IR-2024-001 — Insider Data Exfiltration

### Executive Summary

On **January 15, 2024 at 22:02 UTC**, Wazuh SIEM generated multiple high-severity alerts indicating a privileged employee (**jsmith**) was accessing sensitive financial and HR data outside business hours. Investigation revealed a coordinated data exfiltration attempt involving USB storage, cloud upload attempts, credential harvesting, and log tampering.

---

## Phase 1: Detection

### Initial Alert Triggers

| Time | Rule ID | Alert | Severity |
|------|---------|-------|----------|
| 22:02 | 100500 | After-hours login (RDP) | HIGH |
| 22:08 | 100200 | FIM: Sensitive file modified | MEDIUM |
| 22:18 | 100101 | USB device connected off-hours | HIGH |
| 22:22 | 100701 | Cloud storage upload attempt | CRITICAL |
| 22:25 | 100900 | Credential dumping tool detected | CRITICAL |
| 22:31 | 100400 | Security audit log cleared | CRITICAL |
| 22:34 | 100950 | Composite: File access + USB = Exfiltration | CRITICAL |

### Detection Sources
- **Wazuh FIM** — File modifications in `C:\SensitiveData`
- **Sysmon Event 1** — Process creation (PowerShell encoded commands)
- **Sysmon Event 10** — LSASS memory access
- **Windows Security Log** — Event 1102 (audit log cleared)
- **Splunk Correlation** — Multi-indicator insider threat score

---

## Phase 2: Triage & Analysis

### Severity Assessment: **CRITICAL**

| Factor | Assessment |
|--------|-----------|
| Data Classification | Confidential (Financial, HR PII) |
| Scope | Single user, multiple data sources |
| Business Impact | High — PII exposure, IP theft risk |
| Urgency | Immediate — Active exfiltration in progress |
| Regulatory Impact | GDPR, HIPAA, SOX potential violations |

### Initial Scope
- **Affected User**: jsmith (John Smith, Finance Department)
- **Affected Systems**: WIN-INSIDER-01 (192.168.56.20)
- **Affected Data**: Financial reports, HR records, customer PII, IP documents
- **Attack Vector**: Insider abuse of valid credentials

---

## Phase 3: Investigation

### Timeline Reconstruction

```
22:02  → RDP login from 192.168.56.10 (after-hours)
22:05  → File/directory enumeration of sensitive paths
22:08  → Read financial reports, HR records, customer PII
22:12  → Files staged in %TEMP% and compressed to ZIP
22:18  → USB storage device connected
22:19  → Archive copied to USB device
22:22  → DNS queries to cloud storage (Google Drive, Dropbox, Mega)
22:25  → LSASS memory access (credential harvesting attempt)
22:28  → Encoded PowerShell and download cradle execution
22:31  → Security audit log cleared (anti-forensics)
22:34  → Scheduled task created for persistence
```

### MITRE ATT&CK Mapping

| Tactic | Technique | Evidence |
|--------|-----------|----------|
| Initial Access | T1078 Valid Accounts | After-hours RDP login |
| Execution | T1059.001 PowerShell | Encoded command execution |
| Persistence | T1053.005 Scheduled Task | Task "SystemHealthCheck" |
| Defense Evasion | T1070.001 Clear Event Logs | Security log cleared |
| Credential Access | T1003.001 LSASS Memory | Process access to lsass.exe |
| Discovery | T1083 File Discovery | Recursive directory listing |
| Collection | T1005 Data from Local System | Sensitive file reads |
| Collection | T1560.001 Archive via Utility | Compress-Archive usage |
| Exfiltration | T1052.001 Exfil Over USB | USB copy detected |
| Exfiltration | T1567.002 Exfil to Cloud | Cloud DNS queries |

---

## Phase 4: Containment

### Immediate Actions (Executed)

```powershell
# 1. Disable user account
.\scripts\response\containment.ps1 -TargetUser jsmith -All
```

- [x] User account **disabled** in Active Directory
- [x] Password **reset** to prevent cached credential usage
- [x] Active sessions **terminated** on WIN-INSIDER-01
- [x] Network **isolated** — outbound blocked except SOC server
- [x] USB storage **disabled** via registry
- [x] Evidence **collected** and hashed (SHA256)

### Short-term Containment
- [x] Removed jsmith from all privileged groups
- [x] Revoked VPN access
- [x] Blocked source IP 192.168.56.10 at firewall
- [x] Preserved volatile evidence before reboot

---

## Phase 5: Eradication

- [ ] Remove scheduled task `SystemHealthCheck_*`
- [ ] Remove registry Run key `SystemUpdater_*`
- [ ] Audit all accounts for unauthorized modifications
- [ ] Scan for additional persistence mechanisms
- [ ] Verify no lateral movement to other systems
- [ ] Reset passwords for all accounts jsmith had access to

---

## Phase 6: Recovery

- [ ] Re-enable USB storage with DLP policy
- [ ] Restore network access with enhanced monitoring
- [ ] Verify data integrity of sensitive files
- [ ] Deploy additional detection rules
- [ ] Enable enhanced logging on all endpoints
- [ ] Conduct vulnerability assessment

---

## Phase 7: Lessons Learned

### Gaps Identified
1. No DLP solution to prevent USB data copy
2. Cloud storage not blocked at proxy level
3. After-hours access not requiring MFA
4. PowerShell logging was not enabled prior
5. No behavioral analytics (UEBA) in place

### Recommendations
1. Deploy USB DLP with allowlisting
2. Block unauthorized cloud storage at web proxy
3. Implement conditional access with MFA for off-hours
4. Enable PowerShell constrained language mode
5. Deploy UEBA solution for behavioral anomaly detection
6. Implement data classification and labeling
7. Conduct regular insider threat awareness training

---

## Evidence Preservation

All evidence collected with SHA256 integrity hashes. Chain of custody maintained.

| Evidence | Location | Hash |
|----------|----------|------|
| Security.evtx | IR case folder | Verified |
| Sysmon.evtx | IR case folder | Verified |
| processes.csv | IR case folder | Verified |
| network_connections.csv | IR case folder | Verified |
| usb_history.csv | IR case folder | Verified |
| exfil_package.zip | IR case folder | Verified |

**Case Status**: CONTAINMENT COMPLETE — Pending eradication and recovery.
