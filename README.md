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

---

## 🧱 DevOps Environment Setup in VMware Workstation

Dieses Projekt ist optimiert für die Nutzung unter **VMware Workstation Pro** auf Windows-Systemen.  
Es dient als stabile, performante und vollständig isolierte Entwicklungsumgebung für Docker, Kubernetes und Infrastruktur-Tests.

---

### ⚙️ Empfohlene Basis-VM (Ubuntu Server 24.04 LTS)

| Komponente | Empfehlung | Hinweise |
|-------------|-------------|----------|
| **OS** | Ubuntu Server 24.04 LTS (CLI only) | Minimal-Installation ohne Desktop |
| **vCPU** | 4 Kerne | für Docker/K8s ausreichend performant |
| **RAM** | 8–12 GB | je nach Workload (K3s, Prometheus, etc.) |
| **Disk** | 60 GB (SCSI, Thin Provision) | schnelles NVMe-Backend empfohlen |
| **Netzwerk** | NAT oder Bridged | NAT für lokale Isolation, Bridged für Cluster-Zugriff |
| **Virtualize VT-x/EPT** | ❌ deaktiviert | Nested Virtualization wird nicht benötigt |
| **IOMMU / Performance Counters** | ❌ deaktiviert | nur für spezielle Hardware-Tests erforderlich |
| **Shared Folder (optional)** | `C:\Tools\SharedVM → /mnt/hgfs/shared` | einfacher Datei-Austausch Host ↔ VM |
| **Snapshots** | aktiv | z. B. *ubuntu-dev-base* nach Docker-Setup |

---

### 🐳 Container & Cluster Setup

Empfohlene Tools innerhalb der VM:

| Komponente | Beschreibung |
|-------------|---------------|
| **Docker Engine** | Basis für Container-Entwicklung |
| **Docker Compose** | Multi-Container-Orchestrierung |
| **K3s oder MicroK8s** | Lightweight Kubernetes Distribution |
| **Helm** | Paket-Management für Kubernetes |
| **Prometheus + Grafana** | Monitoring & Visualisierung |
| **Node Exporter** | Systemmetriken aus der VM für Grafana |

Alle Komponenten laufen **direkt in der Ubuntu-VM** ohne Nested-Virtualization.  
Dadurch bleibt das Setup **stabil, portabel und performant**.

---

### 🧩 Best Practices

- Verwende Snapshots für stabile Meilensteine (z. B. `ubuntu-docker-base`, `ubuntu-k8s-ready`)
- Halte VMware Tools aktuell (`sudo apt install open-vm-tools`)
- Nutze `vmrun` oder PowerShell-Automation für Start/Stop-Skripte
- Optional: Nutze gemeinsame Volume-Mounts für lokale CI-Pipelines oder Build-Artefakte
- Sichere `/etc/docker`, `/var/lib/docker` und `/etc/rancher/k3s` regelmäßig mit `tar` oder `rsync`

---

### 💡 Warum dieses Setup optimal ist

- **Keine Hyper-V- oder WSL2-Konflikte**
- **Volle Hardware-Performance** dank direkter VT-x-Nutzung durch VMware
- **Isoliertes Dev-Lab**, das wie ein kleiner Produktions-Cluster funktioniert
- **Portabel:** VM lässt sich 1:1 auf Proxmox oder andere Systeme übertragen
- **Reproduzierbar:** Gleiche Basis für alle DevOps- oder KI-Tests

---

> 🧠 *Tipp:*  
> Richte dir eine Baseline-VM ein („ubuntu-dev-base“) und klone sie für verschiedene Projekte (z. B. *docker-lab*, *k8s-lab*, *monitoring-lab*).  
> So bleiben deine Umgebungen sauber getrennt, und du kannst neue Tools gefahrlos ausprobieren.

