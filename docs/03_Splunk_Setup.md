# Splunk Setup Guide

## Quick Install
```bash
sudo ./scripts/setup/install_splunk.sh
```

## Access
- **Web UI**: http://192.168.56.40:8000
- **User**: admin
- **Password**: InsiderThreatSplunk2024!

## Indexes Created
| Index | Purpose |
|-------|---------|
| insiderthreat | Windows Security/System events |
| sysmon | Sysmon operational events |
| powershell | PowerShell script block logs |
| wazuh | Wazuh alert forwarding |

## Universal Forwarder Deployment
Deploy `configs/splunk/inputs.conf` to Windows agents at:
`C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf`

## Correlation Searches
20+ saved searches deployed in `configs/splunk/savedsearches.conf` covering:
- USB device activity (after-hours)
- Suspicious PowerShell (encoded, offensive tools)
- Authentication anomalies (brute force, after-hours, RDP)
- Log tampering (event log clearing)
- Data exfiltration (cloud uploads, archiving)
- Credential access (LSASS)
- Persistence (scheduled tasks, registry)
- **Composite insider threat scoring** (multi-indicator correlation)
