<# 
  vmware_ready_check.ps1
  Prüft (und optional fixed per -Fix) Windows-Settings, damit VMware Workstation volle Hardware-Virtualisierung (VT-x/VT-d) nutzen kann.

  Nutzung:
    PS> .\vmware_ready_check.ps1
    PS> .\vmware_ready_check.ps1 -Fix   # Admin-Rechte nötig
#>

param([switch]$Fix)

# ---------- Helpers ----------
function Write-Status {
  param([string]$Label, [string]$State, [ConsoleColor]$Color)
  $old = $Host.UI.RawUI.ForegroundColor
  $Host.UI.RawUI.ForegroundColor = $Color
  Write-Host ("{0,-35} {1}" -f $Label, $State)
  $Host.UI.RawUI.ForegroundColor = $old
}

function Test-Admin {
  $id  = [Security.Principal.WindowsIdentity]::GetCurrent()
  $prp = [Security.Principal.WindowsPrincipal]$id
  return $prp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-DeviceGuardStatus {
  try {
    $dg = Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard -ErrorAction Stop
    return [pscustomobject]@{
      SecurityServicesConfigured        = ($dg.SecurityServicesConfigured -join ",")
      SecurityServicesRunning           = ($dg.SecurityServicesRunning    -join ",")
      VirtualizationBasedSecurityStatus = $dg.VirtualizationBasedSecurityStatus
    }
  } catch {
    return [pscustomobject]@{
      SecurityServicesConfigured        = ""
      SecurityServicesRunning           = ""
      VirtualizationBasedSecurityStatus = -1
    }
  }
}

function Get-OptionalFeatureState {
  param([string[]]$Names)
  $out = @{}
  foreach ($n in $Names) {
    $f = Get-WindowsOptionalFeature -Online -FeatureName $n -ErrorAction SilentlyContinue
    if ($f) { $out[$n] = $f.State } else { $out[$n] = "Unknown" }
  }
  return $out
}

function Get-BcdHypervisorLaunchType {
  $out = (bcdedit /enum {current}) 2>$null
  if (-not $out) { return "Unknown" }
  foreach ($line in $out) {
    if ($line -match "hypervisorlaunchtype\s+(\S+)") { return $Matches[1] }
  }
  return "Not set"
}

function Test-HyperVDetectedBySystemInfo {
  $line = systeminfo | findstr /C:"Hyper-V-Anforderungen"
  if (-not $line) { return $false }              # keine Zeile -> i.d.R. kein Hypervisor
  if ($line -match "nicht erkannt") { return $false }
  return $true
}

# ---------- Checks ----------
$dg   = Get-DeviceGuardStatus
$feat = Get-OptionalFeatureState -Names @(
  "Microsoft-Hyper-V-All",
  "VirtualMachinePlatform",
  "Microsoft-Windows-Subsystem-Linux",
  "Containers",
  "HypervisorPlatform",
  "Microsoft-Hyper-V-Hypervisor",
  "Microsoft-Hyper-V-Services"
)
$bcd  = Get-BcdHypervisorLaunchType
$hvDetected = Test-HyperVDetectedBySystemInfo

# ---------- Report ----------
Write-Host ""
Write-Host "=== VMware Ready Check ===" -ForegroundColor Cyan
Write-Host ""

# VBS/DeviceGuard
$dgState = "Unbekannt"
if ($dg.VirtualizationBasedSecurityStatus -eq 0) { $dgState = "Aus (OK)" }
elseif ($dg.VirtualizationBasedSecurityStatus -eq 1) { $dgState = "Aktiv" }
elseif ($dg.VirtualizationBasedSecurityStatus -eq 2) { $dgState = "Aktiv (pending off)" }

$dgColor = 'Yellow'
if ($dg.VirtualizationBasedSecurityStatus -eq 0) { $dgColor = 'Green' }
Write-Status "VBS/DeviceGuard" $dgState $dgColor

# Optional Features
foreach ($k in $feat.Keys) {
  $state = $feat[$k]
  $ok = @("Disabled","Unknown") -contains $state
  $color = 'Yellow'
  if ($ok) { $color = 'Green' }
  Write-Status ("Feature: {0}" -f $k) $state $color
}

# BCDEdit
$bcdColor = 'Yellow'
if ($bcd -match 'off') { $bcdColor = 'Green' }
Write-Status "bcd: hypervisorlaunchtype" $bcd $bcdColor

# systeminfo Detection
$hvColor = 'Green'
$hvText  = "NEIN"
if ($hvDetected) { $hvColor = 'Yellow'; $hvText = "JA" }
Write-Status "systeminfo: Hypervisor erkannt" $hvText $hvColor

# Overall
$okVBS  = ($dg.VirtualizationBasedSecurityStatus -eq 0)
$okFeat = @(
  "Microsoft-Hyper-V-All",
  "VirtualMachinePlatform",
  "Microsoft-Windows-Subsystem-Linux",
  "Containers",
  "HypervisorPlatform",
  "Microsoft-Hyper-V-Hypervisor",
  "Microsoft-Hyper-V-Services"
).ForEach({ $feat[$_] -in @("Disabled","Unknown") }) -notcontains $false
$okBCD = ($bcd -match 'off')
$okSI  = (-not $hvDetected)

$allOK = $okVBS -and $okFeat -and $okBCD -and $okSI

Write-Host ""
if ($allOK) {
  Write-Host " VMware ready  kein Hypervisor aktiv, volle Hardware-Virtualisierung verfügbar." -ForegroundColor Green
} else {
  Write-Host " Nicht optimal  du kannst '-Fix' nutzen, um empfohlene Einstellungen zu setzen." -ForegroundColor Yellow
}

# ---------- Fix ----------
if ($Fix) {
  if (-not (Test-Admin)) {
    Write-Host "`n -Fix benötigt Administratorrechte. PowerShell als Administrator neu starten." -ForegroundColor Red
    exit 1
  }

  Write-Host "`n=== Applying Fixes ===" -ForegroundColor Cyan

  # VBS / Credential Guard aus
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v RequirePlatformSecurityFeatures /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard" /v Enabled /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LsaCfgFlags /t REG_DWORD /d 0 /f | Out-Null

  # Optional Features aus
  $toDisable = @(
    "Microsoft-Hyper-V-All",
    "VirtualMachinePlatform",
    "Microsoft-Windows-Subsystem-Linux",
    "Containers",
    "HypervisorPlatform"
  )
  foreach ($fName in $toDisable) {
    try { dism.exe /Online /Disable-Feature:"$fName" /NoRestart | Out-Null } catch {}
  }

  # Hypervisor beim Boot sicher aus
  bcdedit /set hypervisorlaunchtype off | Out-Null

  Write-Host "`nFix angewendet. Bitte jetzt neu starten, damit alle Änderungen wirksam werden:" -ForegroundColor Yellow
  Write-Host "  shutdown /r /t 0" -ForegroundColor Yellow
}
