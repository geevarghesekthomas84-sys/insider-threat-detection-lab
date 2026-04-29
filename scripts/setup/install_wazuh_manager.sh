#!/bin/bash
# ============================================================
# Wazuh Manager Installation Script - Insider Threat Lab
# Target: Ubuntu 22.04 LTS (192.168.56.40)
# ============================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; exit 1; }
banner() { echo -e "${CYAN}$1${NC}"; }

banner "
╔══════════════════════════════════════════════════════╗
║       Wazuh Manager Installation Script              ║
║       Insider Threat Detection Lab                   ║
╚══════════════════════════════════════════════════════╝
"

# Check root
[[ $EUID -ne 0 ]] && error "This script must be run as root"

WAZUH_VERSION="4.9.0"
MANAGER_IP="192.168.56.40"

# ==================== PREREQUISITES ====================
log "Installing prerequisites..."
apt-get update -qq
apt-get install -y curl apt-transport-https lsb-release gnupg2 software-properties-common net-tools jq

# ==================== INSTALL WAZUH MANAGER ====================
log "Adding Wazuh GPG key..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

log "Adding Wazuh repository..."
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

apt-get update -qq

log "Installing Wazuh Manager v${WAZUH_VERSION}..."
apt-get install -y wazuh-manager

# ==================== CONFIGURE WAZUH ====================
log "Backing up default configuration..."
cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.bak

log "Deploying custom configuration..."
# Copy our custom ossec.conf
if [ -f "./configs/wazuh/ossec.conf" ]; then
    cp ./configs/wazuh/ossec.conf /var/ossec/etc/ossec.conf
    log "Custom ossec.conf deployed"
fi

# Deploy custom rules
if [ -f "./configs/wazuh/local_rules.xml" ]; then
    cp ./configs/wazuh/local_rules.xml /var/ossec/etc/rules/local_rules.xml
    log "Custom insider threat rules deployed"
fi

# Deploy shared agent configuration
if [ -f "./configs/wazuh/agent.conf" ]; then
    mkdir -p /var/ossec/etc/shared/default
    cp ./configs/wazuh/agent.conf /var/ossec/etc/shared/default/agent.conf
    log "Shared agent configuration deployed"
fi

# ==================== CREATE SENSITIVE DATA DIRECTORIES ====================
log "Creating sensitive data directories for FIM monitoring..."
mkdir -p /opt/sensitive-data/{financial,hr,intellectual-property,customer-data}

# Create sample sensitive files
echo "Q1 2024 Revenue: \$12.5M | Q2 Forecast: \$14.2M" > /opt/sensitive-data/financial/quarterly_report.xlsx
echo "Employee SSN Database - CONFIDENTIAL" > /opt/sensitive-data/hr/employee_ssn.csv
echo "Patent Application #2024-001 - Proprietary Algorithm" > /opt/sensitive-data/intellectual-property/patent_draft.docx
echo "Customer PII - Names, Emails, CC Numbers" > /opt/sensitive-data/customer-data/customer_db.csv

chmod -R 750 /opt/sensitive-data
log "Sensitive data directories created with sample files"

# ==================== SET ENROLLMENT PASSWORD ====================
log "Setting agent enrollment password..."
echo "InsiderThreatLab2024!" > /var/ossec/etc/authd.pass
chmod 640 /var/ossec/etc/authd.pass
chown root:wazuh /var/ossec/etc/authd.pass

# ==================== ENABLE AND START ====================
log "Starting Wazuh Manager..."
systemctl daemon-reload
systemctl enable wazuh-manager
systemctl start wazuh-manager

# Wait for service
sleep 5

# Verify
if systemctl is-active --quiet wazuh-manager; then
    log "Wazuh Manager is running successfully!"
else
    error "Wazuh Manager failed to start. Check /var/ossec/logs/ossec.log"
fi

# ==================== CONFIGURE FIREWALL ====================
log "Configuring firewall rules..."
if command -v ufw &> /dev/null; then
    ufw allow 1514/tcp comment "Wazuh agent communication"
    ufw allow 1515/tcp comment "Wazuh agent enrollment"
    ufw allow 55000/tcp comment "Wazuh API"
    ufw allow 514/udp comment "Syslog"
    log "Firewall rules configured"
fi

# ==================== DISPLAY STATUS ====================
banner "
╔══════════════════════════════════════════════════════╗
║       Installation Complete!                         ║
╠══════════════════════════════════════════════════════╣
║  Wazuh Manager:  https://${MANAGER_IP}:55000         ║
║  Agent Port:     1514/tcp                            ║
║  Enrollment:     1515/tcp                            ║
║  Password:       InsiderThreatLab2024!               ║
╠══════════════════════════════════════════════════════╣
║  Logs: /var/ossec/logs/ossec.log                     ║
║  Rules: /var/ossec/etc/rules/local_rules.xml         ║
║  Config: /var/ossec/etc/ossec.conf                   ║
╚══════════════════════════════════════════════════════╝
"

log "Wazuh Manager installation complete!"
log "Next: Install ELK Stack (./install_elk_stack.sh)"
