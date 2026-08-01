[CmdletBinding()]
param([Parameter(Mandatory)][string] $Joystick)

$ErrorActionPreference = 'Stop'
$File = 'WINCTRL ViperAce ICP {3731E2E0-4D98-11F1-8001-444553540000}.diff.lua'
$Path = Join-Path $Joystick $File
if (-not (Test-Path $Path -PathType Leaf)) { throw "Missing profile: $File" }
$Lua = Get-Content $Path -Raw
$KeySection = ($Lua -split '\["keyDiffs"\]\s*=\s*\{', 2)[1]
$Buttons = [regex]::Matches($KeySection, '\["key"\]\s*=\s*"(?<Key>JOY_BTN\d+)"') | ForEach-Object { $_.Groups['Key'].Value }
if ($Buttons.Count -ne 33 -or ($Buttons | Sort-Object -Unique).Count -ne 33) { throw 'ViperAce ICP must contain 33 unique button assignments.' }

$RequiredNames = @(
    'ICP Priority Function Button - 0(M-SEL)', 'ICP Priority Function Button - 1(T-ILS)', 'ICP Priority Function Button - 2/N(ALOW)', 'ICP Priority Function Button - 3',
    'ICP Priority Function Button - 4/W(STPT)', 'ICP Priority Function Button - 5(CRUS)', 'ICP Priority Function Button - 6/E(TIME)', 'ICP Priority Function Button - 7(MARK)',
    'ICP Priority Function Button - 8/S(FIX)', 'ICP Priority Function Button - 9(A-CAL)', 'ICP COM Override Button - COM1(UHF)', 'ICP COM Override Button - COM2(VHF)',
    'ICP IFF Override Button - IFF', 'ICP LIST Override Button - LIST', 'ICP Enter Button - ENTR', 'ICP Recall Button - RCL', 'ICP Master Mode Button - A-A', 'ICP Master Mode Button - A-G',
    'ICP DED Increment/Decrement Switch - Increment', 'ICP DED Increment/Decrement Switch - Decrement', 'ICP Data Control Switch - RET', 'ICP Data Control Switch - SEQ',
    'ICP Data Control Switch - UP', 'ICP Data Control Switch - DOWN', 'ICP FLIR Polarity Button', 'ICP FLIR Increment/Decrement Switch - Increment',
    'ICP FLIR Increment/Decrement Switch - Decrement', 'ICP FLIR GAIN/LEVEL Switch - GAIN', 'ICP FLIR GAIN/LEVEL Switch - LVL', 'ICP FLIR GAIN/LEVEL Switch - AUTO',
    'ICP DRIFT CUTOUT/WARN RESET Switch - DRIFT C/O', 'ICP DRIFT CUTOUT/WARN RESET Switch - NORM', 'ICP DRIFT CUTOUT/WARN RESET 3-pos Switch: WARN RESET <>NORM'
)
foreach ($Name in $RequiredNames) {
    if ($Lua -notmatch ('\["name"\]\s*=\s*"' + [regex]::Escape($Name) + '"')) { throw "Missing ICP control: $Name" }
}

$Axes = @{
    'JOY_Y'='HUD Symbology Intensity Knob'; 'JOY_X'='Reticle Depression Control Knob'; 'JOY_RY'='Raster Intensity Knob'; 'JOY_RX'='Raster Contrast Knob'
}
foreach ($Pair in $Axes.GetEnumerator()) {
    if ($Lua -notmatch ('(?ms)\["added"\].*?\["key"\]\s*=\s*"' + $Pair.Key + '".*?\["name"\]\s*=\s*"' + [regex]::Escape($Pair.Value) + '"')) { throw "Missing ICP axis: $($Pair.Value)" }
}
foreach ($Axis in 'Pitch', 'Roll') {
    if ($Lua -notmatch ('(?ms)\["name"\]\s*=\s*"' + $Axis + '".*?\["removed"\]')) { throw "$Axis must be removed from the ICP profile." }
}

Write-Host 'WINCTRL ViperAce ICP validation passed.'
