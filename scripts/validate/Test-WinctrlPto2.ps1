[CmdletBinding()]
param([Parameter(Mandatory)][string] $Joystick)

$ErrorActionPreference = 'Stop'
$File = 'WINCTRL CarrierAce PTO 2 {19B7D090-6120-11F0-8001-444553540000}.diff.lua'
$Path = Join-Path $Joystick $File
if (-not (Test-Path $Path -PathType Leaf)) { throw "Missing profile: $File" }
$Lua = Get-Content $Path -Raw
$Buttons = [regex]::Matches($Lua, '\["key"\]\s*=\s*"(?<Key>JOY_BTN\d+)"') | ForEach-Object { $_.Groups['Key'].Value }
if ($Buttons.Count -ne 7 -or ($Buttons | Sort-Object -Unique).Count -ne 7) { throw 'PTO2 must contain exactly seven unique assignments.' }

$Expected = @(
    @{ Command='d3006pnilunilcd7vd1vpnilvunil'; Button='JOY_BTN32'; Name='HOOK Switch - UP' },
    @{ Command='d3006pnilunilcd7vd0vpnilvunil'; Button='JOY_BTN34'; Name='HOOK Switch - DN' },
    @{ Command='d3008pnilu3008cd11vd-1vpnilvu0'; Button='JOY_BTN12'; Name='LANDING TAXI LIGHTS 3-pos Switch: TAXI<>OFF' },
    @{ Command='d3008pnilunilcd11vd0vpnilvunil'; Button='JOY_BTN9'; Name='LANDING TAXI LIGHTS Switch - OFF' },
    @{ Command='d3018pnilunilcd11vd1vpnilvunil'; Button='JOY_BTN8'; Name='LANDING TAXI LIGHTS Switch - Up' },
    @{ Command='d430pnilunilcdnilvdnilvpnilvunil'; Button='JOY_BTN35'; Name='LG Handle - UP' },
    @{ Command='d431pnilunilcdnilvdnilvpnilvunil'; Button='JOY_BTN37'; Name='LG Handle - DN' }
)
foreach ($Binding in $Expected) {
    if ($Lua -notmatch ('(?ms)\["' + [regex]::Escape($Binding.Command) + '"\].*?\["key"\]\s*=\s*"' + $Binding.Button + '".*?\["name"\]\s*=\s*"' + [regex]::Escape($Binding.Name) + '"')) { throw "Invalid PTO2 binding: $($Binding.Name)" }
}

Write-Host 'WINCTRL PTO2 validation passed.'
