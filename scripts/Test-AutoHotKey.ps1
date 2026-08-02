[CmdletBinding()]
param(
    [string] $Path
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = Join-Path $RepoRoot 'autohotkey/dcs-TQS.ahk'
}
if (-not (Test-Path $Path -PathType Leaf)) { throw "Missing AutoHotKey bridge: $Path" }

$Ahk = Get-Content $Path -Raw
if ($Ahk -notmatch '(?m)^#Requires AutoHotkey v2\.0\s*$') { throw 'The bridge must require AutoHotKey v2.0.' }
if ($Ahk -notmatch '(?m)^#SingleInstance Force\s*$') { throw 'The bridge must enforce a single instance.' }

$Mappings = @(
    @{ Input = '5Joy1'; Key = 'vk31'; Tx = 'TX1' },
    @{ Input = '5Joy2'; Key = 'vk32'; Tx = 'TX2' },
    @{ Input = '5Joy3'; Key = 'vk33'; Tx = 'TX3' },
    @{ Input = '5Joy4'; Key = 'vk34'; Tx = 'TX4' },
    @{ Input = '5Joy5'; Key = 'vk35'; Tx = 'TX5' }
)
foreach ($Mapping in $Mappings) {
    $BlockPattern = '(?ms)^' + [regex]::Escape($Mapping.Input) + '::\s*\{(?<Block>.*?)^\}'
    $Match = [regex]::Match($Ahk, $BlockPattern)
    if (-not $Match.Success) { throw "Missing $($Mapping.Tx) handler for $($Mapping.Input)." }
    $Block = $Match.Groups['Block'].Value
    if ($Block -notmatch ('\{LCtrl down\}\{LAlt down\}\{LShift down\}\{' + $Mapping.Key + ' down\}')) {
        throw "$($Mapping.Tx) does not press the expected VoiceAttack chord."
    }
    if ($Block -notmatch ('KeyWait "' + [regex]::Escape($Mapping.Input) + '"')) {
        throw "$($Mapping.Tx) does not wait for the physical input to be released."
    }
    if ($Block -notmatch ('\{' + $Mapping.Key + ' up\}\{LShift up\}\{LAlt up\}\{LCtrl up\}')) {
        throw "$($Mapping.Tx) does not release the expected VoiceAttack chord."
    }
}

$DeclaredInputs = [regex]::Matches($Ahk, '(?m)^(?<Input>\d+Joy\d+)::\s*$') |
    ForEach-Object { $_.Groups['Input'].Value }
if ($DeclaredInputs.Count -ne 5 -or ($DeclaredInputs | Sort-Object -Unique).Count -ne 5) {
    throw 'The bridge must declare exactly five unique joystick handlers.'
}
if ($Ahk -notmatch '(?m)^OnExit\(ReleaseAll\)\s*$' -or $Ahk -notmatch '(?m)^ReleaseAll\(\*\)\s*$') {
    throw 'The bridge must release all synthetic keys when it exits.'
}

Write-Host 'AutoHotKey bridge validation passed.'
