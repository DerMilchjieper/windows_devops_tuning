<#  
  rdp_check_and_fix.ps1
  Prüft und repariert RDP-Verbindungen (Firewall, Listener, Dienst, Gruppenrechte)
  Nutzung:
    .\rdp_check_and_fix.ps1
    .\rdp_check_and_fix.ps1 -Fix
#>

param([switch]$Fix)

Write-Host "`n=== RDP Check & Fix ===`n" -ForegroundColor Cyan

# 1. Dienst prüfen
$service = Get-Service TermService -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq 'Running') {
    Write-Host " TermService läuft" -ForegroundColor Green
} else {
    Write-Host " TermService nicht aktiv!" -ForegroundColor Yellow
    if ($Fix) {
        Write-Host "-> Starte Dienst..." -ForegroundColor Cyan
        Start-Service TermService -ErrorAction SilentlyContinue
    }
}

# 2. Firewall prüfen
$firewallRules = Get-NetFirewallRule -DisplayGroup "Remotedesktop" -ErrorAction SilentlyContinue
if ($firewallRules | Where-Object { $_.Enabled -eq 'True' }) {
    Write-Host " Firewall-Regeln für RDP sind aktiv" -ForegroundColor Green
} else {
    Write-Host " Firewall-Regeln für RDP sind deaktiviert!" -ForegroundColor Yellow
    if ($Fix) {
        Write-Host "-> Aktiviere Firewall-Regeln..." -ForegroundColor Cyan
        Enable-NetFirewallRule -DisplayGroup "Remotedesktop" | Out-Null
    }
}

# 3. RDP-Port prüfen
$listener = netstat -ano | findstr ":3389"
if ($listener) {
    Write-Host " RDP Listener läuft auf Port 3389" -ForegroundColor Green
} else {
    Write-Host " Kein aktiver RDP Listener auf Port 3389!" -ForegroundColor Yellow
    if ($Fix) {
        Write-Host "-> Setze Standardport zurück..." -ForegroundColor Cyan
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 3389 /f | Out-Null
        Restart-Service TermService -Force
    }
}

# 4. Benutzerrechte prüfen
$rdpUsers = Get-LocalGroupMember -Group "Remotedesktopbenutzer" | Select-Object -ExpandProperty Name
if ($rdpUsers -contains "$env:COMPUTERNAME\wizzard") {
    Write-Host " Benutzer 'wizzard' hat RDP-Rechte" -ForegroundColor Green
} else {
    Write-Host " Benutzer 'wizzard' fehlt in der RDP-Gruppe!" -ForegroundColor Yellow
    if ($Fix) {
        Write-Host "-> Füge 'wizzard' hinzu..." -ForegroundColor Cyan
        Add-LocalGroupMember -Group "Remotedesktopbenutzer" -Member "wizzard"
    }
}

# 5. Optimierungen (nur im Fix-Modus)
if ($Fix) {
    Write-Host "`n=== Anwenden von Optimierungen ===" -ForegroundColor Cyan
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v KeepAliveTimeout /t REG_DWORD /d 60000 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MaxMonitors /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v fDisableCam /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v fDisableAudioCapture /t REG_DWORD /d 1 /f | Out-Null
    Write-Host " RDP-Optimierungen angewendet" -ForegroundColor Green
}

Write-Host ""
Write-Host "RDP-Check abgeschlossen." -ForegroundColor Cyan
Write-Host "-> Teste nun: mstsc /v:127.0.0.1" -ForegroundColor Yellow
