[CmdletBinding()]
param(
    [string]$Version
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Version = node (Join-Path $PSScriptRoot 'version.mjs') resolve $Version
if ($LASTEXITCODE -ne 0) { throw 'Failed to resolve the release package version.' }
$OvgmeName = "Scott-F-16C-50-Control-Profiles-$Version.zip"
$BundleName = "Scott-F-16C-50-Complete-Package-$Version"
$Dist = Join-Path $RepoRoot 'dist'
$OvgmeArchive = Join-Path $Dist $OvgmeName
$BuildRoot = Join-Path $RepoRoot '.build/release'
$BundleRoot = Join-Path $BuildRoot $BundleName
$BundleArchive = Join-Path $Dist "$BundleName.zip"

if (-not (Test-Path $OvgmeArchive -PathType Leaf)) {
    throw "Missing OVGME archive: $OvgmeArchive. Run Build-OvGME.ps1 first."
}

Remove-Item $BuildRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item (Join-Path $BundleRoot 'OVGME') -ItemType Directory -Force | Out-Null
New-Item (Join-Path $BundleRoot 'AutoHotKey') -ItemType Directory -Force | Out-Null
New-Item (Join-Path $BundleRoot 'Documentation') -ItemType Directory -Force | Out-Null

Copy-Item $OvgmeArchive (Join-Path $BundleRoot 'OVGME')
Copy-Item (Join-Path $RepoRoot 'autohotkey/dcs-TQS.ahk') (Join-Path $BundleRoot 'AutoHotKey')
Copy-Item (Join-Path $RepoRoot 'README.md') (Join-Path $BundleRoot 'Documentation/README.md')
Copy-Item (Join-Path $RepoRoot 'CHANGELOG.md') (Join-Path $BundleRoot 'Documentation/CHANGELOG.md')
Copy-Item (Join-Path $RepoRoot 'docs/INSTALLATION.md') (Join-Path $BundleRoot 'Documentation')
Copy-Item (Join-Path $RepoRoot 'docs/CONTROL-MAPPINGS.md') (Join-Path $BundleRoot 'Documentation')
Copy-Item (Join-Path $RepoRoot 'docs/OPENKNEEBOARD-VAICOM.md') (Join-Path $BundleRoot 'Documentation')
Copy-Item (Join-Path $RepoRoot 'docs/THIRD-PARTY-ASSETS.md') (Join-Path $BundleRoot 'Documentation')

$BundleChecksumTargets = @(
    (Join-Path $BundleRoot "OVGME/$OvgmeName"),
    (Join-Path $BundleRoot 'AutoHotKey/dcs-TQS.ahk')
)
$BundleChecksums = foreach ($File in $BundleChecksumTargets) {
    $Hash = Get-FileHash $File -Algorithm SHA256
    $RelativePath = [IO.Path]::GetRelativePath($BundleRoot, $File).Replace('\', '/')
    "$($Hash.Hash.ToLowerInvariant())  $RelativePath"
}
$BundleChecksums | Set-Content (Join-Path $BundleRoot 'SHA256SUMS.txt') -Encoding utf8

Remove-Item $BundleArchive -Force -ErrorAction SilentlyContinue
Compress-Archive -Path $BundleRoot -DestinationPath $BundleArchive -CompressionLevel Optimal

$ReleaseChecksums = Get-ChildItem (Join-Path $Dist '*.zip') | Sort-Object Name | ForEach-Object {
    $Hash = Get-FileHash $_.FullName -Algorithm SHA256
    "$($Hash.Hash.ToLowerInvariant())  $($_.Name)"
}
$ReleaseChecksums | Set-Content (Join-Path $Dist 'SHA256SUMS.txt') -Encoding utf8

Write-Host "Created $BundleArchive"
Write-Host "Created $(Join-Path $Dist 'SHA256SUMS.txt')"
