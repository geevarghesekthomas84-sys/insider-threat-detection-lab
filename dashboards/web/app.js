// SOC Dashboard - Insider Threat Detection Lab
// Main Application Logic

// ==================== SIMULATED DATA ====================
const alertsData = [
  { time: "22:34:15", severity: "critical", ruleId: "100950", desc: "Sensitive file access + USB device - Active exfiltration", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1005, T1052.001", status: "open" },
  { time: "22:31:02", severity: "critical", ruleId: "100400", desc: "Security audit log cleared - Anti-forensics detected", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1070.001", status: "open" },
  { time: "22:28:47", severity: "critical", ruleId: "100300", desc: "PowerShell offensive tool execution detected", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1059.001", status: "investigating" },
  { time: "22:25:33", severity: "critical", ruleId: "100900", desc: "Credential dumping tool detected - LSASS access", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1003.001", status: "open" },
  { time: "22:22:10", severity: "critical", ruleId: "100701", desc: "Cloud storage upload detected - drive.google.com", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1567.002", status: "investigating" },
  { time: "22:18:55", severity: "high", ruleId: "100101", desc: "USB storage device connected during off-hours", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1052.001", status: "open" },
  { time: "22:15:20", severity: "high", ruleId: "100500", desc: "After-hours login detected (22:15)", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1078", status: "acknowledged" },
  { time: "22:14:05", severity: "high", ruleId: "100600", desc: "After-hours RDP login - Remote access", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1021.001", status: "acknowledged" },
  { time: "22:12:30", severity: "high", ruleId: "100301", desc: "PowerShell download/execution pattern detected", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1059.001", status: "open" },
  { time: "22:10:18", severity: "high", ruleId: "100302", desc: "PowerShell obfuscated/hidden execution", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1059.001, T1027", status: "open" },
  { time: "22:08:42", severity: "medium", ruleId: "100200", desc: "FIM: Sensitive file modified - C:\\SensitiveData\\Financial", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1005", status: "acknowledged" },
  { time: "22:07:15", severity: "medium", ruleId: "100303", desc: "PowerShell file collection/staging activity", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1074.001", status: "open" },
  { time: "22:05:50", severity: "medium", ruleId: "100800", desc: "Scheduled task created - Persistence", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1053.005", status: "open" },
  { time: "22:04:20", severity: "medium", ruleId: "100702", desc: "File archiving with compression detected", agent: "WIN-INSIDER-01", user: "jsmith", mitre: "T1560.001", status: "open" },
  { time: "22:02:00", severity: "low", ruleId: "100102", desc: "New USB device driver installed", agent: "WIN-INSIDER-01", user: "SYSTEM", mitre: "T1052.001", status: "closed" },
];

const mitreData = [
  { id: "T1078", name: "Valid Accounts", tactic: "Initial Access", detections: 3, status: "detected" },
  { id: "T1059.001", name: "PowerShell", tactic: "Execution", detections: 8, status: "detected" },
  { id: "T1053.005", name: "Scheduled Task", tactic: "Persistence", detections: 2, status: "detected" },
  { id: "T1547.001", name: "Registry Run Keys", tactic: "Persistence", detections: 1, status: "covered" },
  { id: "T1548.002", name: "UAC Bypass", tactic: "Privilege Escalation", detections: 0, status: "covered" },
  { id: "T1070.001", name: "Clear Event Logs", tactic: "Defense Evasion", detections: 2, status: "detected" },
  { id: "T1027", name: "Obfuscated Files", tactic: "Defense Evasion", detections: 1, status: "detected" },
  { id: "T1562.001", name: "Disable Security Tools", tactic: "Defense Evasion", detections: 1, status: "partial" },
  { id: "T1003.001", name: "LSASS Memory", tactic: "Credential Access", detections: 2, status: "detected" },
  { id: "T1552.001", name: "Credentials In Files", tactic: "Credential Access", detections: 1, status: "covered" },
  { id: "T1083", name: "File Discovery", tactic: "Discovery", detections: 3, status: "detected" },
  { id: "T1082", name: "System Info Discovery", tactic: "Discovery", detections: 1, status: "covered" },
  { id: "T1021.001", name: "Remote Desktop", tactic: "Lateral Movement", detections: 2, status: "detected" },
  { id: "T1005", name: "Data from Local System", tactic: "Collection", detections: 5, status: "detected" },
  { id: "T1074.001", name: "Local Data Staging", tactic: "Collection", detections: 2, status: "detected" },
  { id: "T1560.001", name: "Archive via Utility", tactic: "Collection", detections: 2, status: "detected" },
  { id: "T1052.001", name: "Exfil Over USB", tactic: "Exfiltration", detections: 4, status: "detected" },
  { id: "T1567.002", name: "Exfil to Cloud", tactic: "Exfiltration", detections: 3, status: "detected" },
  { id: "T1105", name: "Ingress Tool Transfer", tactic: "Command and Control", detections: 1, status: "partial" },
];

const timelineData = [
  { time: "22:02:00", phase: "Initial Access", title: "After-Hours RDP Login", desc: "User jsmith logged in via RDP from 192.168.56.10 outside business hours", severity: "high", mitre: "T1078" },
  { time: "22:05:50", phase: "Discovery", title: "File & Directory Enumeration", desc: "Recursive listing of C:\\SensitiveData and C:\\ConfidentialProjects", severity: "medium", mitre: "T1083" },
  { time: "22:08:42", phase: "Collection", title: "Sensitive File Access", desc: "Read financial reports, HR records, and customer PII files", severity: "high", mitre: "T1005" },
  { time: "22:12:30", phase: "Staging", title: "Data Staging & Archiving", desc: "Files copied to temp directory and compressed into ZIP archive", severity: "high", mitre: "T1074.001" },
  { time: "22:18:55", phase: "Exfiltration", title: "USB Device Connected", desc: "USB storage device connected and archive copied", severity: "critical", mitre: "T1052.001" },
  { time: "22:22:10", phase: "Exfiltration", title: "Cloud Upload Attempt", desc: "DNS queries to drive.google.com, dropbox.com, mega.nz", severity: "critical", mitre: "T1567.002" },
  { time: "22:25:33", phase: "Credential Access", title: "LSASS Memory Access", desc: "Attempted credential harvesting via LSASS process access", severity: "critical", mitre: "T1003.001" },
  { time: "22:28:47", phase: "Execution", title: "Malicious PowerShell", desc: "Encoded commands and download cradle patterns executed", severity: "critical", mitre: "T1059.001" },
  { time: "22:31:02", phase: "Defense Evasion", title: "Security Log Cleared", desc: "Security audit log was cleared to cover tracks", severity: "critical", mitre: "T1070.001" },
  { time: "22:34:15", phase: "Persistence", title: "Scheduled Task Created", desc: "Persistence mechanism via scheduled task at 3:00 AM", severity: "high", mitre: "T1053.005" },
];

const endpoints = [
  { name: "WIN-INSIDER-01", ip: "192.168.56.20", os: "Windows 10 Pro", role: "Employee Workstation", status: "compromised", icon: "💻", agents: "Wazuh + Sysmon + Splunk UF", alerts: 15, lastSeen: "22:34:15" },
  { name: "DC-01", ip: "192.168.56.30", os: "Windows Server 2019", role: "Domain Controller", status: "online", icon: "🖥️", agents: "Wazuh + Sysmon", alerts: 2, lastSeen: "22:35:00" },
  { name: "SOC-SERVER", ip: "192.168.56.40", os: "Ubuntu 22.04 LTS", role: "Wazuh + ELK + Splunk", status: "online", icon: "🛡️", agents: "Wazuh Manager", alerts: 0, lastSeen: "22:35:01" },
  { name: "KALI-ATTACK", ip: "192.168.56.10", os: "Kali Linux 2024.1", role: "Attack Simulation", status: "online", icon: "🐉", agents: "Monitored via network", alerts: 0, lastSeen: "22:30:00" },
];

const irPhases = [
  { icon: "🔍", title: "Detection", desc: "Wazuh FIM alert triggered on sensitive file access. USB connection detected.", status: "completed" },
  { icon: "📊", title: "Triage & Analysis", desc: "Alert severity assessed as CRITICAL. Multiple IOCs correlated.", status: "completed" },
  { icon: "🔬", title: "Investigation", desc: "Full timeline reconstructed. 10 MITRE techniques identified.", status: "completed" },
  { icon: "🔒", title: "Containment", desc: "User account disabled. Network isolated. USB blocked.", status: "active-phase" },
  { icon: "🧹", title: "Eradication", desc: "Remove persistence mechanisms. Revoke all access tokens.", status: "pending" },
  { icon: "🔄", title: "Recovery", desc: "Restore systems. Verify data integrity. Resume operations.", status: "pending" },
  { icon: "📝", title: "Lessons Learned", desc: "Document findings. Update detection rules. Brief stakeholders.", status: "pending" },
];

const evidenceItems = [
  { item: "Security.evtx", type: "Event Log", hash: "a3f2c1...8b4e", collected: "22:40:00", custodian: "SOC-01" },
  { item: "Sysmon.evtx", type: "Event Log", hash: "b7d4e2...9c3f", collected: "22:40:05", custodian: "SOC-01" },
  { item: "PowerShell.evtx", type: "Event Log", hash: "c5a8f3...1d2e", collected: "22:40:10", custodian: "SOC-01" },
  { item: "processes.csv", type: "Volatile Data", hash: "d9b1c4...7e5a", collected: "22:41:00", custodian: "SOC-01" },
  { item: "netconn.csv", type: "Volatile Data", hash: "e2f6a8...4b9c", collected: "22:41:05", custodian: "SOC-01" },
  { item: "dns_cache.csv", type: "Volatile Data", hash: "f4c3d7...6a8b", collected: "22:41:10", custodian: "SOC-01" },
  { item: "usb_history.csv", type: "Registry", hash: "17e5b9...3c2d", collected: "22:42:00", custodian: "SOC-01" },
  { item: "ps_history.txt", type: "User Artifact", hash: "28a4c6...5f1e", collected: "22:42:30", custodian: "SOC-01" },
  { item: "exfil_package.zip", type: "Malware/Tool", hash: "39d7e2...8a4b", collected: "22:43:00", custodian: "SOC-01" },
];

const iocSummary = [
  { type: "IP Addresses", count: 7 },
  { type: "Domains", count: 6 },
  { type: "File Hashes", count: 12 },
  { type: "USB Devices", count: 2 },
  { type: "Processes", count: 9 },
  { type: "Registry Keys", count: 4 },
  { type: "Sched Tasks", count: 1 },
  { type: "User Accounts", count: 1 },
];

// ==================== NAVIGATION ====================
function switchTab(tabId) {
  document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.getElementById('tab-' + tabId).classList.add('active');
  document.querySelector(`[data-tab="${tabId}"]`).classList.add('active');
  const titles = { overview:'Security Overview', alerts:'Alert Feed', mitre:'MITRE ATT&CK', timeline:'Attack Timeline', endpoints:'Endpoint Status', incident:'IR Workflow', forensics:'Digital Forensics' };
  document.getElementById('pageTitle').textContent = titles[tabId] || 'Dashboard';
}

document.querySelectorAll('.nav-item').forEach(item => {
  item.addEventListener('click', () => switchTab(item.dataset.tab));
});

document.getElementById('menuToggle')?.addEventListener('click', () => {
  document.getElementById('sidebar').classList.toggle('open');
});

// ==================== LIVE CLOCK ====================
function updateClock() {
  const now = new Date();
  document.getElementById('liveTime').textContent = now.toLocaleTimeString('en-US', { hour12: false }) + ' UTC';
}
setInterval(updateClock, 1000);
updateClock();

// ==================== RENDER ALERTS TABLE ====================
function renderAlerts(containerId, data, limit) {
  const tbody = document.getElementById(containerId);
  const items = limit ? data.slice(0, limit) : data;
  tbody.innerHTML = items.map(a => `
    <tr>
      <td style="font-family:'JetBrains Mono',monospace;font-size:12px;color:var(--accent-cyan)">${a.time}</td>
      <td><span class="severity-badge ${a.severity}">${a.severity}</span></td>
      <td style="font-family:'JetBrains Mono',monospace">${a.ruleId}</td>
      <td>${a.desc}</td>
      <td>${a.agent || ''}</td>
      <td>${a.user || ''}</td>
      <td>${(a.mitre||'').split(',').map(m=>`<span class="mitre-tag">${m.trim()}</span>`).join(' ')}</td>
      <td><span class="severity-badge ${a.status==='open'?'critical':a.status==='investigating'?'high':'low'}">${a.status||'open'}</span></td>
    </tr>
  `).join('');
}

renderAlerts('recentAlertsBody', alertsData, 5);
renderAlerts('allAlertsBody', alertsData);

// ==================== FILTERS ====================
document.getElementById('severityFilter')?.addEventListener('change', function() {
  const val = this.value;
  const filtered = val === 'all' ? alertsData : alertsData.filter(a => a.severity === val);
  renderAlerts('allAlertsBody', filtered);
});

document.getElementById('categoryFilter')?.addEventListener('change', function() {
  const val = this.value;
  if (val === 'all') { renderAlerts('allAlertsBody', alertsData); return; }
  const map = { usb:'USB', powershell:'PowerShell', authentication:'login|RDP|After-hours', fim:'FIM|file', log_tampering:'log|cleared', insider_threat:'' };
  const pattern = map[val] || val;
  const filtered = pattern ? alertsData.filter(a => new RegExp(pattern, 'i').test(a.desc)) : alertsData;
  renderAlerts('allAlertsBody', filtered);
});

// ==================== MITRE GRID ====================
function renderMitre() {
  const grid = document.getElementById('mitreGrid');
  const tbody = document.getElementById('mitreTableBody');
  grid.innerHTML = mitreData.map(m => `
    <div class="mitre-cell ${m.status}" title="${m.tactic}">
      <div class="tech-id">${m.id}</div>
      <span class="tech-name">${m.name}</span>
    </div>
  `).join('');
  tbody.innerHTML = mitreData.map(m => `
    <tr>
      <td><span class="mitre-tag">${m.id}</span></td>
      <td>${m.name}</td>
      <td>${m.tactic}</td>
      <td style="font-family:'JetBrains Mono',monospace;font-weight:600;color:${m.detections>0?'var(--accent-red)':'var(--text-muted)'}">${m.detections}</td>
      <td><span class="severity-badge ${m.status==='detected'?'critical':m.status==='partial'?'medium':'low'}">${m.status}</span></td>
    </tr>
  `).join('');
}
renderMitre();

// ==================== TIMELINE ====================
function renderTimeline() {
  document.getElementById('attackTimeline').innerHTML = timelineData.map((t, i) => `
    <div class="timeline-item ${t.severity}" style="animation-delay:${i*0.1}s">
      <div class="timeline-time">${t.time} — ${t.phase}</div>
      <h4>${t.title} <span class="mitre-tag">${t.mitre}</span></h4>
      <p>${t.desc}</p>
    </div>
  `).join('');
}
renderTimeline();

// ==================== ENDPOINTS ====================
function renderEndpoints() {
  document.getElementById('endpointGrid').innerHTML = endpoints.map(e => `
    <div class="endpoint-card">
      <div class="endpoint-header">
        <span class="endpoint-icon">${e.icon}</span>
        <div>
          <div class="endpoint-name">${e.name}</div>
          <div class="endpoint-ip">${e.ip}</div>
        </div>
        <div class="endpoint-status ${e.status}">
          <div class="status-indicator" style="background:${e.status==='compromised'?'var(--accent-red)':'var(--accent-green)'}"></div>
          ${e.status.toUpperCase()}
        </div>
      </div>
      <div class="endpoint-details">
        <div><span>OS</span><span>${e.os}</span></div>
        <div><span>Role</span><span>${e.role}</span></div>
        <div><span>Agents</span><span>${e.agents}</span></div>
        <div><span>Alerts</span><span style="color:${e.alerts>0?'var(--accent-red)':'var(--accent-green)'}; font-weight:700">${e.alerts}</span></div>
        <div><span>Last Seen</span><span>${e.lastSeen}</span></div>
      </div>
    </div>
  `).join('');
}
renderEndpoints();

// ==================== IR WORKFLOW ====================
function renderIR() {
  document.getElementById('irWorkflow').innerHTML = irPhases.map(p => `
    <div class="ir-phase ${p.status}">
      <div class="ir-phase-icon">${p.icon}</div>
      <div class="ir-phase-title">${p.title}</div>
      <div class="ir-phase-desc">${p.desc}</div>
      <div class="ir-phase-status">${p.status==='completed'?'✓ Complete':p.status==='active-phase'?'● In Progress':'○ Pending'}</div>
    </div>
  `).join('');
}
renderIR();

// ==================== FORENSICS ====================
function renderForensics() {
  document.getElementById('evidenceBody').innerHTML = evidenceItems.map(e => `
    <tr>
      <td style="font-weight:600">${e.item}</td>
      <td><span class="severity-badge low">${e.type}</span></td>
      <td style="font-family:'JetBrains Mono',monospace;font-size:11px">${e.hash}</td>
      <td>${e.collected}</td>
      <td>${e.custodian}</td>
    </tr>
  `).join('');
  document.getElementById('iocCards').innerHTML = iocSummary.map(i => `
    <div class="ioc-card">
      <div class="ioc-count">${i.count}</div>
      <div class="ioc-type">${i.type}</div>
    </div>
  `).join('');
}
renderForensics();

// ==================== CHARTS (Canvas-based, no deps) ====================
function drawBarChart(canvasId, labels, datasets) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const w = canvas.width = canvas.parentElement.clientWidth - 40;
  const h = canvas.height = 200;
  const padding = { top: 20, right: 20, bottom: 40, left: 50 };
  const chartW = w - padding.left - padding.right;
  const chartH = h - padding.top - padding.bottom;

  ctx.clearRect(0, 0, w, h);

  const allValues = datasets.flatMap(d => d.data);
  const maxVal = Math.max(...allValues, 1);

  // Grid lines
  ctx.strokeStyle = 'rgba(148,163,184,0.1)';
  ctx.lineWidth = 1;
  for (let i = 0; i <= 4; i++) {
    const y = padding.top + (chartH / 4) * i;
    ctx.beginPath(); ctx.moveTo(padding.left, y); ctx.lineTo(w - padding.right, y); ctx.stroke();
    ctx.fillStyle = '#64748b'; ctx.font = '10px JetBrains Mono';
    ctx.textAlign = 'right';
    ctx.fillText(Math.round(maxVal - (maxVal / 4) * i), padding.left - 8, y + 4);
  }

  const barGroupWidth = chartW / labels.length;
  const barWidth = barGroupWidth / (datasets.length + 1);
  const colors = ['#ef4444', '#f97316', '#f59e0b', '#3b82f6'];

  datasets.forEach((ds, di) => {
    ds.data.forEach((val, i) => {
      const x = padding.left + i * barGroupWidth + (di + 0.5) * barWidth;
      const barH = (val / maxVal) * chartH;
      const y = padding.top + chartH - barH;

      const grad = ctx.createLinearGradient(x, y, x, y + barH);
      grad.addColorStop(0, colors[di] || '#06b6d4');
      grad.addColorStop(1, (colors[di] || '#06b6d4') + '40');
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.roundRect(x, y, barWidth * 0.8, barH, [3, 3, 0, 0]);
      ctx.fill();
    });
  });

  // Labels
  ctx.fillStyle = '#64748b'; ctx.font = '10px Inter'; ctx.textAlign = 'center';
  labels.forEach((label, i) => {
    ctx.fillText(label, padding.left + i * barGroupWidth + barGroupWidth / 2, h - 8);
  });
}

function drawDonutChart(canvasId, labels, data, colors) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const size = Math.min(canvas.parentElement.clientWidth - 40, 250);
  canvas.width = canvas.parentElement.clientWidth - 40;
  canvas.height = size;
  const cx = size / 2 + 20;
  const cy = size / 2;
  const radius = size * 0.38;
  const innerRadius = radius * 0.6;
  const total = data.reduce((a, b) => a + b, 0);

  ctx.clearRect(0, 0, canvas.width, canvas.height);

  let startAngle = -Math.PI / 2;
  data.forEach((val, i) => {
    const sliceAngle = (val / total) * Math.PI * 2;
    ctx.beginPath();
    ctx.arc(cx, cy, radius, startAngle, startAngle + sliceAngle);
    ctx.arc(cx, cy, innerRadius, startAngle + sliceAngle, startAngle, true);
    ctx.closePath();
    ctx.fillStyle = colors[i];
    ctx.fill();
    startAngle += sliceAngle;
  });

  // Center text
  ctx.fillStyle = '#f1f5f9'; ctx.font = 'bold 24px JetBrains Mono'; ctx.textAlign = 'center';
  ctx.fillText(total, cx, cy + 4);
  ctx.fillStyle = '#64748b'; ctx.font = '11px Inter';
  ctx.fillText('Total', cx, cy + 20);

  // Legend
  const legendX = size + 40;
  labels.forEach((label, i) => {
    const ly = 20 + i * 22;
    ctx.fillStyle = colors[i];
    ctx.fillRect(legendX, ly, 12, 12);
    ctx.fillStyle = '#94a3b8'; ctx.font = '12px Inter'; ctx.textAlign = 'left';
    ctx.fillText(`${label} (${data[i]})`, legendX + 18, ly + 10);
  });
}

// Draw charts on load
const hours = Array.from({ length: 24 }, (_, i) => `${i}:00`);
const critData = [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,5,2];
const highData = [0,0,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,4,3];
const medData =  [1,0,0,0,0,0,1,0,2,1,1,0,1,0,0,1,0,0,0,0,0,0,3,2];

drawBarChart('alertTimelineChart', hours, [
  { data: critData }, { data: highData }, { data: medData }
]);

drawDonutChart('categoryChart',
  ['USB/Exfil', 'PowerShell', 'Auth', 'FIM', 'Log Tamper', 'Cred Access'],
  [6, 8, 3, 4, 3, 2],
  ['#ef4444', '#8b5cf6', '#3b82f6', '#10b981', '#f59e0b', '#ec4899']
);

// Resize handler
window.addEventListener('resize', () => {
  drawBarChart('alertTimelineChart', hours, [{ data: critData }, { data: highData }, { data: medData }]);
  drawDonutChart('categoryChart', ['USB/Exfil','PowerShell','Auth','FIM','Log Tamper','Cred Access'], [6,8,3,4,3,2], ['#ef4444','#8b5cf6','#3b82f6','#10b981','#f59e0b','#ec4899']);
});

// ==================== SEARCH ====================
document.getElementById('globalSearch')?.addEventListener('input', function() {
  const q = this.value.toLowerCase();
  if (!q) { renderAlerts('allAlertsBody', alertsData); return; }
  const filtered = alertsData.filter(a =>
    Object.values(a).some(v => String(v).toLowerCase().includes(q))
  );
  renderAlerts('allAlertsBody', filtered);
});

// ==================== SIMULATED LIVE UPDATES ====================
let eventCounter = 1247;
setInterval(() => {
  eventCounter += Math.floor(Math.random() * 3);
  const el = document.getElementById('totalEvents');
  if (el) el.textContent = eventCounter.toLocaleString();
}, 5000);

console.log('[SOC Dashboard] Insider Threat Detection Lab - Initialized');
