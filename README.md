# 🧰 Windows DevOps Tuning Suite
**High-Performance System Hardening & Automation for Industrial AI Workflows**

> *"Consistency in the development environment is the first step toward reliability in production. This suite ensures that Windows 11 operates as a stable, high-performance DevOps workstation—without telemetry, without clutter."*
>
> *"Konsistenz in der Entwicklungsumgebung ist der erste Schritt zur Zuverlässigkeit in der Produktion. Diese Suite stellt sicher, dass Windows 11 als stabile, hochperformante DevOps-Workstation agiert – ohne Telemetrie, ohne Ballast."*

---

### 🧠 Core Philosophy | Kernphilosophie
**Industrial-Grade Windows (DE/EN):**
Diese Toolbox wurde entwickelt, um Windows 11 für den Einsatz in anspruchsvollen **Industrial AI- und HPC-Umgebungen** zu optimieren. Der Fokus liegt auf maximaler Kontrolle, Deaktivierung unnötiger Hintergrunddienste (Hyper-V/VBS Konflikte) und der Automatisierung des Tool-Deployments.
*This toolbox was developed to optimize Windows 11 for use in demanding **Industrial AI and HPC environments**. The focus is on maximum control, disabling unnecessary background services (Hyper-V/VBS conflicts), and automating tool deployment.*

---

### 🚀 Key Capabilities | Hauptfunktionen

#### 🧱 Virtualization Excellence (VMware)
Spezialisierte Skripte zur Deaktivierung von Windows-Features, die mit der Hardware-Virtualisierung (VT-x/VT-d) konkurrieren.
*Specialized scripts to disable Windows features that compete with hardware virtualization (VT-x/VT-d).*
- **Script:** `vmware_ready_check.ps1`
- **Impact:** Disables Hyper-V, VBS, and Device Guard for native VMware performance.

#### 🖥️ PowerShell 7 Modernization
Automatisierte Migration auf PowerShell 7 als primäre Shell, inklusive Bereinigung von Legacy-Komponenten.
*Automated migration to PowerShell 7 as the primary shell, including the removal of legacy components.*
- **Scripts:** `update_powershell_latest.ps1`, `remove_legacy_powershell.ps1`.

#### 🔒 System Hardening & DevOps Setup
Gezielte Reparatur von RDP-Diensten, Windows Hello Fixes und automatisiertes Winget-basiertes Tooling.
*Targeted repair of RDP services, Windows Hello fixes, and automated Winget-based tooling.*
- **Scripts:** `rdp_check_and_fix.ps1`, `install_dev_tools.ps1`, `setup_windows_devops.ps1`.

---

### 🛠️ Quickstart | Schnellstart

**1. Clone the Suite:**
```powershell
git clone https://github.com/DerMilchjieper/windows_devops_tuning.git "C:\Tools\windows_devops_tuning"
cd C:\Tools\windows_devops_tuning
```

**2. Execute Full DevOps Setup (Admin required):**
```powershell
pwsh -ExecutionPolicy Bypass -File .\setup_windows_devops.ps1
```

**3. Optimize for VMware:**
```powershell
.\vmware_ready_check.ps1 -Fix
```

---

### 🧩 Technical Insights | Technische Einblicke

- **Telemetry-Free:** Alle Skripte sind darauf ausgelegt, die System-Privatsphäre zu erhöhen und unnötige "Phone-Home" Dienste zu reduzieren.
- **Idempotent Design:** Die Skripte können mehrfach ausgeführt werden, ohne das System in einen inkonsistenten Zustand zu bringen.
- **Offline-Ready:** Fokus auf lokale Ausführung und minimale externe Abhängigkeiten (außer Winget für Tooling).

---

### 🪪 License & Usage
Dieses Projekt steht unter der **MIT License**.
*This project is licensed under the **MIT License**.*

---

### 📬 Connect with the Architect
- **Vibe:** Senior Enterprise Architect, Industrial AI Specialist.
- **Context:** Created for daily use in industrial AI and HPC environments.
- **Web:** [zentrader.io](https://zentrader.io)

---
*Automation suite generated and maintained by Gemini CLI | Performance-first philosophy.*
