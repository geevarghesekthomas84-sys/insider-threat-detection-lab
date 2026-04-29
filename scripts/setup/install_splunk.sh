#!/bin/bash
# ============================================================
# Splunk Enterprise Installation Script - Insider Threat Lab
# Target: Ubuntu 22.04 LTS (192.168.56.40)
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; exit 1; }

echo -e "${CYAN}
╔══════════════════════════════════════════════════════╗
║     Splunk Enterprise Installation - Insider Threat  ║
╚══════════════════════════════════════════════════════╝
${NC}"

[[ $EUID -ne 0 ]] && error "Must run as root"

SPLUNK_VERSION="9.3.1"
MANAGER_IP="192.168.56.40"

# ==================== DOWNLOAD & INSTALL ====================
log "Downloading Splunk Enterprise..."
cd /opt
wget -O splunk.deb "https://download.splunk.com/products/splunk/releases/${SPLUNK_VERSION}/linux/splunk-${SPLUNK_VERSION}-0b8d769cb912-linux-2.1-amd64.deb" 2>/dev/null || {
    log "Direct download unavailable. Please download Splunk Enterprise from https://www.splunk.com/en_us/download.html"
    log "Place the .deb file in /opt/splunk.deb and re-run this script"
    log "Alternatively, use the following manual steps:"
    echo ""
    echo "  1. Visit https://www.splunk.com/en_us/download/splunk-enterprise.html"
    echo "  2. Download the .deb package for Linux"
    echo "  3. sudo dpkg -i splunk-*.deb"
    echo "  4. sudo /opt/splunk/bin/splunk start --accept-license --seed-passwd 'InsiderThreatSplunk2024!'"
    echo ""
}

if [ -f "/opt/splunk.deb" ]; then
    dpkg -i /opt/splunk.deb
    rm /opt/splunk.deb
fi

# ==================== CONFIGURE ====================
log "Starting Splunk with initial configuration..."
/opt/splunk/bin/splunk start --accept-license --seed-passwd 'InsiderThreatSplunk2024!' --no-prompt

log "Enabling boot start..."
/opt/splunk/bin/splunk enable boot-start -user splunk

# ==================== CREATE INDEXES ====================
log "Creating indexes for insider threat data..."
/opt/splunk/bin/splunk add index insiderthreat -auth admin:InsiderThreatSplunk2024!
/opt/splunk/bin/splunk add index sysmon -auth admin:InsiderThreatSplunk2024!
/opt/splunk/bin/splunk add index powershell -auth admin:InsiderThreatSplunk2024!
/opt/splunk/bin/splunk add index wazuh -auth admin:InsiderThreatSplunk2024!

# ==================== CONFIGURE RECEIVING ====================
log "Enabling receiving on port 9997..."
/opt/splunk/bin/splunk enable listen 9997 -auth admin:InsiderThreatSplunk2024!

# ==================== DEPLOY SAVED SEARCHES ====================
log "Deploying correlation searches..."
SPLUNK_APP_DIR="/opt/splunk/etc/apps/insider_threat"
mkdir -p "${SPLUNK_APP_DIR}/local"
mkdir -p "${SPLUNK_APP_DIR}/metadata"

# Create app.conf
cat > "${SPLUNK_APP_DIR}/local/app.conf" << 'EOF'
[install]
is_configured = true

[ui]
is_visible = true
label = Insider Threat Detection

[launcher]
author = Blue Team SOC
description = Insider threat detection and incident response
version = 1.0.0
EOF

# Create default metadata
cat > "${SPLUNK_APP_DIR}/metadata/local.meta" << 'EOF'
[]
access = read : [ * ], write : [ admin ]
export = system
EOF

# Copy saved searches
if [ -f "./configs/splunk/savedsearches.conf" ]; then
    cp ./configs/splunk/savedsearches.conf "${SPLUNK_APP_DIR}/local/savedsearches.conf"
    log "Correlation searches deployed"
fi

# Copy inputs
if [ -f "./configs/splunk/inputs.conf" ]; then
    cp ./configs/splunk/inputs.conf "${SPLUNK_APP_DIR}/local/inputs.conf"
fi

# ==================== RESTART ====================
log "Restarting Splunk..."
/opt/splunk/bin/splunk restart

# ==================== FIREWALL ====================
if command -v ufw &> /dev/null; then
    ufw allow 8000/tcp comment "Splunk Web"
    ufw allow 8089/tcp comment "Splunk Management"
    ufw allow 9997/tcp comment "Splunk Receiving"
fi

echo -e "${CYAN}
╔══════════════════════════════════════════════════════╗
║       Splunk Enterprise Installation Complete!       ║
╠══════════════════════════════════════════════════════╣
║  Web UI:     http://${MANAGER_IP}:8000               ║
║  User:       admin                                   ║
║  Password:   InsiderThreatSplunk2024!                ║
║  Receiving:  9997/tcp                                ║
╠══════════════════════════════════════════════════════╣
║  Indexes:    insiderthreat, sysmon, powershell       ║
║  App:        Insider Threat Detection                ║
╚══════════════════════════════════════════════════════╝
${NC}"
