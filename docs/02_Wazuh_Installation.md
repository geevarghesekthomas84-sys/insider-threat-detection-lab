# Wazuh Installation Guide

## Server Requirements
- Ubuntu 22.04 LTS
- 4+ GB RAM, 50+ GB disk
- Internet access for package downloads

## Quick Install

```bash
sudo ./scripts/setup/install_wazuh_manager.sh
```

## Manual Steps

### 1. Add Repository
```bash
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
apt-get update && apt-get install wazuh-manager
```

### 2. Deploy Configuration
Copy `configs/wazuh/ossec.conf` → `/var/ossec/etc/ossec.conf`
Copy `configs/wazuh/local_rules.xml` → `/var/ossec/etc/rules/local_rules.xml`
Copy `configs/wazuh/agent.conf` → `/var/ossec/etc/shared/default/agent.conf`

### 3. Start Service
```bash
systemctl enable wazuh-manager && systemctl start wazuh-manager
```

### 4. Verify
```bash
systemctl status wazuh-manager
/var/ossec/bin/agent_control -l   # List agents
curl -k -u admin:admin https://localhost:55000   # API test
```

## Agent Enrollment
```bash
# On agent machine
/var/ossec/bin/agent-auth -m 192.168.56.40 -P InsiderThreatLab2024!
```
