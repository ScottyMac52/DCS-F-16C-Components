[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Version = (Get-Content (Join-Path $RepoRoot 'packaging/ovgme/VERSION.TXT') -Raw).Trim()
$PackageName = "Scott-F-16C-Control-Profiles-$Version"
$Archive = Join-Path $RepoRoot "dist/$PackageName.zip"
$VerifyRoot = Join-Path $RepoRoot '.build/verify'

if (-not (Test-Path $Archive -PathType Leaf)) { throw "Missing package: $Archive" }
Remove-Item $VerifyRoot -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive $Archive $VerifyRoot

$Container = Join-Path $VerifyRoot $PackageName
$Joystick = Join-Path $Container 'Config/Input/F-16C_50/joystick'
if (-not (Test-Path $Joystick -PathType Container)) { throw 'Missing F-16C_50 joystick directory.' }
$Profiles = Get-ChildItem $Joystick -Filter '*.diff.lua'
if ($Profiles.Count -lt 2) { throw 'Expected at least the two foundational MFD profiles.' }
if ((Get-Content (Join-Path $VerifyRoot 'VERSION.TXT') -Raw).Trim() -ne $Version) { throw 'VERSION.TXT mismatch.' }

foreach ($Profile in $Profiles) {
    $Lua = Get-Content $Profile.FullName -Raw
    if ($Lua -notmatch '^local diff\s*=\s*\{' -or $Lua -notmatch 'return diff\s*$') {
        throw "$($Profile.Name) does not have the expected DCS diff.lua structure."
    }
}

foreach ($Validator in Get-ChildItem (Join-Path $RepoRoot 'scripts/validate') -Filter '*.ps1' | Sort-Object Name) {
    & $Validator.FullName -Joystick $Joystick
}

Write-Host 'Package validation passed.'

