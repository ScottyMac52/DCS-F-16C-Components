[CmdletBinding()]
param(
    [string]$Version
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Version = node (Join-Path $PSScriptRoot 'version.mjs') resolve $Version
if ($LASTEXITCODE -ne 0) { throw 'Failed to resolve the package-test version.' }
$PackageName = "Scott-F-16C-50-Control-Profiles-$Version"
$Archive = Join-Path $RepoRoot "dist/$PackageName.zip"
$VerifyRoot = Join-Path $RepoRoot '.build/verify'

if (-not (Test-Path $Archive)) { throw "Missing package: $Archive" }
Remove-Item $VerifyRoot -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive $Archive $VerifyRoot

$Container = Join-Path $VerifyRoot $PackageName
$Joystick = Join-Path $Container 'Config/Input/F-16C_50/joystick'
$Kneeboard = Join-Path $Container 'KNEEBOARD/F-16C_50'

if (-not (Test-Path $Joystick)) { throw 'Missing F-16C_50 joystick directory.' }
if (-not (Test-Path $Kneeboard)) { throw 'Missing F-16C_50 kneeboard directory.' }
if ((Get-ChildItem $Joystick -Filter '*.diff.lua').Count -ne 9) { throw 'Expected 9 control profiles.' }

$ExpectedKneeboardPages = @(
    '01-CONTROL-OVERVIEW.png',
    '02-LEFT-MFD.png',
    '03-RIGHT-MFD.png',
    '04-VIPER-TQS.png',
    '05-AVA-WARTHOG-GRIP.png',
    '06-WINCTRL-PTO2.png',
    '07-WINCTRL-VIPERACE-ICP.png',
    '08-OPENKNEEBOARD-VAICOM.png'
)
$ActualKneeboardPages = @(Get-ChildItem $Kneeboard -Filter '*.png' | Sort-Object Name | ForEach-Object Name)
if (Compare-Object $ExpectedKneeboardPages $ActualKneeboardPages) {
    throw 'Kneeboard package must contain the exact eight expected PNG filenames.'
}

if (-not (Test-Path (Join-Path $VerifyRoot 'THIRD-PARTY-ASSETS.md') -PathType Leaf)) {
    throw 'Missing kneeboard third-party asset notice.'
}
foreach ($License in 'joystick-diagrams-GPL-2.0.txt', 'bindulator-templates-GPL-2.0-or-later.txt') {
    if (-not (Test-Path (Join-Path $VerifyRoot "LICENSES/$License") -PathType Leaf)) {
        throw "Missing redistributed asset license: $License"
    }
}
if ((Get-Content (Join-Path $VerifyRoot 'VERSION.TXT') -Raw).Trim() -ne $Version) {
    throw 'VERSION.TXT mismatch.'
}
$PackageReadme = Get-Content (Join-Path $VerifyRoot 'README.TXT') -Raw
if ($PackageReadme.Contains('{{VERSION}}')) {
    throw 'README.TXT contains an unresolved version token.'
}
if ($PackageReadme -notmatch ('OVGME PACKAGE VERSION ' + [regex]::Escape($Version))) {
    throw 'README.TXT does not contain the package version.'
}

Write-Host 'Package validation passed.'
