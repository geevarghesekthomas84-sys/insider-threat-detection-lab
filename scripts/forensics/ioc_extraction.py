#!/usr/bin/env python3
"""
IOC Extraction Tool - Insider Threat Lab
Extracts Indicators of Compromise from event logs and evidence files
"""

import csv
import json
import re
import hashlib
import os
import sys
from datetime import datetime
from collections import defaultdict

class IOCExtractor:
    def __init__(self, evidence_dir, output_dir=None):
        self.evidence_dir = evidence_dir
        self.output_dir = output_dir or os.path.join(evidence_dir, "iocs")
        os.makedirs(self.output_dir, exist_ok=True)
        
        self.iocs = {
            "file_hashes": [],
            "ip_addresses": [],
            "domains": [],
            "urls": [],
            "email_addresses": [],
            "registry_keys": [],
            "file_paths": [],
            "user_accounts": [],
            "usb_devices": [],
            "scheduled_tasks": [],
            "processes": [],
            "dns_queries": [],
            "timestamps": []
        }
        
        self.mitre_mapping = {
            "file_access": {"technique": "T1005", "tactic": "Collection", "name": "Data from Local System"},
            "usb_exfil": {"technique": "T1052.001", "tactic": "Exfiltration", "name": "Exfiltration Over USB"},
            "cloud_upload": {"technique": "T1567.002", "tactic": "Exfiltration", "name": "Exfiltration to Cloud Storage"},
            "powershell": {"technique": "T1059.001", "tactic": "Execution", "name": "PowerShell"},
            "log_clear": {"technique": "T1070.001", "tactic": "Defense Evasion", "name": "Clear Windows Event Logs"},
            "cred_dump": {"technique": "T1003.001", "tactic": "Credential Access", "name": "LSASS Memory"},
            "sched_task": {"technique": "T1053.005", "tactic": "Persistence", "name": "Scheduled Task"},
            "reg_run_key": {"technique": "T1547.001", "tactic": "Persistence", "name": "Registry Run Keys"},
            "timestomp": {"technique": "T1070.006", "tactic": "Defense Evasion", "name": "Timestomp"},
            "valid_accounts": {"technique": "T1078", "tactic": "Initial Access", "name": "Valid Accounts"},
        }
    
    def extract_from_processes(self, filepath):
        """Extract suspicious process IOCs"""
        suspicious_procs = [
            "mimikatz", "procdump", "psexec", "cobaltstrike",
            "powershell", "cmd.exe", "certutil", "bitsadmin",
            "mshta", "regsvr32", "rundll32", "wscript", "cscript"
        ]
        
        if not os.path.exists(filepath):
            return
        
        with open(filepath, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                proc_name = row.get("ProcessName", "").lower()
                proc_path = row.get("Path", "")
                
                for susp in suspicious_procs:
                    if susp in proc_name:
                        self.iocs["processes"].append({
                            "name": row.get("ProcessName"),
                            "pid": row.get("Id"),
                            "path": proc_path,
                            "start_time": row.get("StartTime"),
                            "indicator_type": "suspicious_process",
                            "severity": "high" if susp in ["mimikatz", "procdump", "cobaltstrike"] else "medium"
                        })
    
    def extract_from_network(self, filepath):
        """Extract suspicious network IOCs"""
        suspicious_ports = [4444, 5555, 1337, 8080, 9999, 1234, 6666]
        
        if not os.path.exists(filepath):
            return
        
        with open(filepath, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                remote_addr = row.get("RemoteAddress", "")
                remote_port = int(row.get("RemotePort", 0) or 0)
                state = row.get("State", "")
                
                if remote_addr and remote_addr not in ["0.0.0.0", "::", "127.0.0.1", "::1"]:
                    if state == "Established":
                        entry = {
                            "ip": remote_addr,
                            "port": remote_port,
                            "local_port": row.get("LocalPort"),
                            "state": state,
                            "pid": row.get("OwningProcess"),
                            "severity": "high" if remote_port in suspicious_ports else "low"
                        }
                        self.iocs["ip_addresses"].append(entry)
    
    def extract_from_dns(self, filepath):
        """Extract suspicious DNS IOCs"""
        suspicious_domains = [
            "pastebin.com", "mega.nz", "transfer.sh", "ngrok",
            "drive.google.com", "dropbox.com", "wetransfer.com",
            ".onion", ".bit", "raw.githubusercontent.com"
        ]
        
        if not os.path.exists(filepath):
            return
        
        with open(filepath, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = row.get("Entry", "") or row.get("Name", "")
                for susp in suspicious_domains:
                    if susp in name.lower():
                        self.iocs["domains"].append({
                            "domain": name,
                            "matched_pattern": susp,
                            "data": row.get("Data", ""),
                            "severity": "high"
                        })
    
    def extract_from_usb(self, filepath):
        """Extract USB device IOCs"""
        if not os.path.exists(filepath):
            return
        
        with open(filepath, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                if row.get("FriendlyName"):
                    self.iocs["usb_devices"].append({
                        "device_name": row.get("FriendlyName"),
                        "hardware_id": row.get("HardwareID"),
                        "manufacturer": row.get("Mfg"),
                        "severity": "medium"
                    })
    
    def extract_from_tasks(self, filepath):
        """Extract suspicious scheduled task IOCs"""
        if not os.path.exists(filepath):
            return
        
        with open(filepath, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                task_name = row.get("TaskName", "")
                # Flag non-Microsoft tasks
                author = row.get("Author", "")
                if author and "Microsoft" not in author:
                    self.iocs["scheduled_tasks"].append({
                        "task_name": task_name,
                        "task_path": row.get("TaskPath"),
                        "author": author,
                        "state": row.get("State"),
                        "severity": "medium"
                    })
    
    def generate_file_hashes(self, directory):
        """Generate hashes for evidence files"""
        for root, dirs, files in os.walk(directory):
            for file in files:
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'rb') as f:
                        content = f.read()
                        self.iocs["file_hashes"].append({
                            "file": filepath,
                            "md5": hashlib.md5(content).hexdigest(),
                            "sha256": hashlib.sha256(content).hexdigest(),
                            "size": len(content)
                        })
                except (PermissionError, OSError):
                    pass
    
    def build_timeline(self):
        """Build attack timeline from IOCs"""
        timeline = []
        
        for proc in self.iocs["processes"]:
            if proc.get("start_time"):
                timeline.append({
                    "timestamp": proc["start_time"],
                    "event": f"Suspicious process: {proc['name']} (PID: {proc['pid']})",
                    "mitre": "T1059",
                    "severity": proc["severity"]
                })
        
        for domain in self.iocs["domains"]:
            timeline.append({
                "timestamp": "N/A",
                "event": f"DNS query to suspicious domain: {domain['domain']}",
                "mitre": "T1567.002",
                "severity": domain["severity"]
            })
        
        for usb in self.iocs["usb_devices"]:
            timeline.append({
                "timestamp": "N/A",
                "event": f"USB device detected: {usb['device_name']}",
                "mitre": "T1052.001",
                "severity": usb["severity"]
            })
        
        return sorted(timeline, key=lambda x: str(x.get("timestamp", "")))
    
    def export_iocs(self):
        """Export all IOCs to various formats"""
        # JSON export
        with open(os.path.join(self.output_dir, "iocs_full.json"), 'w') as f:
            json.dump(self.iocs, f, indent=2, default=str)
        
        # CSV export
        with open(os.path.join(self.output_dir, "ioc_list.csv"), 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(["Type", "Value", "Severity", "Context"])
            
            for ip in self.iocs["ip_addresses"]:
                writer.writerow(["IP", ip["ip"], ip["severity"], f"Port:{ip['port']}"])
            for domain in self.iocs["domains"]:
                writer.writerow(["Domain", domain["domain"], domain["severity"], domain["matched_pattern"]])
            for usb in self.iocs["usb_devices"]:
                writer.writerow(["USB", usb["device_name"], usb["severity"], usb.get("hardware_id","")])
            for proc in self.iocs["processes"]:
                writer.writerow(["Process", proc["name"], proc["severity"], proc.get("path","")])
            for task in self.iocs["scheduled_tasks"]:
                writer.writerow(["ScheduledTask", task["task_name"], task["severity"], task.get("author","")])
            for fh in self.iocs["file_hashes"]:
                writer.writerow(["FileHash", fh["sha256"], "info", fh["file"]])
        
        # MITRE mapping export
        with open(os.path.join(self.output_dir, "mitre_mapping.json"), 'w') as f:
            json.dump(self.mitre_mapping, f, indent=2)
        
        # Timeline
        timeline = self.build_timeline()
        with open(os.path.join(self.output_dir, "attack_timeline.json"), 'w') as f:
            json.dump(timeline, f, indent=2, default=str)
        
        # Summary
        summary = {
            "extraction_time": datetime.now().isoformat(),
            "evidence_directory": self.evidence_dir,
            "total_iocs": sum(len(v) for v in self.iocs.values()),
            "breakdown": {k: len(v) for k, v in self.iocs.items() if v},
            "high_severity_count": sum(
                1 for cat in self.iocs.values()
                for item in cat if isinstance(item, dict) and item.get("severity") == "high"
            ),
            "mitre_techniques_observed": list(set(
                t.get("mitre", "") for t in self.build_timeline() if t.get("mitre")
            ))
        }
        
        with open(os.path.join(self.output_dir, "ioc_summary.json"), 'w') as f:
            json.dump(summary, f, indent=2)
        
        return summary
    
    def run(self):
        """Main extraction workflow"""
        print("\n[+] IOC Extraction Tool - Insider Threat Lab")
        print(f"[+] Evidence Directory: {self.evidence_dir}")
        print(f"[+] Output Directory: {self.output_dir}\n")
        
        # Extract from various evidence sources
        self.extract_from_processes(os.path.join(self.evidence_dir, "processes.csv"))
        self.extract_from_network(os.path.join(self.evidence_dir, "netconn.csv"))
        self.extract_from_dns(os.path.join(self.evidence_dir, "dns_cache.csv"))
        self.extract_from_usb(os.path.join(self.evidence_dir, "usb.csv"))
        self.extract_from_tasks(os.path.join(self.evidence_dir, "tasks.csv"))
        self.generate_file_hashes(self.evidence_dir)
        
        # Export
        summary = self.export_iocs()
        
        print(f"[+] Total IOCs extracted: {summary['total_iocs']}")
        print(f"[+] High severity IOCs: {summary['high_severity_count']}")
        for k, v in summary['breakdown'].items():
            print(f"    - {k}: {v}")
        print(f"\n[+] MITRE techniques: {', '.join(summary['mitre_techniques_observed'])}")
        print(f"[+] Results saved to: {self.output_dir}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python ioc_extraction.py <evidence_directory> [output_directory]")
        print("Example: python ioc_extraction.py C:\\IncidentResponse\\IR_2024\\evidence")
        sys.exit(1)
    
    evidence_dir = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None
    
    extractor = IOCExtractor(evidence_dir, output_dir)
    extractor.run()
