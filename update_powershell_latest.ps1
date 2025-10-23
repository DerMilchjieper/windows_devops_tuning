<#
  update_powershell_latest.ps1
  Prüft deine aktuelle PowerShell-Version, installiert automatisch die neueste stabile Version (PowerShell 7.x)
  und setzt sie als Standardshell im System, Windows Terminal und (optional) VS Code.
#>

# --- 1 Aktuelle Version prüfen ---
$CurrentVersion = $PSVersionTable.PSVersion.ToString()
Write-Host "Aktuelle PowerShell-Version: $CurrentVersion" -ForegroundColor Cyan

# --- 2 Prüfen, ob winget verfügbar ist ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host " Winget ist nicht installiert. Bitte installiere es zuerst aus dem Microsoft Store (App Installer)." -ForegroundColor Red
    exit 1
}

# --- 3 Verfügbare PowerShell-Version suchen ---
Write-Host "`n Prüfe verfügbare PowerShell-Version über Winget..." -ForegroundColor Yellow
$available = winget search Microsoft.PowerShell | Select-String -Pattern "Microsoft.PowerShell"

if ($available) {
    Write-Host "`nGefundene PowerShell-Pakete:" -ForegroundColor Cyan
    Write-Host $available
} else {
    Write-Host " Keine PowerShell-Pakete über Winget gefunden." -ForegroundColor Red
    exit 1
}

# --- 4 Installationsabfrage ---
Write-Host "`nBereit zur Installation der neuesten PowerShell-Version." -ForegroundColor Green
$confirm = Read-Host "Fortfahren? (J/N)"
if ($confirm -notin @('J','j','Y','y')) {
    Write-Host " Abgebrochen." -ForegroundColor Yellow
    exit
}

# --- 5 PowerShell 7 installieren/aktualisieren ---
Write-Host "`n Installiere oder aktualisiere PowerShell (Microsoft.PowerShell)..." -ForegroundColor Cyan
winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements --silent

# --- 6 Nachkontrolle ---
Start-Sleep -Seconds 3
Write-Host "`n Installation abgeschlossen." -ForegroundColor Green

# --- 7 PowerShell 7 als Standard-Shell im Windows Terminal setzen ---
$terminalSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $terminalSettings) {
    $json = Get-Content $terminalSettings -Raw | ConvertFrom-Json
    $pwshProfile = $json.profiles.list | Where-Object { $_.commandline -like "*pwsh.exe*" }
    if ($pwshProfile) {
        $json.defaultProfile = $pwshProfile.guid
        $json | ConvertTo-Json -Depth 5 | Set-Content $terminalSettings -Encoding UTF8
        Write-Host "  PowerShell 7 als Standard-Shell im Windows Terminal gesetzt." -ForegroundColor Green
    }
}

# --- 8 Kontextmenü/Standard-Terminal anpassen ---
Write-Host "`n Setze PowerShell 7 als Standardshell im System..."
$pwshPath = (Get-Command pwsh).Source
if ($pwshPath) {
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions" -Name "PreferredConsole" -Value $pwshPath -PropertyType String -Force | Out-Null
    Write-Host " PowerShell 7 systemweit als Standard-Terminal registriert." -ForegroundColor Green
}

# --- 9 Optional: VS Code Integration ---
if (Test-Path "$env:APPDATA\Code\User\settings.json") {
    $vscode = Get-Content "$env:APPDATA\Code\User\settings.json" -Raw
    if ($vscode -notmatch "powershell.exe") {
        $vscode = $vscode -replace '"terminal.integrated.defaultProfile.windows":.*?,', ''
        $vscode = $vscode -replace '\}$', ', "terminal.integrated.defaultProfile.windows": "PowerShell"}'
        Set-Content "$env:APPDATA\Code\User\settings.json" -Value $vscode -Encoding UTF8
        Write-Host " PowerShell 7 als Standard-Terminal in VS Code gesetzt." -ForegroundColor Green
    }
}

# --- 10 Abschluss ---
Write-Host "`nAlles erledigt " -ForegroundColor Cyan
Write-Host "Starte dein Terminal neu und prüfe mit:" -ForegroundColor Yellow
Write-Host "  pwsh -v" -ForegroundColor Green
