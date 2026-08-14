[CmdletBinding()]
param(
    [string]$Version
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Version = node (Join-Path $PSScriptRoot 'version.mjs') resolve $Version
if ($LASTEXITCODE -ne 0) { throw 'Failed to resolve the OVGME package version.' }
$PackageName = "Scott-F-16C-50-Control-Profiles-$Version"
$BuildRoot = Join-Path $RepoRoot '.build/ovgme'
$StageRoot = Join-Path $BuildRoot 'stage'
$Container = Join-Path $StageRoot $PackageName
$Dist = Join-Path $RepoRoot 'dist'
$Archive = Join-Path $Dist "$PackageName.zip"

Remove-Item $BuildRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item (Join-Path $Container 'Config/Input/F-16C_50') -ItemType Directory -Force | Out-Null
New-Item (Join-Path $Container 'KNEEBOARD/F-16C_50') -ItemType Directory -Force | Out-Null
New-Item (Join-Path $StageRoot 'LICENSES') -ItemType Directory -Force | Out-Null
New-Item $Dist -ItemType Directory -Force | Out-Null

Copy-Item (Join-Path $RepoRoot 'src/Config/Input/F-16C_50/joystick') (Join-Path $Container 'Config/Input/F-16C_50/joystick') -Recurse
$Modifiers = Join-Path $RepoRoot 'src/Config/Input/F-16C_50/modifiers.lua'
if (Test-Path $Modifiers -PathType Leaf) {
    Copy-Item $Modifiers (Join-Path $Container 'Config/Input/F-16C_50/modifiers.lua')
}
Copy-Item (Join-Path $RepoRoot 'kneeboard/F-16C_50/*') (Join-Path $Container 'KNEEBOARD/F-16C_50')
Copy-Item (Join-Path $RepoRoot 'docs/THIRD-PARTY-ASSETS.md') (Join-Path $StageRoot 'THIRD-PARTY-ASSETS.md')
Copy-Item (Join-Path $RepoRoot 'kneeboard/assets/source/licenses/*') (Join-Path $StageRoot 'LICENSES')
$ReadmeTemplate = Get-Content (Join-Path $RepoRoot 'packaging/ovgme/README.TXT') -Raw
if (-not $ReadmeTemplate.Contains('{{VERSION}}')) {
    throw 'OVGME README.TXT does not contain the {{VERSION}} token.'
}
$ReadmeTemplate.Replace('{{VERSION}}', $Version) |
    Set-Content (Join-Path $StageRoot 'README.TXT') -Encoding utf8
$Version | Set-Content (Join-Path $StageRoot 'VERSION.TXT') -Encoding utf8

Remove-Item $Archive -Force -ErrorAction SilentlyContinue
Compress-Archive -Path $Container, (Join-Path $StageRoot 'README.TXT'), (Join-Path $StageRoot 'VERSION.TXT'), (Join-Path $StageRoot 'THIRD-PARTY-ASSETS.md'), (Join-Path $StageRoot 'LICENSES') -DestinationPath $Archive -CompressionLevel Optimal

Write-Host "Created $Archive"
