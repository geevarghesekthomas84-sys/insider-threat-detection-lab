#!/bin/bash
# ============================================================
# ELK Stack Installation Script - Insider Threat Lab
# Target: Ubuntu 22.04 LTS (192.168.56.40)
# Installs: Elasticsearch 8.x + Logstash + Kibana + Filebeat
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; exit 1; }

echo -e "${CYAN}
╔══════════════════════════════════════════════════════╗
║       ELK Stack Installation - Insider Threat Lab    ║
╚══════════════════════════════════════════════════════╝
${NC}"

[[ $EUID -ne 0 ]] && error "Must run as root"

ELASTIC_VERSION="8.15.0"
MANAGER_IP="192.168.56.40"
ES_PASSWORD="InsiderThreatELK2024!"

# ==================== PREREQUISITES ====================
log "Installing prerequisites..."
apt-get update -qq
apt-get install -y curl apt-transport-https gnupg2 default-jdk

# ==================== ADD ELASTIC REPOSITORY ====================
log "Adding Elastic GPG key and repository..."
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg

echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-8.x.list

apt-get update -qq

# ==================== ELASTICSEARCH ====================
log "Installing Elasticsearch ${ELASTIC_VERSION}..."
apt-get install -y elasticsearch

log "Configuring Elasticsearch..."
cat > /etc/elasticsearch/elasticsearch.yml << 'ESCONFIG'
cluster.name: insider-threat-lab
node.name: soc-node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node
xpack.security.enabled: true
xpack.security.enrollment.enabled: true
xpack.security.http.ssl.enabled: false
xpack.security.transport.ssl.enabled: false
ESCONFIG

log "Setting JVM heap size..."
sed -i 's/-Xms1g/-Xms2g/' /etc/elasticsearch/jvm.options
sed -i 's/-Xmx1g/-Xmx2g/' /etc/elasticsearch/jvm.options

systemctl daemon-reload
systemctl enable elasticsearch
systemctl start elasticsearch
sleep 15

log "Setting Elasticsearch password..."
echo "y" | /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -i <<< "${ES_PASSWORD}
${ES_PASSWORD}"

# ==================== KIBANA ====================
log "Installing Kibana..."
apt-get install -y kibana

log "Configuring Kibana..."
cat > /etc/kibana/kibana.yml << KIBCONFIG
server.port: 5601
server.host: "0.0.0.0"
server.name: "insider-threat-soc"
elasticsearch.hosts: ["http://${MANAGER_IP}:9200"]
elasticsearch.username: "kibana_system"
elasticsearch.password: "${ES_PASSWORD}"
logging.appenders.file.type: file
logging.appenders.file.fileName: /var/log/kibana/kibana.log
logging.appenders.file.layout.type: json
KIBCONFIG

echo "y" | /usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system -i <<< "${ES_PASSWORD}
${ES_PASSWORD}"

systemctl enable kibana
systemctl start kibana

# ==================== LOGSTASH ====================
log "Installing Logstash..."
apt-get install -y logstash

log "Deploying Logstash pipeline..."
if [ -f "./configs/elk/logstash.conf" ]; then
    cp ./configs/elk/logstash.conf /etc/logstash/conf.d/insider-threat.conf
fi

# Set ES password in environment
echo "ES_PASSWORD=${ES_PASSWORD}" >> /etc/default/logstash

systemctl enable logstash
systemctl start logstash

# ==================== FILEBEAT ====================
log "Installing Filebeat..."
apt-get install -y filebeat

log "Configuring Filebeat for Wazuh alerts..."
cat > /etc/filebeat/filebeat.yml << FBCONFIG
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/ossec/logs/alerts/alerts.json
    json.keys_under_root: true
    json.add_error_key: true
    json.message_key: log

output.elasticsearch:
  hosts: ["http://${MANAGER_IP}:9200"]
  username: "elastic"
  password: "${ES_PASSWORD}"
  index: "wazuh-alerts-%{+yyyy.MM.dd}"

setup.template.name: "wazuh-alerts"
setup.template.pattern: "wazuh-alerts-*"
setup.ilm.enabled: false

logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
FBCONFIG

systemctl enable filebeat
systemctl start filebeat

# ==================== CREATE INDEX PATTERNS ====================
log "Waiting for Kibana to be ready..."
sleep 30

log "Creating Kibana index patterns..."
curl -s -X POST "http://${MANAGER_IP}:5601/api/saved_objects/index-pattern/insider-threat-*" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -u "elastic:${ES_PASSWORD}" \
  -d '{"attributes":{"title":"insider-threat-*","timeFieldName":"@timestamp"}}' || true

curl -s -X POST "http://${MANAGER_IP}:5601/api/saved_objects/index-pattern/wazuh-alerts-*" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -u "elastic:${ES_PASSWORD}" \
  -d '{"attributes":{"title":"wazuh-alerts-*","timeFieldName":"@timestamp"}}' || true

# ==================== FIREWALL ====================
if command -v ufw &> /dev/null; then
    ufw allow 9200/tcp comment "Elasticsearch"
    ufw allow 5601/tcp comment "Kibana"
    ufw allow 5044/tcp comment "Logstash Beats"
fi

echo -e "${CYAN}
╔══════════════════════════════════════════════════════╗
║       ELK Stack Installation Complete!               ║
╠══════════════════════════════════════════════════════╣
║  Elasticsearch: http://${MANAGER_IP}:9200            ║
║  Kibana:        http://${MANAGER_IP}:5601            ║
║  Logstash:      Beats on 5044                        ║
║  User:          elastic                              ║
║  Password:      ${ES_PASSWORD}                       ║
╚══════════════════════════════════════════════════════╝
${NC}"
