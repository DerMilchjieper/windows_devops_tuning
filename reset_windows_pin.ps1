<#
.SYNOPSIS
    Repariert Windows Hello / PIN-Login (Ngc-Ordner zurücksetzen).

.DESCRIPTION
    Dieses Skript entfernt den defekten Windows Hello PIN-Speicher (Ngc-Ordner)
    und ermöglicht danach das erneute Einrichten der PIN über die Windows-Anmeldung.
    Es wird SYSTEM-Zugriff über PsExec oder Task-Scheduler verwendet, um Berechtigungen zu erhalten.

.NOTES
    Autor: Michael Zenkert (DerMilchjieper)
    Version: 1.0
    Kompatibel mit: Windows 10 / 11 Pro (PowerShell 5.1 / 7+)
    Repository: https://github.com/DerMilchjieper/windows_devops_tuning

.PARAMETER Force
    Überspringt Sicherheitsabfragen (z. B. bei automatisierten Deployments).

.EXAMPLE
    PS> .\reset_windows_pin.ps1
    Führt das Skript interaktiv aus und setzt den PIN-Speicher zurück.

.EXAMPLE
    PS> .\reset_windows_pin.ps1 -Force
    Führt das Skript ohne Rückfrage aus (automatisiert).
#>

param([switch]$Force)

Write-Host ""
Write-Host "=== Windows Hello / PIN Repair Utility ===" -ForegroundColor Cyan
Write-Host ""

# --- Pfad zum Ngc-Ordner ---
$NgcPath = "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"

# --- Prüfen, ob der Ordner existiert ---
if (-not (Test-Path $NgcPath)) {
    Write-Host "⚠️  Kein Ngc-Ordner gefunden. Windows Hello ist vermutlich deaktiviert." -ForegroundColor Yellow
    exit
}

# --- Prüfen, ob Skript als Administrator läuft ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "❌ Bitte starte PowerShell **als Administrator**." -ForegroundColor Red
    exit 1
}

# --- Info anzeigen ---
Write-Host "Dieser Vorgang entfernt den aktuellen Windows Hello/PIN-Container." -ForegroundColor Yellow
Write-Host "Nach dem Neustart kannst du deinen PIN neu einrichten." -ForegroundColor Yellow
if (-not $Force) {
    $confirm = Read-Host "Fortfahren? (J/N)"
    if ($confirm -ne "J" -and $confirm -ne "j") { exit }
}

# --- SYSTEM-Zugriff per PsExec oder Task ---
$PsExecPath = "C:\Tools\PSTools\PsExec64.exe"
if (-not (Test-Path $PsExecPath)) {
    Write-Host "➡️  Lade PsExec von Microsoft Sysinternals herunter:" -ForegroundColor Cyan
    Write-Host "    https://learn.microsoft.com/sysinternals/downloads/psexec"
    exit
}

Write-Host "Starte SYSTEM-Sitzung zum Löschen des Ngc-Ordners..." -ForegroundColor Cyan

# --- SYSTEM-Kommando vorbereiten ---
$cmd = "powershell -Command `"Remove-Item -Path '$NgcPath' -Recurse -Force -ErrorAction SilentlyContinue`""
Start-Process -FilePath $PsExecPath -ArgumentList "-accepteula", "-i", "-s", $cmd -Wait

Start-Sleep -Seconds 3

# --- Prüfen, ob der Ordner gelöscht wurde ---
if (-not (Test-Path $NgcPath)) {
    Write-Host "✅ Ngc-Ordner erfolgreich gelöscht!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Der Ngc-Ordner konnte nicht vollständig entfernt werden." -ForegroundColor Yellow
}

# --- Empfehlung anzeigen ---
Write-Host ""
Write-Host "Bitte führe jetzt einen Neustart durch, um den PIN neu einzurichten." -ForegroundColor Cyan
Write-Host "👉  shutdown /r /t 0"
Write-Host ""
