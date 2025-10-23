<#
  remove_legacy_powershell.ps1
  Entfernt alte Windows PowerShell 5.x aus Startmenue, Taskleiste und Kontextmenues.
  Startet sich bei Bedarf automatisch mit Administratorrechten neu.
  PowerShell 7 bleibt voll funktionsfaehig.
#>

# Automatisch mit Adminrechten neu starten, falls noetig
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Neustart mit Administratorrechten..." -ForegroundColor Yellow
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "`n=== Entferne alte Windows PowerShell aus Startmenue ===`n" -ForegroundColor Cyan

# 1?? Startmenue-Pfade
$startMenuPaths = @(
  "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Windows PowerShell",
  "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell"
)

foreach ($path in $startMenuPaths) {
    if (Test-Path $path) {
        Write-Host "Entferne: $path" -ForegroundColor Yellow
        try {
            Remove-Item -Recurse -Force -Path $path -ErrorAction Stop
        } catch {
            Write-Warning ("Konnte {0} nicht vollstaendig loeschen: {1}" -f $path, $_.Exception.Message)
        }
    }
}

# 2?? Taskleisten-Verknuepfung
$taskbar = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Windows PowerShell.lnk"
if (Test-Path $taskbar) {
    Write-Host "Entferne Taskleisten-Eintrag: $taskbar" -ForegroundColor Yellow
    Remove-Item -Force $taskbar
}

# 3?? Kontextmenues (Registry)
$keys = @(
  "HKCR\Directory\Background\shell\Powershell",
  "HKCR\Directory\shell\Powershell"
)
foreach ($k in $keys) {
    if (Test-Path $k) {
        Write-Host "Entferne Registry-Key: $k" -ForegroundColor Yellow
        try {
            Remove-Item -Path $k -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Warning ("Fehler beim Entfernen von {0}: {1}" -f $k, $_.Exception.Message)
        }
    }
}

# 4?? Windows-Tools-Eintrag
$toolsLnk = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Windows Tools\Windows PowerShell.lnk"
if (Test-Path $toolsLnk) {
    Write-Host "Entferne Windows Tools-Verknuepfung: $toolsLnk" -ForegroundColor Yellow
    Remove-Item -Force $toolsLnk
}

# 5?? Explorer neu starten
Write-Host "`nStarte Windows Explorer neu, um Aenderungen anzuwenden..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force
Start-Process explorer.exe

Write-Host "`nBereinigung abgeschlossen." -ForegroundColor Green
Write-Host "Alte Windows PowerShell wurde aus Menues, Taskleiste und Tools entfernt." -ForegroundColor Green
Write-Host "PowerShell 7 bleibt voll funktionsfaehig." -ForegroundColor Cyan
