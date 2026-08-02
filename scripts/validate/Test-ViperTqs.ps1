[CmdletBinding()]
param([Parameter(Mandatory)][string] $Joystick)

$ErrorActionPreference = 'Stop'
$File = 'Viper TQS {C0A33440-3F54-11f1-8001-444553540000}.diff.lua'
$Path = Join-Path $Joystick $File
if (-not (Test-Path $Path -PathType Leaf)) { throw "Missing profile: $File" }
$Lua = Get-Content $Path -Raw
$KeySection = ($Lua -split '\["keyDiffs"\]\s*=\s*\{', 2)[1]
$AddedButtons = [regex]::Matches(
    $KeySection,
    '(?ms)\["added"\]\s*=\s*\{\s*\[1\]\s*=\s*\{\s*\["key"\]\s*=\s*"(?<Key>JOY_BTN\d+)"'
) | ForEach-Object { $_.Groups['Key'].Value }
if ($AddedButtons.Count -ne 53 -or ($AddedButtons | Sort-Object -Unique).Count -ne 53) {
    throw 'Viper TQS must contain 53 unique native DCS button assignments.'
}

$ReservedButtons = 1..5 | ForEach-Object { "JOY_BTN$_" }
$NativeReservedButtons = @($AddedButtons | Where-Object { $_ -in $ReservedButtons })
if ($NativeReservedButtons.Count -ne 0) {
    throw "Viper TQS buttons 1-5 are reserved for AutoHotKey/VAICOM, but native DCS assignments remain: $($NativeReservedButtons -join ', ')."
}

$RemovedButtons = [regex]::Matches(
    $KeySection,
    '(?ms)\["removed"\]\s*=\s*\{\s*\[1\]\s*=\s*\{\s*\["key"\]\s*=\s*"(?<Key>JOY_BTN\d+)"'
) | ForEach-Object { $_.Groups['Key'].Value }
foreach ($Button in 'JOY_BTN1', 'JOY_BTN2', 'JOY_BTN3', 'JOY_BTN4') {
    if ($Button -notin $RemovedButtons) { throw "$Button must explicitly remove its former native DCS transmit binding." }
}

$Bindings = @(
    @{ Command='d3002pnilu3002cd19vd1vpnilvu0'; Button='JOY_BTN23'; Name='MASTER ARM 3-pos Switch: MASTER ARM<>OFF' },
    @{ Command='d3002pnilu3002cd19vd-1vpnilvu0'; Button='JOY_BTN24'; Name='MASTER ARM 3-pos Switch: SIMULATE<>OFF' },
    @{ Command='d3003pnilu3003cd19vd1vpnilvu0'; Button='JOY_BTN22'; Name='EMER STORES JETTISON Button' },
    @{ Command='d3004pnilunilcd22vd1vpnilvunil'; Button='JOY_BTN48'; Name='LASER ARM Switch - ARM' },
    @{ Command='d3004pnilunilcd22vd0vpnilvunil'; Button='JOY_BTN61'; Name='LASER ARM Switch - OFF' },
    @{ Command='d3030pnilu3030cd16vd1vpnilvu0'; Button='JOY_BTN7'; Name='DOGFIGHT/Missile Override 3-pos Switch: DOGFIGHT<>CENTER' },
    @{ Command='d3030pnilu3030cd16vd-1vpnilvu0'; Button='JOY_BTN8'; Name='DOGFIGHT/Missile Override 3-pos Switch: MISSILE OVERRIDE<>CENTER' },
    @{ Command='d3031pnilu3031cd16vd-1vpnilvu0'; Button='JOY_BTN9'; Name='SPD BRK Switch - Aft/EXTEND (Momentary)' },
    @{ Command='d3031pnilunilcd16vd1vpnilvunil'; Button='JOY_BTN10'; Name='SPD BRK Switch - Fwd/RETRACT' },
    @{ Command='d313pnilu311cdnilvd1vpnilvu1'; Button='JOY_BTN18'; Name='Throttle - OFF(hold)<>IDLE' }
)
foreach ($Binding in $Bindings) {
    $Pattern = '(?ms)\["' + [regex]::Escape($Binding.Command) + '"\]\s*=\s*\{(?<Block>.*?)(?=^\t\t\["|^\t\},)'
    $Match = [regex]::Match($Lua, $Pattern)
    if (-not $Match.Success -or $Match.Groups['Block'].Value -notmatch ('\["key"\]\s*=\s*"' + $Binding.Button + '"') -or $Match.Groups['Block'].Value -notmatch ('\["name"\]\s*=\s*"' + [regex]::Escape($Binding.Name) + '"')) {
        throw "Invalid Viper TQS binding: $($Binding.Name)"
    }
}

$Axes = @(
    @{ Command='a2012cdnil'; Key='JOY_RZ'; Name='Zoom View' },
    @{ Command='a3028cd16'; Key='JOY_RX'; Name='MAN RNG Knob' },
    @{ Command='a3032cd16'; Key='JOY_RY'; Name='ANT ELEV Knob' },
    @{ Command='a3046cd16'; Key='JOY_Y'; Name='RDR CURSOR Switch - Y axis' },
    @{ Command='a3047cd16'; Key='JOY_X'; Name='RDR CURSOR Switch - X axis' }
)
foreach ($Axis in $Axes) {
    if ($Lua -notmatch ('(?ms)\["' + $Axis.Command + '"\].*?\["added"\].*?\["key"\]\s*=\s*"' + $Axis.Key + '".*?\["name"\]\s*=\s*"' + [regex]::Escape($Axis.Name) + '"')) { throw "Invalid Viper TQS axis: $($Axis.Name)" }
}
if ($Lua -notmatch '(?ms)\["a3046cd16"\].*?\["curvature"\].*?0.12.*?\["deadzone"\]\s*=\s*0.02.*?\["invert"\]\s*=\s*true') { throw 'RDR CURSOR Y tuning changed.' }
if ($Lua -notmatch '(?ms)\["a3047cd16"\].*?\["curvature"\].*?0.12.*?\["deadzone"\]\s*=\s*0.02.*?\["invert"\]\s*=\s*false') { throw 'RDR CURSOR X tuning changed.' }

Write-Host 'Viper TQS validation passed.'
