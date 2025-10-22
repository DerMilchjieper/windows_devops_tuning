# Windows DevOps Tuning  VMware Ready Check

PowerShell-Skript, das Windows so prüft (und optional fixiert), dass **VMware Workstation** volle Hardware-Virtualisierung (VT-x/VT-d) nutzen kann.  
Getestet mit **Windows 11 24H2** und **Windows PowerShell 5.1**.

---

##  Features

- Prüft **VBS/Device Guard / Credential Guard**
- Prüft **Hyper-V / WSL / Containers** (optionale Windows-Features)
- Prüft **\cdedit hypervisorlaunchtype\**
- Prüft die **Hypervisor-Erkennung** via systeminfo
- **Fix-Modus** (-Fix) schaltet konfliktträchtige Features aus und setzt Boot-Optionen (Admin nötig)
- Rein **lokal**  keine Telemetrie oder Netzwerk-Calls

---

##  Schnellstart

`powershell
# in PowerShell (am besten als Admin) ins Repo wechseln
cd C:\Tools\vmware-ready

# Check (keine Änderungen am System)
.\vmware_ready_check.ps1

# Fix (schreibt Registry/BCDEdit/Features; Admin nötig)
.\vmware_ready_check.ps1 -Fix

