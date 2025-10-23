<#
  install_dev_tools.ps1
  Installiert VMware Workstation Pro, Visual Studio Code und Sublime Text automatisch.
  Getestet unter Windows 11 Pro (Build 24H2+).

  Nutzung:
    .\install_dev_tools.ps1
#>

Write-Host "`n=== Windows Dev Tools Installer ===`n" -ForegroundColor Cyan

# --- Voraussetzung prüfen: Winget ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Winget nicht gefunden. Bitte installiere das App Installer-Paket aus dem Microsoft Store und starte PowerShell neu." -ForegroundColor Red
    exit 1
}

# --- Liste der Tools ---
$apps = @(
    @{ Name = "VMware Workstation Pro"; Id = "VMware.WorkstationPro" },
    @{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode" },
    @{ Name = "Sublime Text"; Id = "SublimeHQ.SublimeText.4" }
)

foreach ($app in $apps) {
    Write-Host "`n➡️  Installiere $($app.Name)..." -ForegroundColor Cyan
    $installed = winget list --id $($app.Id) 2>$null | Select-String $app.Id
    if ($installed) {
        Write-Host "   ✅ Bereits installiert: $($app.Name)" -ForegroundColor Green
    } else {
        try {
            winget install --id $($app.Id) --silent --accept-package-agreements --accept-source-agreements -h 0
            Write-Host "   ✅ Erfolgreich installiert: $($app.Name)" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️ Fehler bei der Installation von $($app.Name): $_" -ForegroundColor Yellow
        }
    }
}

# --- Nacharbeiten ---
Write-Host "`n=== Installation abgeschlossen ===" -ForegroundColor Green
Write-Host "Starte ggf. dein System neu, wenn VMware-Treiber installiert wurden." -ForegroundColor Yellow
Write-Host "Tipp: Du kannst die Tools später mit 'winget upgrade' aktuell halten." -ForegroundColor Cyan
