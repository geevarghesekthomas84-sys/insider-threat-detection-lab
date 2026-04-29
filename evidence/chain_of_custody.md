# Evidence / Chain of Custody

## Case: IR-2024-001

### Chain of Custody Log

| Date | Time | Action | Item | Handler | Hash Verified |
|------|------|--------|------|---------|---------------|
| 2024-01-15 | 22:40 | Collected | Security.evtx | SOC-01 | ✓ |
| 2024-01-15 | 22:40 | Collected | Sysmon.evtx | SOC-01 | ✓ |
| 2024-01-15 | 22:40 | Collected | PowerShell.evtx | SOC-01 | ✓ |
| 2024-01-15 | 22:41 | Collected | processes.csv | SOC-01 | ✓ |
| 2024-01-15 | 22:41 | Collected | netconn.csv | SOC-01 | ✓ |
| 2024-01-15 | 22:41 | Collected | dns_cache.csv | SOC-01 | ✓ |
| 2024-01-15 | 22:42 | Collected | usb_history.csv | SOC-01 | ✓ |
| 2024-01-15 | 22:42 | Collected | ps_history.txt | SOC-01 | ✓ |
| 2024-01-15 | 22:43 | Seized | exfil_package.zip | SOC-01 | ✓ |
| 2024-01-15 | 22:45 | Transferred | All items | SOC-01→DFIR | ✓ |

### Storage
All evidence stored in secure evidence locker with restricted access.
Evidence integrity continuously verified via SHA256 checksums.

### Legal Hold
Legal hold applied to all evidence items. Do not modify or delete.
