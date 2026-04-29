# Sysmon Deployment Guide

## Install
```powershell
.\scripts\setup\deploy_windows_agents.ps1
```

## Manual Install
1. Download from https://download.sysinternals.com/files/Sysmon.zip
2. Extract and run:
```powershell
Sysmon64.exe -accepteula -i configs\sysmon\sysmonconfig.xml
```

## Configuration Highlights
Our `sysmonconfig.xml` monitors:

| Event ID | Category | Insider Threat Use |
|----------|----------|-------------------|
| 1 | Process Create | PowerShell, LOLBins, suspicious tools |
| 2 | File Create Time | Timestomping detection |
| 3 | Network Connect | Cloud uploads, C2 connections |
| 6 | Driver Load | USB device drivers |
| 7 | Image Load | Credential DLL loading (samlib, vaultcli) |
| 8 | CreateRemoteThread | Process injection |
| 10 | Process Access | LSASS credential dumping |
| 11 | File Create | Executables, archives, scripts in sensitive dirs |
| 12-14 | Registry | Persistence via Run keys, services |
| 15 | FileCreateStreamHash | Zone.Identifier (downloads) |
| 17-18 | Pipe Events | Mimikatz, PsExec named pipes |
| 22 | DNS Query | Cloud storage, suspicious TLDs |
| 23 | File Delete | Sensitive file deletion, log removal |

## Update Configuration
```powershell
Sysmon64.exe -c configs\sysmon\sysmonconfig.xml
```
