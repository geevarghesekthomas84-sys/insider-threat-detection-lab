# Lab Setup Guide - Insider Threat Detection Lab

## Prerequisites

| Component | Version | Purpose |
|-----------|---------|---------|
| VirtualBox | 7.0+ | Virtualization platform |
| RAM | 16 GB minimum | For running 4 VMs |
| Disk | 300 GB free | VM storage |
| CPU | 4+ cores | Performance |

## VM Configuration

### 1. Network Setup (VirtualBox)

```bash
# Create Host-Only Network
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
VBoxManage dhcpserver modify --ifname vboxnet0 --ip 192.168.56.100 --netmask 255.255.255.0 --lowerip 192.168.56.101 --upperip 192.168.56.254 --enable
```

### 2. Ubuntu SOC Server (192.168.56.40)

1. Download Ubuntu 22.04 LTS Server ISO
2. Create VM: 8GB RAM, 100GB disk, 2 CPU
3. Network: Adapter 1 = NAT, Adapter 2 = Host-Only (vboxnet0)
4. Install Ubuntu Server with OpenSSH
5. Configure static IP:

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

```yaml
network:
  version: 2
  ethernets:
    enp0s8:
      addresses: [192.168.56.40/24]
      routes:
        - to: 192.168.56.0/24
          via: 192.168.56.1
```

```bash
sudo netplan apply
```

6. Run setup scripts:
```bash
cd insider-threat-lab
chmod +x scripts/setup/*.sh
sudo ./scripts/setup/install_wazuh_manager.sh
sudo ./scripts/setup/install_elk_stack.sh
sudo ./scripts/setup/install_splunk.sh
```

### 3. Windows 10/11 Insider Machine (192.168.56.20)

1. Install Windows 10/11 Pro
2. VM: 4GB RAM, 60GB disk, 2 CPU
3. Network: Adapter 1 = NAT, Adapter 2 = Host-Only
4. Set static IP: 192.168.56.20
5. Run agent deployment:

```powershell
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\setup\deploy_windows_agents.ps1
```

### 4. Windows Server DC (192.168.56.30) - Optional

1. Install Windows Server 2019/2022
2. VM: 4GB RAM, 60GB disk
3. Promote to Domain Controller:

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "insiderthreat.local" -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) -Force
```

4. Create test users:
```powershell
New-ADUser -Name "John Smith" -SamAccountName "jsmith" -UserPrincipalName "jsmith@insiderthreat.local" -AccountPassword (ConvertTo-SecureString "Employee123!" -AsPlainText -Force) -Enabled $true -Path "OU=Employees,DC=insiderthreat,DC=local"
```

### 5. Kali Linux Attacker (192.168.56.10)

1. Download Kali Linux VM image
2. VM: 2GB RAM, 40GB disk
3. Network: Host-Only (vboxnet0)
4. Set static IP: 192.168.56.10

## Verification

```bash
# From SOC Server
curl -k -u admin:admin https://localhost:55000/security/user/authenticate
curl http://localhost:9200/_cluster/health -u elastic:InsiderThreatELK2024!
curl http://localhost:8000 # Splunk Web

# From Windows
Test-NetConnection 192.168.56.40 -Port 1514  # Wazuh
Test-NetConnection 192.168.56.40 -Port 9997  # Splunk
```

## Service Ports Summary

| Service | Port | Protocol |
|---------|------|----------|
| Wazuh Agent | 1514 | TCP |
| Wazuh Enrollment | 1515 | TCP |
| Wazuh API | 55000 | TCP/HTTPS |
| Elasticsearch | 9200 | TCP/HTTP |
| Kibana | 5601 | TCP/HTTP |
| Logstash Beats | 5044 | TCP |
| Splunk Web | 8000 | TCP/HTTP |
| Splunk Mgmt | 8089 | TCP |
| Splunk Receiving | 9997 | TCP |
