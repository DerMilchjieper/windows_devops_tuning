# ===============================================
#  Windows DevOps Tuning – Interaktives Setup
#  Autor: Michael Zenkert (ai4industry)
#  Erstellt: 2025-10-23
# ===============================================

param([switch]$Silent)

# --- UTF-8 Fix ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Adminrechte sicherstellen ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "🔐 Starte mit Administratorrechten neu..." -ForegroundColor Yellow
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- Pfade & Logging ---
$basePath = "C:\Tools\windows_devops_tuning"
$logDir   = Join-Path $basePath "logs"
$logFile  = Join-Path $logDir ("setup_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log")

if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

Start-Transcript -Path $logFile -Force | Out-Null
Write-Host "`n=== 🚀 Windows DevOps Setup gestartet ===`n" -ForegroundColor Cyan

function Run-Step {
    param(
        [string]$Title,
        [string]$Script,
        [string]$Description
    )

    Write-Host "`n=== ⚙️ $Title ===" -ForegroundColor Green
    if (Test-Path "$basePath\$Script") {
        $answer = Read-Host "➡️  $Description (J/N)"
        if ($answer -match '^[JjYy]$') {
            Write-Host "▶ Starte $Script..." -ForegroundColor Cyan
            try {
                & "$basePath\$Script"
                Write-Host "✅ $Title abgeschlossen." -ForegroundColor Green
            } catch {
                Write-Warning "❌ Fehler beim Ausführen von ${Script}: ${_}"
            }
        } else {
            Write-Host "⏭ Übersprungen: $Title" -ForegroundColor DarkGray
        }
    } else {
        Write-Warning "⚠️ Datei nicht gefunden: $basePath\$Script"
    }
}

# --- Schritt 1: PowerShell ---
Run-Step -Title "PowerShell 7 aktualisieren" `
         -Script "update_powershell_latest.ps1" `
         -Description "Willst du PowerShell auf die aktuelle Stable-Version bringen?"

# --- Schritt 2: PowerShell 7 als Standard setzen ---
Run-Step -Title "PowerShell 7 als Standard-Terminal setzen" `
         -Script "set_pwsh_default.ps1" `
         -Description "Willst du PowerShell 7 systemweit als Standard-Terminal aktivieren?"

# --- Schritt 3: Entwickler-Tools ---
Run-Step -Title "Entwicklungs-Tools installieren" `
         -Script "install_dev_tools.ps1" `
         -Description "Willst du VS Code, Sublime Text und VMware Workstation Pro installieren?"

# --- Schritt 4: VMware Ready Check ---
Run-Step -Title "VMware Ready Check ausführen" `
         -Script "vmware_ready_check.ps1" `
         -Description "Willst du prüfen, ob dein System für VMware-Workstation bereit ist?"

# --- Schritt 5: RDP prüfen/fixen ---
Run-Step -Title "RDP Check & Fix" `
         -Script "rdp_check_and_fix.ps1 -Fix" `
         -Description "Willst du Remotedesktop (RDP) prüfen und ggf. reparieren?"

# --- Schritt 6: Klassisches Kontextmenü ---
Run-Step -Title "Klassisches Kontextmenü aktivieren" `
         -Script "restore_classic_context_menu.ps1 -Enable" `
         -Description "Willst du das klassische Windows 10 Kontextmenü aktivieren?"

# --- Schritt 7: Alte PowerShell aus Startmenü entfernen ---
Run-Step -Title "Alte PowerShell-Verknüpfungen entfernen" `
         -Script "remove_legacy_powershell.ps1" `
         -Description "Willst du alte Windows PowerShell-Verknüpfungen aus dem Startmenü entfernen?"

# --- Abschluss ---
Write-Host "`n=== 🏁 Setup abgeschlossen ===" -ForegroundColor Cyan
Write-Host "📄 Log gespeichert unter: $logFile" -ForegroundColor DarkCyan
Write-Host "💡 Tipp: Starte dein System neu, um alle Änderungen zu übernehmen." -ForegroundColor Yellow

Stop-Transcript | Out-Null
