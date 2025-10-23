<#
  restore_classic_context_menu.ps1
  Aktiviert das klassische Kontextmenü von Windows 10 unter Windows 11
  Nutzung:
    .\restore_classic_context_menu.ps1 -Enable   # Aktivieren
    .\restore_classic_context_menu.ps1 -Disable  # Zurück auf Win11-Style
#>

param(
  [switch]$Enable,
  [switch]$Disable
)

if ($Enable) {
    Write-Host " Aktiviere klassisches Kontextmenü..." -ForegroundColor Cyan
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
    Write-Host " Aktiviert. Starte Explorer neu..." -ForegroundColor Green
}
elseif ($Disable) {
    Write-Host "  Setze Windows 11-Kontextmenü wieder zurück..." -ForegroundColor Cyan
    reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
    Write-Host " Deaktiviert. Starte Explorer neu..." -ForegroundColor Green
}
else {
    Write-Host " Bitte Parameter angeben: -Enable oder -Disable" -ForegroundColor Yellow
    exit
}

taskkill /F /IM explorer.exe
Start-Sleep -Seconds 1
start explorer.exe
Write-Host " Explorer neu gestartet  Änderungen aktiv." -ForegroundColor Cyan
