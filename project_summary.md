# 🛡️ Insider Threat Detection & IR Lab — Project Summary

## Project Complete ✅

A fully functional **Blue Team SOC + DFIR Lab** has been built at `d:\blue` with **38 files** across all project deliverables.

---

## Dashboard Screenshots

### SOC Overview
![SOC Overview Dashboard](C:\Users\GG\.gemini\antigravity\brain\37321b0d-76db-4234-9928-61ea4a286217\artifacts\dashboard_overview.png)

### Alert Feed (Filterable)
![Alert Feed](C:\Users\GG\.gemini\antigravity\brain\37321b0d-76db-4234-9928-61ea4a286217\artifacts\dashboard_alerts.png)

### Attack Timeline
![Attack Timeline](C:\Users\GG\.gemini\antigravity\brain\37321b0d-76db-4234-9928-61ea4a286217\artifacts\dashboard_ir.png)

---

## Files Created (38 total)

### 🔧 Configuration Files (7)
| File | Purpose |
|------|---------|
| [ossec.conf](file:///d:/blue/configs/wazuh/ossec.conf) | Wazuh Manager config with FIM, active response |
| [agent.conf](file:///d:/blue/configs/wazuh/agent.conf) | Shared agent config for Windows event collection |
| [local_rules.xml](file:///d:/blue/configs/wazuh/local_rules.xml) | **30+ custom insider threat detection rules** with MITRE mapping |
| [sysmonconfig.xml](file:///d:/blue/configs/sysmon/sysmonconfig.xml) | Sysmon config for 14 event types |
| [inputs.conf](file:///d:/blue/configs/splunk/inputs.conf) | Splunk forwarder input configuration |
| [savedsearches.conf](file:///d:/blue/configs/splunk/savedsearches.conf) | **20+ Splunk correlation searches** |
| [logstash.conf](file:///d:/blue/configs/elk/logstash.conf) | ELK pipeline with risk scoring engine |

### 🚀 Setup Scripts (4)
| File | Purpose |
|------|---------|
| [install_wazuh_manager.sh](file:///d:/blue/scripts/setup/install_wazuh_manager.sh) | Automated Wazuh Manager install |
| [install_elk_stack.sh](file:///d:/blue/scripts/setup/install_elk_stack.sh) | Full ELK Stack install (ES+LS+Kibana+Filebeat) |
| [install_splunk.sh](file:///d:/blue/scripts/setup/install_splunk.sh) | Splunk Enterprise install + index creation |
| [deploy_windows_agents.ps1](file:///d:/blue/scripts/setup/deploy_windows_agents.ps1) | Windows: Sysmon + Wazuh Agent + Splunk UF + audit policies |

### 💣 Attack Simulation (1)
| File | Purpose |
|------|---------|
| [run_all_attacks.ps1](file:///d:/blue/scripts/attack-simulation/run_all_attacks.ps1) | **9-phase attack chain** covering 10 MITRE techniques |

### 🚨 Response & Forensics (2)
| File | Purpose |
|------|---------|
| [containment.ps1](file:///d:/blue/scripts/response/containment.ps1) | IR containment: account lockout, network isolation, USB block, evidence collection |
| [ioc_extraction.py](file:///d:/blue/scripts/forensics/ioc_extraction.py) | Python IOC extractor with MITRE mapping + timeline generation |

### 📏 Detection Rules (1)
| File | Purpose |
|------|---------|
| [insider_threat_rules.yml](file:///d:/blue/rules/sigma/insider_threat_rules.yml) | **10 SIGMA rules** — vendor-agnostic detection |

### 🖥️ SOC Dashboard (3)
| File | Purpose |
|------|---------|
| [index.html](file:///d:/blue/dashboards/web/index.html) | 7-tab SOC dashboard (Overview, Alerts, MITRE, Timeline, Endpoints, IR, Forensics) |
| [style.css](file:///d:/blue/dashboards/web/style.css) | Premium dark theme with glassmorphism |
| [app.js](file:///d:/blue/dashboards/web/app.js) | Dashboard logic with charts, filters, live clock |

### 📄 Documentation (13)
| File | Purpose |
|------|---------|
| [01_Lab_Setup_Guide.md](file:///d:/blue/docs/01_Lab_Setup_Guide.md) | VM creation and network setup |
| [02_Wazuh_Installation.md](file:///d:/blue/docs/02_Wazuh_Installation.md) | Wazuh install guide |
| [03_Splunk_Setup.md](file:///d:/blue/docs/03_Splunk_Setup.md) | Splunk setup guide |
| [04_ELK_Setup.md](file:///d:/blue/docs/04_ELK_Setup.md) | ELK Stack setup guide |
| [05_Sysmon_Deployment.md](file:///d:/blue/docs/05_Sysmon_Deployment.md) | Sysmon deployment guide |
| [06_FIM_Configuration.md](file:///d:/blue/docs/06_FIM_Configuration.md) | File Integrity Monitoring config |
| [07_Detection_Rules.md](file:///d:/blue/docs/07_Detection_Rules.md) | All 30+ detection rules documented |
| [08_Attack_Simulation.md](file:///d:/blue/docs/08_Attack_Simulation.md) | Attack simulation usage guide |
| [09_Incident_Response.md](file:///d:/blue/docs/09_Incident_Response.md) | **Full NIST 800-61 IR playbook** |
| [10_Forensics_Report.md](file:///d:/blue/docs/10_Forensics_Report.md) | Forensics report with evidence chain |
| [11_MITRE_ATTACK_Mapping.md](file:///d:/blue/docs/11_MITRE_ATTACK_Mapping.md) | **26 techniques mapped across 10 tactics** |
| [12_Remediation_Report.md](file:///d:/blue/docs/12_Remediation_Report.md) | Prioritized remediation plan |
| [13_Final_Report.md](file:///d:/blue/docs/13_Final_Report.md) | Executive incident report |

### 📊 Evidence & Reports (5)
| File | Purpose |
|------|---------|
| [ioc_list.csv](file:///d:/blue/evidence/ioc_list.csv) | 20 IOCs with MITRE tagging |
| [timeline.csv](file:///d:/blue/evidence/timeline.csv) | 29-event attack timeline |
| [chain_of_custody.md](file:///d:/blue/evidence/chain_of_custody.md) | Evidence chain of custody |
| [presentation_outline.md](file:///d:/blue/presentation/presentation_outline.md) | 20-slide presentation structure |
| [README.md](file:///d:/blue/README.md) | GitHub-ready project README |

---

## Deliverables Checklist

| # | Requirement | Status | File(s) |
|---|------------|--------|---------|
| 1 | Wazuh installation and configuration | ✅ | ossec.conf, install script |
| 2 | Splunk installation and log forwarding | ✅ | inputs.conf, install script |
| 3 | Windows agent setup | ✅ | deploy_windows_agents.ps1 |
| 4 | Sysmon deployment | ✅ | sysmonconfig.xml |
| 5 | File Integrity Monitoring rules | ✅ | agent.conf, local_rules.xml |
| 6 | Custom detection rules | ✅ | 30+ Wazuh rules, 10 SIGMA rules |
| 7 | USB activity monitoring | ✅ | Rules 100100-100103 |
| 8 | PowerShell activity monitoring | ✅ | Rules 100300-100304 |
| 9 | Login monitoring | ✅ | Rules 100500-100502 |
| 10 | VPN/Login anomaly detection | ✅ | Splunk correlation searches |
| 11 | Log correlation (Splunk) | ✅ | 20+ saved searches |
| 12 | Alert generation dashboard | ✅ | SOC Web Dashboard |
| 13 | Incident response workflow | ✅ | IR playbook + containment script |
| 14 | Containment actions | ✅ | containment.ps1 |
| 15 | Forensic evidence collection | ✅ | Evidence collection + IOC extraction |
| 16 | IOC extraction | ✅ | ioc_extraction.py + ioc_list.csv |
| 17 | MITRE ATT&CK mapping | ✅ | 26 techniques across 10 tactics |
| 18 | Final remediation report | ✅ | Remediation + Final report |

> [!TIP]
> Open the SOC Dashboard by opening `d:\blue\dashboards\web\index.html` in any browser. All 7 tabs are fully functional with simulated data from the attack scenario.
