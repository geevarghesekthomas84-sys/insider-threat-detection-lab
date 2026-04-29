# Final Report - Insider Threat Breach Response

## Document Information

| Field | Value |
|-------|-------|
| **Report Title** | Insider Threat Incident - Data Exfiltration by Privileged Employee |
| **Case ID** | IR-2024-001 |
| **Classification** | CONFIDENTIAL |
| **Date** | January 16, 2024 |
| **Prepared By** | SOC Team / DFIR Unit |
| **Distribution** | CISO, Legal, HR, Management |

---

## 1. Executive Summary

A privileged employee in the Finance Department conducted a deliberate, multi-stage data exfiltration attack on January 15, 2024. The insider accessed confidential financial reports, HR records containing PII, customer data, and intellectual property documents during non-business hours. Data was staged, archived, and copied to a USB device with additional attempts to upload to cloud storage. The attacker attempted to cover their tracks by clearing security logs and establishing persistence mechanisms.

**Impact**: Confidential data exposure affecting financial records, ~500 employee PII records, and customer payment information.

**Detection Time**: 36 minutes from initial access to first critical alert.

**Containment Time**: 8 minutes from critical alert to full containment.

---

## 2. Attack Summary

### Threat Actor Profile
- **Identity**: John Smith (jsmith), Senior Financial Analyst
- **Access Level**: Domain User, Finance share access, local admin on workstation
- **Motivation**: Suspected corporate espionage / competitor intelligence

### Attack Chain (Kill Chain)

| Phase | Time | Action | MITRE |
|-------|------|--------|-------|
| Access | 22:02 | RDP login after hours | T1078 |
| Discovery | 22:05 | Enumerated sensitive directories | T1083 |
| Collection | 22:08 | Read financial/HR/customer data | T1005 |
| Staging | 22:12 | Copied files, created ZIP archive | T1074.001, T1560.001 |
| Exfiltration | 22:18 | USB device connected, data copied | T1052.001 |
| Exfiltration | 22:22 | Attempted cloud upload | T1567.002 |
| Credential Access | 22:25 | LSASS memory access attempt | T1003.001 |
| Evasion | 22:31 | Security event log cleared | T1070.001 |
| Persistence | 22:34 | Scheduled task created | T1053.005 |

---

## 3. Detection Effectiveness

### Tools Performance

| Tool | Detection | Response |
|------|-----------|----------|
| **Wazuh** | 14 alerts generated, 5 critical | FIM + custom rules effective |
| **Sysmon** | Full process/network telemetry | Essential for credential access detection |
| **Splunk** | Correlation searches triggered | Multi-indicator scoring identified threat |
| **ELK** | Log enrichment with risk scoring | MITRE auto-tagging successful |

### Rule Performance
- **52 custom rules** deployed, **14 triggered** during incident
- **Zero false positives** on critical rules
- **Composite rule 100950** (file access + USB) provided highest confidence alert

---

## 4. Impact Assessment

| Category | Impact | Severity |
|----------|--------|----------|
| Financial Data | Q4 revenue reports accessed | HIGH |
| Employee PII | ~500 SSN/salary records | CRITICAL |
| Customer Data | Payment card information | CRITICAL |
| Intellectual Property | Trade secrets accessed | HIGH |
| Regulatory | GDPR, HIPAA, PCI-DSS exposure | CRITICAL |
| Reputation | Potential if data leaked | HIGH |

---

## 5. Containment & Remediation

### Immediate Actions Taken
1. ✅ User account disabled and password reset
2. ✅ Active sessions terminated
3. ✅ Workstation network isolated
4. ✅ USB storage disabled organization-wide
5. ✅ Evidence preserved with SHA256 integrity
6. ✅ Persistence mechanisms removed

### Long-term Recommendations

1. **Deploy Data Loss Prevention (DLP)** — Prevent unauthorized USB copies
2. **Implement UEBA** — User and Entity Behavior Analytics
3. **Enforce MFA for off-hours access** — Conditional access policies
4. **Block unauthorized cloud storage** — Web proxy/CASB
5. **PowerShell Constrained Language Mode** — Limit script capabilities
6. **Privileged Access Management** — Just-in-time access for sensitive data
7. **Regular insider threat training** — Security awareness program
8. **Data classification program** — Label and protect sensitive files
9. **Enhanced audit logging** — Expand Sysmon and Windows audit coverage
10. **Quarterly access reviews** — Verify least-privilege compliance

---

## 6. Indicators of Compromise

| Type | Value | Context |
|------|-------|---------|
| User | jsmith | Compromised insider account |
| IP | 192.168.56.10 | RDP source (Kali attack VM) |
| File | exfil_package_*.zip | Staged exfiltration archive |
| USB | USBSTOR registry entries | Removable storage used |
| Task | SystemHealthCheck_* | Persistence scheduled task |
| Registry | HKCU\...\Run\SystemUpdater_* | Persistence run key |
| Domain | drive.google.com | Cloud exfiltration target |
| Domain | mega.nz | Cloud exfiltration target |
| Domain | dropbox.com | Cloud exfiltration target |

---

## 7. Lessons Learned

The incident demonstrated the effectiveness of defense-in-depth monitoring but exposed gaps in preventive controls. Key takeaways:

1. **Detection works** — Multi-layer monitoring caught the attack within 36 minutes
2. **Prevention gaps** — No DLP or CASB to prevent data leaving the organization
3. **Logging is essential** — PowerShell and Sysmon logging were critical
4. **Composite rules matter** — Single alerts have low fidelity; correlated alerts caught the real threat
5. **IR automation needed** — Containment could be faster with SOAR playbooks

---

**Classification**: CONFIDENTIAL
**Distribution**: Limited to authorized personnel only
