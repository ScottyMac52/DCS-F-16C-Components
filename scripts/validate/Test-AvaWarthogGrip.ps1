[CmdletBinding()]
param([Parameter(Mandatory)][string] $Joystick)

$ErrorActionPreference = 'Stop'
$File = 'Ava [R] Viper {F77212B0-00A8-11f1-8001-444553540000}.diff.lua'
$Path = Join-Path $Joystick $File
if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing profile: $File" }
$Lua = Get-Content -LiteralPath $Path -Raw
$KeySection = ($Lua -split '\["keyDiffs"\]\s*=\s*\{', 2)[1]
$Buttons = [regex]::Matches($KeySection, '\["key"\]\s*=\s*"(?<Key>JOY_BTN\d+)"') | ForEach-Object { $_.Groups['Key'].Value }
if ($Buttons.Count -ne 15 -or ($Buttons | Sort-Object -Unique).Count -ne 15) { throw 'AVA Warthog grip must contain 15 unique button assignments.' }

$Expected = @{
    'JOY_BTN2'='WPN REL Button - Depress'; 'JOY_BTN3'='NWS A/R DISC MSL STEP Button';
    'JOY_BTN11'='Display Management Switch - Up'; 'JOY_BTN13'='Display Management Switch - Down'; 'JOY_BTN14'='Display Management Switch - Left'; 'JOY_BTN12'='Display Management Switch - Right';
    'JOY_BTN7'='Target Management Switch - Up'; 'JOY_BTN9'='Target Management Switch - Down'; 'JOY_BTN10'='Target Management Switch - Left'; 'JOY_BTN8'='Target Management Switch - Right';
    'JOY_BTN15'='Countermeasures Management Switch - Fwd'; 'JOY_BTN17'='Countermeasures Management Switch - Aft'; 'JOY_BTN18'='Countermeasures Management Switch - Left'; 'JOY_BTN16'='Countermeasures Management Switch - Right';
    'JOY_BTN19'='Countermeasures Management Switch - Depress';
    'JOY_POV1_U'='TRIM Switch - UP'; 'JOY_POV1_D'='TRIM Switch - DOWN'; 'JOY_POV1_L'='TRIM Switch - LEFT'; 'JOY_POV1_R'='TRIM Switch - RIGHT'
}
foreach ($Pair in $Expected.GetEnumerator()) {
    if ($Lua -notmatch ('(?ms)\["added"\].*?\["key"\]\s*=\s*"' + $Pair.Key + '".*?\["name"\]\s*=\s*"' + [regex]::Escape($Pair.Value) + '"')) { throw "Missing $($Pair.Key): $($Pair.Value)" }
}
$ExpectedAxes = @{ 'JOY_X'='Roll'; 'JOY_Y'='Pitch' }
foreach ($Pair in $ExpectedAxes.GetEnumerator()) {
    if ($Lua -notmatch ('(?ms)\["added"\].*?\["key"\]\s*=\s*"' + $Pair.Key + '".*?\["name"\]\s*=\s*"' + $Pair.Value + '"')) { throw "Missing $($Pair.Key) axis: $($Pair.Value)" }
}

foreach ($Axis in 'Rudder', 'Thrust') {
    if ($Lua -notmatch ('(?ms)\["name"\]\s*=\s*"' + $Axis + '".*?\["removed"\]')) { throw "$Axis must be removed from the AVA grip profile." }
}

Write-Host 'AVA Warthog grip validation passed.'

