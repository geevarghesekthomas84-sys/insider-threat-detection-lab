# Detection Rules Documentation

## Rule Categories

### USB Monitoring (100100-100103)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100100 | 10 | USB storage device connected |
| 100101 | 12 | USB connected during off-hours (8PM-6AM) |
| 100102 | 8 | New USB device driver installed |
| 100103 | 10 | USB registry (USBSTOR) modified |

### Sensitive File Access (100200-100202)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100200 | 10 | Sensitive file modified |
| 100201 | 12 | Sensitive file DELETED |
| 100202 | 8 | New file in sensitive directory |

### PowerShell (100300-100304)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100300 | 12 | Offensive tool execution (Mimikatz, etc.) |
| 100301 | 10 | Suspicious download/execution pattern |
| 100302 | 10 | Obfuscated/hidden execution |
| 100303 | 8 | File collection/staging |
| 100304 | 10 | Attempt to disable Defender |

### Log Tampering (100400-100402)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100400 | 14 | Security audit log cleared |
| 100401 | 12 | PS log clearing command |
| 100402 | 10 | Log clearing via Sysmon |

### Authentication (100500-100502)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100500 | 10 | After-hours login (10PM-5AM) |
| 100501 | 8 | Weekend evening login |
| 100502 | 12 | Failed logins then success |

### Lateral Movement (100600-100602)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100600 | 12 | After-hours RDP login |
| 100601 | 10 | Network logon with admin account |
| 100602 | 8 | Special privileges off-hours |

### Exfiltration (100700-100702)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100700 | 10 | Data transfer tool execution |
| 100701 | 12 | Cloud storage upload detected |
| 100702 | 8 | File archiving detected |

### Persistence (100800)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100800 | 10 | Scheduled task created |

### Credential Access (100900-100901)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100900 | 14 | Credential dumping tool |
| 100901 | 12 | LSASS process access/dump |

### Composite (100950)
| Rule ID | Level | Description |
|---------|-------|-------------|
| 100950 | 14 | File access + USB = Active exfiltration |
