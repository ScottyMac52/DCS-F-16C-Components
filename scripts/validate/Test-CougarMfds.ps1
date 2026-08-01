[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Joystick
)

$ErrorActionPreference = 'Stop'
$Expected = @(
    @{ File = 'F16 MFD 1 {51FA60C0-CB32-11ed-800B-444553540000}.diff.lua'; Side = 'Left'; Device = '24' },
    @{ File = 'F16 MFD 2 {51FA39B0-CB32-11ed-8008-444553540000}.diff.lua'; Side = 'Right'; Device = '25' }
)

foreach ($Profile in $Expected) {
    $Path = Join-Path $Joystick $Profile.File
    if (-not (Test-Path $Path -PathType Leaf)) { throw "Missing profile: $($Profile.File)" }
    $Lua = Get-Content $Path -Raw

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

Write-Host 'Cougar MFD validation passed.'
