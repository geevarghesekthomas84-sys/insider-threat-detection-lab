# Presentation Outline - Insider Threat Detection & Response Lab

## Slide Deck Structure (20 slides)

### Section 1: Introduction (Slides 1-3)
1. **Title Slide**: Insider Threat Detection and Incident Response Lab Using Wazuh + Splunk + ELK
2. **Problem Statement**: Insider threats account for 60% of data breaches. Average cost: $15.4M per incident (Ponemon 2023).
3. **Project Objectives**: Build a practical SOC lab to detect, investigate, contain, and respond to insider threats.

### Section 2: Lab Architecture (Slides 4-6)
4. **Lab Environment**: 4 VMs — Kali, Windows 10, Windows Server DC, Ubuntu SOC Server
5. **Tool Stack**: Wazuh Manager + Agents, Splunk Enterprise, ELK Stack, Sysmon
6. **Network Diagram**: Visual architecture with data flow between components

### Section 3: Detection Engineering (Slides 7-10)
7. **Sysmon Configuration**: 14 event types monitored, insider-specific tuning
8. **Wazuh Custom Rules**: 50+ rules covering USB, PowerShell, FIM, authentication, log tampering
9. **Splunk Correlation Searches**: Multi-event detection, behavioral scoring, after-hours analysis
10. **SIGMA Rules**: 10 vendor-agnostic rules with MITRE ATT&CK tagging

### Section 4: Attack Simulation (Slides 11-13)
11. **Attack Scenario**: Privileged employee data exfiltration — 9 phases
12. **Attack Timeline**: Chronological progression from access to cover-up
13. **MITRE ATT&CK Mapping**: 26 techniques across 10 tactics

### Section 5: Detection & Response (Slides 14-17)
14. **Alert Dashboard**: SOC dashboard screenshots showing real-time alerts
15. **Investigation Process**: Timeline reconstruction, evidence correlation
16. **Containment Actions**: Account lockout, network isolation, USB blocking
17. **Forensic Evidence**: Chain of custody, IOC extraction, hash verification

### Section 6: Results & Recommendations (Slides 18-20)
18. **Detection Metrics**: 14 alerts triggered, 0 false positives on critical rules, 36-min detection time
19. **Remediation Plan**: DLP, UEBA, MFA, CASB, insider threat program
20. **Conclusion**: Defense-in-depth monitoring is effective; prevention gaps need addressing

### Appendix
- Full detection rule list
- IOC table
- Evidence hashes
- Tool configuration details

## Speaking Notes
- Total presentation time: 20-25 minutes
- Include live demo of SOC dashboard (5 minutes)
- Q&A: 10 minutes
- Emphasize practical, deployment-ready nature of the project
