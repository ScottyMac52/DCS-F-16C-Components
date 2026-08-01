[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Version = (Get-Content (Join-Path $RepoRoot 'packaging/ovgme/VERSION.TXT') -Raw).Trim()
$PackageName = "Scott-F-16C-Control-Profiles-$Version"
$BuildRoot = Join-Path $RepoRoot '.build/ovgme'
$StageRoot = Join-Path $BuildRoot 'stage'
$Container = Join-Path $StageRoot $PackageName
$Dist = Join-Path $RepoRoot 'dist'
$Archive = Join-Path $Dist "$PackageName.zip"

Remove-Item $BuildRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item (Join-Path $Container 'Config/Input/F-16C_50') -ItemType Directory -Force | Out-Null
New-Item $Dist -ItemType Directory -Force | Out-Null

Copy-Item (Join-Path $RepoRoot 'src/Config/Input/F-16C_50/joystick') (Join-Path $Container 'Config/Input/F-16C_50/joystick') -Recurse
Copy-Item (Join-Path $RepoRoot 'packaging/ovgme/README.TXT') (Join-Path $StageRoot 'README.TXT')
Copy-Item (Join-Path $RepoRoot 'packaging/ovgme/VERSION.TXT') (Join-Path $StageRoot 'VERSION.TXT')

Remove-Item $Archive -Force -ErrorAction SilentlyContinue
Compress-Archive -Path $Container, (Join-Path $StageRoot 'README.TXT'), (Join-Path $StageRoot 'VERSION.TXT') -DestinationPath $Archive -CompressionLevel Optimal

$Hash = Get-FileHash $Archive -Algorithm SHA256
"$($Hash.Hash.ToLowerInvariant())  $([IO.Path]::GetFileName($Archive))" | Set-Content (Join-Path $Dist 'SHA256SUMS.txt') -Encoding utf8

Write-Host "Created $Archive"

