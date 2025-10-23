<#
  set_pwsh_default.ps1 (final version)
  Macht PowerShell 7 zur Standardshell:
  ✅ Windows Terminal
  ✅ VS Code
  ✅ Explorer-Kontextmenü
#>

Write-Host "`n=== Set PowerShell 7 as Default Shell ===`n" -ForegroundColor Cyan

# 1️⃣ Prüfen
$pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
if (-not (Test-Path $pwshPath)) {
    Write-Host "❌ PowerShell 7 nicht gefunden unter: $pwshPath" -ForegroundColor Red
    exit 1
}
Write-Host "✔ PowerShell 7 gefunden: $pwshPath" -ForegroundColor Green

# 2️⃣ Registry (Explorer)
Write-Host "🔧 Setze PowerShell 7 als Standard-Terminal..." -ForegroundColor Yellow
reg add "HKCU\Console\%%SystemRoot%%_System32_WindowsPowerShell_v1.0_powershell.exe" /v DelegateTerminal /t REG_SZ /d "$pwshPath" /f | Out-Null

# 3️⃣ Windows Terminal (optional)
$terminalSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $terminalSettings) {
    Write-Host "🔧 Aktualisiere Windows Terminal-Profil..." -ForegroundColor Yellow
    try {
        $json = Get-Content $terminalSettings -Raw | ConvertFrom-Json
        $pwshProfile = $json.profiles.list | Where-Object { $_.commandline -like "*pwsh.exe" }

        if ($pwshProfile) {
            $json.defaultProfile = $pwshProfile.guid
            $json | ConvertTo-Json -Depth 10 | Set-Content $terminalSettings -Encoding utf8
            Write-Host "✅ PowerShell 7 als Standard-Terminal gesetzt." -ForegroundColor Green
        } else {
            Write-Host "⚠ Kein pwsh-Profil im Terminal gefunden, keine Änderung vorgenommen." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠ Terminal-Settings konnten nicht bearbeitet werden: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "ℹ Windows Terminal nicht gefunden – übersprungen." -ForegroundColor DarkGray
}

# 4️⃣ VS Code Settings
$codeSettingsDir = "$env:APPDATA\Code\User"
$codeSettingsFile = Join-Path $codeSettingsDir "settings.json"

if (Test-Path $codeSettingsFile) {
    Write-Host "🔧 Setze VS Code Terminal auf PowerShell 7..." -ForegroundColor Yellow
    try {
        $settingsRaw = Get-Content $codeSettingsFile -Raw
        $settings = $settingsRaw | ConvertFrom-Json | ConvertTo-Json -Depth 5 | ConvertFrom-Json -AsHashtable
    } catch {
        $settings = @{}
    }

    $settings["terminal.integrated.defaultProfile.windows"] = "PowerShell"
    $settings["terminal.integrated.profiles.windows"] = @{
        PowerShell = @{
            source = "PowerShell"
            path   = $pwshPath
        }
    }

    $settings | ConvertTo-Json -Depth 5 | Set-Content $codeSettingsFile -Encoding utf8
    Write-Host "✅ VS Code verwendet jetzt PowerShell 7 als Standard-Terminal." -ForegroundColor Green
} else {
    Write-Host "ℹ VS Code Settings nicht gefunden – übersprungen." -ForegroundColor DarkGray
}

Write-Host "`n✅ Umstellung abgeschlossen!" -ForegroundColor Green
Write-Host "🔁 Starte dein Terminal und VS Code neu, um die Änderungen zu übernehmen.`n" -ForegroundColor Cyan
