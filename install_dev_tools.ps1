<#
  install_dev_tools.ps1
  Installiert VMware Workstation Pro, Visual Studio Code und Sublime Text automatisch.
  Getestet unter Windows 11 Pro (Build 24H2+).

  Nutzung:
    .\install_dev_tools.ps1
#>

# --- UTF-8 Ausgabe aktivieren ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n=== 🧰 Windows Dev Tools Installer ===`n" -ForegroundColor Cyan

# --- Winget prüfen ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Winget nicht gefunden. Bitte installiere das App Installer-Paket aus dem Microsoft Store und starte PowerShell neu." -ForegroundColor Red
    exit 1
}

# --- Zu installierende Tools ---
$apps = @(
    @{ Name = "VMware Workstation Pro"; Id = "VMware.WorkstationPro" },
    @{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode" },
    @{ Name = "Sublime Text 4"; Id = "SublimeHQ.SublimeText.4" }
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

Write-Host "`n=== ✅ Installation abgeschlossen ===" -ForegroundColor Green
Write-Host "💡 Starte dein System ggf. neu, wenn VMware-Treiber installiert wurden." -ForegroundColor Yellow
Write-Host "🧩 Tipp: Du kannst alle Tools später mit 'winget upgrade' aktuell halten." -ForegroundColor Cyan