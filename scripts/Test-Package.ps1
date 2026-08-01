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
if ((Get-ChildItem $Joystick -Filter '*.diff.lua').Count -ne 2) { throw 'Expected exactly two control profiles.' }
if ((Get-Content (Join-Path $VerifyRoot 'VERSION.TXT') -Raw).Trim() -ne $Version) { throw 'VERSION.TXT mismatch.' }

$Expected = @(
    @{ File = 'F16 MFD 1 {51FA60C0-CB32-11ed-800B-444553540000}.diff.lua'; Side = 'Left'; Device = '24' },
    @{ File = 'F16 MFD 2 {51FA39B0-CB32-11ed-8008-444553540000}.diff.lua'; Side = 'Right'; Device = '25' }
)

foreach ($Profile in $Expected) {
    $Path = Join-Path $Joystick $Profile.File
    if (-not (Test-Path $Path -PathType Leaf)) { throw "Missing profile: $($Profile.File)" }
    $Lua = Get-Content $Path -Raw

    if ($Lua -notmatch '^local diff\s*=\s*\{' -or $Lua -notmatch 'return diff\s*$') {
        throw "$($Profile.File) does not have the expected DCS diff.lua structure."
    }

    $AddedButtons = [regex]::Matches($Lua, '(?ms)\["added"\]\s*=\s*\{.*?\["key"\]\s*=\s*"(?<Key>JOY_BTN\d+)"') |
        ForEach-Object { $_.Groups['Key'].Value }
    if ($AddedButtons.Count -ne 28 -or ($AddedButtons | Sort-Object -Unique).Count -ne 28) {
        throw "$($Profile.File) must contain 28 unique button assignments."
    }

    foreach ($Osb in 1..20) {
        $CommandNumber = '{0:d4}' -f (3000 + $Osb)
        $Command = "d${CommandNumber}pnilu${CommandNumber}cd$($Profile.Device)vd1vpnilvu0"
        $Pattern = '(?ms)\["' + [regex]::Escape($Command) + '"\].*?\["key"\]\s*=\s*"JOY_BTN' + $Osb + '".*?\["name"\]\s*=\s*"' + $Profile.Side + ' MFD OSB ' + $Osb + '"'
        if ($Lua -notmatch $Pattern) { throw "$($Profile.File) has an invalid OSB $Osb mapping." }
    }

    foreach ($Axis in 'Pitch', 'Roll', 'Rudder', 'Thrust') {
        if ($Lua -notmatch '(?ms)\["name"\]\s*=\s*"' + $Axis + '".*?\["removed"\]') {
            throw "$($Profile.File) does not explicitly remove the $Axis axis."
        }
    }
}

if (Get-ChildItem $Joystick -Filter 'F16 MFD 3*.diff.lua') { throw 'MFD 3 must remain unmodified.' }

Write-Host 'Package validation passed.'

