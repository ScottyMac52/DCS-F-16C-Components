[CmdletBinding()]
param([Parameter(Mandatory)][string] $Joystick)

$ErrorActionPreference = 'Stop'
$File = 'Ava [R] Viper {F77212B0-00A8-11f1-8001-444553540000}.diff.lua'
$Path = Join-Path $Joystick $File
if (-not (Test-Path $Path -PathType Leaf)) { throw "Missing profile: $File" }
$Lua = Get-Content $Path -Raw
$KeySection = ($Lua -split '\["keyDiffs"\]\s*=\s*\{', 2)[1]
$Buttons = [regex]::Matches($KeySection, '\["key"\]\s*=\s*"(?<Key>JOY_BTN\d+)"') | ForEach-Object { $_.Groups['Key'].Value }
if ($Buttons.Count -ne 14 -or ($Buttons | Sort-Object -Unique).Count -ne 14) { throw 'AVA Warthog grip must contain 14 unique button assignments.' }

$Expected = @{
    'JOY_BTN2'='WPN REL Button - Depress'; 'JOY_BTN3'='NWS A/R DISC MSL STEP Button';
    'JOY_BTN11'='Display Management Switch - Up'; 'JOY_BTN13'='Display Management Switch - Down'; 'JOY_BTN14'='Display Management Switch - Left'; 'JOY_BTN12'='Display Management Switch - Right';
    'JOY_BTN7'='Target Management Switch - Up'; 'JOY_BTN9'='Target Management Switch - Down'; 'JOY_BTN10'='Target Management Switch - Left'; 'JOY_BTN8'='Target Management Switch - Right';
    'JOY_BTN15'='Countermeasures Management Switch - Fwd'; 'JOY_BTN17'='Countermeasures Management Switch - Aft'; 'JOY_BTN18'='Countermeasures Management Switch - Left'; 'JOY_BTN16'='Countermeasures Management Switch - Right'
}
foreach ($Pair in $Expected.GetEnumerator()) {
    if ($Lua -notmatch ('(?ms)\["added"\].*?\["key"\]\s*=\s*"' + $Pair.Key + '".*?\["name"\]\s*=\s*"' + [regex]::Escape($Pair.Value) + '"')) { throw "Missing $($Pair.Key): $($Pair.Value)" }
}
foreach ($Axis in 'Rudder', 'Thrust') {
    if ($Lua -notmatch ('(?ms)\["name"\]\s*=\s*"' + $Axis + '".*?\["removed"\]')) { throw "$Axis must be removed from the AVA grip profile." }
}

Write-Host 'AVA Warthog grip validation passed.'

