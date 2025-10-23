# 🧰 Windows DevOps Tuning Suite

Skriptsammlung zur Optimierung, Reparatur und Automatisierung von Windows 11 DevOps-Systemen.  
Ermöglicht eine stabile, performante und saubere Umgebung für VMware, PowerShell 7, RDP, VS Code und allgemeine Entwickler-Workflows.  
Alle Skripte sind **PowerShell-basiert**, **offline-fähig** und **ohne Telemetrie**.
---

## ⚙️ Windows DevOps Tuning Toolkit

Diese Sammlung enthält alle PowerShell-Skripte zur Optimierung, Wartung und Einrichtung deiner Windows DevOps-Umgebung.

| 🧩 Skriptname | 📝 Beschreibung | 💻 Beispielbefehl | 🔒 Admin nötig |
|---------------|----------------|-------------------|----------------|
| **vmware_ready_check.ps1** | Prüft & repariert Windows-Konfiguration für volle VMware-Virtualisierung (VT-x / VT-d) | `.\vmware_ready_check.ps1 -Fix` | ✅ |
| **update_powershell_latest.ps1** | Installiert oder aktualisiert PowerShell auf die neueste stabile Version | `.\update_powershell_latest.ps1` | ✅ |
| **set_pwsh_default.ps1** | Setzt PowerShell 7 als Standard-Shell in Windows Terminal & VS Code | `.\set_pwsh_default.ps1` | ✅ |
| **remove_legacy_powershell.ps1** | Entfernt alte Windows PowerShell-Verknüpfungen aus dem Startmenü | `.\remove_legacy_powershell.ps1` | ✅ |
| **restore_classic_context_menu.ps1** | Aktiviert das klassische Windows-10-Kontextmenü unter Windows 11 | `.\restore_classic_context_menu.ps1 -Enable` | ✅ |
| **install_dev_tools.ps1** | Installiert VMware Workstation Pro, VS Code & Sublime Text 4 über Winget | `.\install_dev_tools.ps1` | ✅ |
| **reset_windows_pin.ps1** | Entfernt beschädigte Windows-PIN-Anmeldedaten (Hello-Fix) | `.\reset_windows_pin.ps1` | ✅ |
| **rdp_check_and_fix.ps1** | Prüft & repariert Remotedesktop-Dienste & Firewall-Regeln | `.\rdp_check_and_fix.ps1 -Fix` | ✅ |
| **setup_windows_devops.ps1** | Führt alle DevOps-Setup-Skripte in sinnvoller Reihenfolge aus | `.\setup_windows_devops.ps1` | ✅ |
| **list_autostart.ps1** | Listet alle Autostart-Programme aus Registry & Startup-Ordnern<br>Optional mit HTML-Report | `.\list_autostart.ps1 -HtmlReport` | ❌ |

---

📁 **Tipp:**  
Alle Skripte liegen in `C:\Tools\windows_devops_tuning` und sind UTF-8-kodiert.  
Falls du dein System neu aufsetzt, kannst du einfach das Repo neu klonen und `setup_windows_devops.ps1` ausführen.

```powershell
git clone https://github.com/DerMilchjieper/windows_devops_tuning.git "C:\Tools\windows_devops_tuning"
cd C:\Tools\windows_devops_tuning
pwsh -ExecutionPolicy Bypass -File .\setup_windows_devops.ps1
---

## 🚀 Schnellstart

```powershell
# Repository klonen
git clone https://github.com/DerMilchjieper/windows_devops_tuning.git
cd windows_devops_tuning

# Skripte ausführen (am besten als Administrator)
.\vmware_ready_check.ps1 -Fix
.\update_powershell_latest.ps1
.\install_dev_tools.ps1
🧠 Übersicht aller Skripte
🖥️ System & PowerShell
Skript	Beschreibung
update_powershell_latest.ps1	Installiert oder aktualisiert PowerShell 7 auf die neueste stabile Version via Winget.
set_pwsh_default.ps1	Setzt PowerShell 7 als Standard-Terminal in Windows & VS Code.
remove_legacy_powershell.ps1	Entfernt die alte Windows PowerShell 5.x aus Startmenü & Verknüpfungen (PowerShell 7 bleibt aktiv).
restore_classic_context_menu.ps1	Aktiviert das klassische Rechtsklick-Menü aus Windows 10 unter Windows 11.

🔒 Sicherheit & Login
Skript	Beschreibung
reset_windows_pin.ps1	Repariert Windows Hello / PIN-Login, falls dieser beschädigt oder gesperrt ist.
rdp_check_and_fix.ps1	Prüft RDP-Dienste, Firewall, Benutzerrechte und Listener; optional Fix-Modus mit Optimierungen.

🧱 DevOps & Virtualisierung
Skript	Beschreibung
vmware_ready_check.ps1	Prüft und deaktiviert Hyper-V / VBS / WSL, um VMware Workstation volle Hardware-Virtualisierung (VT-x/VT-d) zu ermöglichen.
install_dev_tools.ps1	Installiert Entwicklungs-Tools (VMware Workstation Pro, Visual Studio Code, Sublime Text 4) über Winget.
setup_windows_devops.ps1	(optional) Automatisierte Grundkonfiguration deines Windows 11 DevOps-Systems mit Logging und Admin-Checks.

⚙️ Beispiel: VMware Ready Check
powershell
Code kopieren
# Testlauf (keine Änderungen)
.\vmware_ready_check.ps1

# Fix-Modus (erfordert Adminrechte)
.\vmware_ready_check.ps1 -Fix
Funktionen:

Deaktiviert Hyper-V, WSL2, Device Guard und VBS

Setzt hypervisorlaunchtype off

Prüft systeminfo und bcdedit-Status

Optimiert Boot-Optionen für volle Virtualisierungsleistung

📦 Empfohlene Umgebung
Komponente	Empfehlung
OS	Windows 11 Pro (24H2 oder neuer)
PowerShell	v7.5 oder neuer
VM	VMware Workstation Pro 17 + Ubuntu Server 24.04 LTS
Tools	VS Code, Sublime Text 4, Docker Desktop, Git, WSL (optional)

🪪 Lizenz
Dieses Projekt steht unter der MIT License.
Verwendung, Anpassung und Erweiterung sind ausdrücklich erlaubt.

💡 Hinweis
Diese Toolbox entstand aus realen Windows-DevOps-Setups von Michael Zenkert
für den täglichen Einsatz in industriellen KI- und HPC-Umgebungen.
Ziel ist maximale Stabilität, Kontrolle und Performance unter Windows 11.
