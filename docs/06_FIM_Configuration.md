# FIM Configuration Guide

## Overview
File Integrity Monitoring is configured in both Wazuh (agent.conf) and Sysmon to detect unauthorized file access and modifications in sensitive directories.

## Monitored Directories

| Path | Type | Monitoring |
|------|------|-----------|
| C:\SensitiveData | Company data | Real-time + changes |
| C:\ConfidentialProjects | IP / Projects | Real-time + changes |
| C:\Users\Public\Documents | Shared docs | Real-time |
| C:\Windows\System32\drivers\etc | System config | Real-time |
| C:\Windows\System32\config | Registry hives | Real-time |
| Startup folders | Persistence | Real-time |

## Registry Monitoring
- `HKLM\...\CurrentVersion\Run` — Auto-start programs
- `HKLM\...\CurrentVersion\RunOnce` — One-time auto-start
- `HKCU\...\CurrentVersion\Run` — User auto-start
- `HKLM\...\USBSTOR` — USB device history
- `HKLM\...\Services` — Service installations

## Alert Levels
| Event | Wazuh Level | Rule ID |
|-------|-------------|---------|
| File modified in SensitiveData | 10 | 100200 |
| File deleted in SensitiveData | 12 | 100201 |
| New file in SensitiveData | 8 | 100202 |
| USB registry change | 10 | 100103 |
