<#
    list_autostart.ps1
    ------------------------------------------------------
    Prüft alle Autostart-Quellen unter Windows:
    - Benutzer-Registry (HKCU)
    - Systemweite Registry (HKLM)
    - Benutzer-Startup-Ordner
    - Gemeinsamer Startup-Ordner
    ------------------------------------------------------
    Nutzung:
      .\list_autostart.ps1
      .\list_autostart.ps1 -HtmlReport
#>

param(
    [switch]$HtmlReport
)

# --- UTF-8 Fix für PS 5 & PS 7 ---
try {
    chcp 65001 | Out-Null
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Write-Host "`n=== 🔍 AUTOSTART-PROGRAMME (Strukturierte Ausgabe) ===`n" -ForegroundColor Cyan

# --- Registry: HKCU ---
Write-Host "=== [HKCU] Benutzerbezogene Registry-Einträge ===" -ForegroundColor Yellow
$hkcuEntries = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
if ($hkcuEntries) {
    foreach ($key in $hkcuEntries.PSObject.Properties | Where-Object { $_.Name -ne "PSPath" -and $_.Name -ne "PSParentPath" -and $_.Name -ne "PSChildName" -and $_.Name -ne "PSDrive" -and $_.Name -ne "PSProvider" }) {
        Write-Host "→ $($key.Name)" -ForegroundColor Green
        Write-Host "   Pfad: $($key.Value)`n" -ForegroundColor Gray
    }
} else {
    Write-Host "Keine Einträge gefunden.`n" -ForegroundColor DarkGray
}

# --- Registry: HKLM ---
Write-Host "=== [HKLM] Systemweite Registry-Einträge ===" -ForegroundColor Yellow
$hklmEntries = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
if ($hklmEntries) {
    foreach ($key in $hklmEntries.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }) {
        Write-Host "→ $($key.Name)" -ForegroundColor Green
        Write-Host "   Pfad: $($key.Value)`n" -ForegroundColor Gray
    }
} else {
    Write-Host "Keine Einträge gefunden.`n" -ForegroundColor DarkGray
}

# --- Benutzer-Startup ---
Write-Host "=== [User Startup Folder] ===" -ForegroundColor Yellow
$userStartup = [Environment]::GetFolderPath('Startup')
$userFiles = Get-ChildItem $userStartup -ErrorAction SilentlyContinue
if ($userFiles) {
    foreach ($f in $userFiles) {
        Write-Host "→ $($f.Name)" -ForegroundColor Green
        Write-Host "   Pfad: $($f.FullName)" -ForegroundColor Gray
        Write-Host "   Geändert: $($f.LastWriteTime)`n" -ForegroundColor DarkGray
    }
} else {
    Write-Host "Keine Benutzer-Startdateien gefunden.`n" -ForegroundColor DarkGray
}

# --- System-Startup ---
Write-Host "=== [Common Startup Folder] ===" -ForegroundColor Yellow
$commonStartup = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
$commonFiles = Get-ChildItem $commonStartup -ErrorAction SilentlyContinue
if ($commonFiles) {
    foreach ($f in $commonFiles) {
        Write-Host "→ $($f.Name)" -ForegroundColor Green
        Write-Host "   Pfad: $($f.FullName)" -ForegroundColor Gray
        Write-Host "   Geändert: $($f.LastWriteTime)`n" -ForegroundColor DarkGray
    }
} else {
    Write-Host "Keine systemweiten Autostart-Dateien gefunden.`n" -ForegroundColor DarkGray
}

Write-Host "=== ✅ SCAN ABGESCHLOSSEN ===" -ForegroundColor Cyan

# --- Optional: HTML-Export ---
if ($HtmlReport) {
    $logDir = "C:\Tools\windows_devops_tuning\logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
    $htmlPath = "$logDir\autostart_report.html"

    $report = @"
<html lang='de'>
<head>
<meta charset='UTF-8'>
<title>Autostart Report</title>
<style>
body { font-family: Consolas, monospace; background: #1e1e1e; color: #e0e0e0; padding: 20px; }
h2 { color: #00bfff; }
h3 { color: #ffd700; }
.entry { margin-left: 20px; color: #c0ffc0; }
.path { margin-left: 40px; color: #aaa; }
</style>
</head>
<body>
<h2>Autostart Report – $(Get-Date -Format 'dd.MM.yyyy HH:mm')</h2>
"@

    $sections = @{
        "HKCU" = $hkcuEntries.PSObject.Properties
        "HKLM" = $hklmEntries.PSObject.Properties
        "User Startup" = $userFiles
        "Common Startup" = $commonFiles
    }

    foreach ($section in $sections.Keys) {
        $report += "<h3>$section</h3>`n"
        $items = $sections[$section]
        if ($items) {
            foreach ($item in $items) {
                if ($item -is [System.IO.FileInfo]) {
                    $report += "<div class='entry'>→ $($item.Name)</div><div class='path'>Pfad: $($item.FullName)</div>`n"
                } elseif ($item.Value) {
                    $report += "<div class='entry'>→ $($item.Name)</div><div class='path'>Pfad: $($item.Value)</div>`n"
                }
            }
        } else {
            $report += "<div class='entry' style='color:#888;'>Keine Einträge gefunden.</div>`n"
        }
    }

    $report += "</body></html>"
    Set-Content -Path $htmlPath -Value $report -Encoding UTF8
    Write-Host "`n📄 HTML-Report gespeichert unter: $htmlPath" -ForegroundColor Green
}
