# ELK Stack Setup Guide

## Quick Install
```bash
sudo ./scripts/setup/install_elk_stack.sh
```

## Access
- **Kibana**: http://192.168.56.40:5601
- **Elasticsearch**: http://192.168.56.40:9200
- **User**: elastic / **Password**: InsiderThreatELK2024!

## Components
| Component | Version | Port | Purpose |
|-----------|---------|------|---------|
| Elasticsearch | 8.15.0 | 9200 | Search & analytics engine |
| Kibana | 8.15.0 | 5601 | Visualization dashboard |
| Logstash | 8.15.0 | 5044 | Log pipeline & enrichment |
| Filebeat | 8.15.0 | N/A | Wazuh alert forwarding |

## Logstash Pipeline
The pipeline in `configs/elk/logstash.conf` provides:
- Wazuh alert parsing and enrichment
- Windows event log processing via Winlogbeat
- Insider threat tagging and categorization
- MITRE ATT&CK auto-enrichment
- **Risk scoring engine** (0-100 scale based on alert tags)
- Separate indexing for high-severity alerts

## Index Patterns
- `insider-threat-*` — All processed events
- `insider-threat-alerts-*` — Critical/high alerts only
- `wazuh-alerts-*` — Raw Wazuh alerts
