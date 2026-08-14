param(
  [Parameter(Mandatory = $true)][string]$Version
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$stage = Join-Path $dist "stage-$Version"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
$pkgName = 'DCS-F-16C-50-Components'
$pkg = Join-Path $stage $pkgName
New-Item -ItemType Directory -Force -Path (Join-Path $pkg "Config/Input/F-16C_50/joystick") | Out-Null
Copy-Item (Join-Path $root 'src/Config/Input/F-16C_50/joystick/*') (Join-Path $pkg "Config/Input/F-16C_50/joystick/") -Force
$modSrc = Join-Path $root 'src/Config/Input/F-16C_50/modifiers.lua'
if (Test-Path $modSrc) {
  Copy-Item $modSrc (Join-Path $pkg "Config/Input/F-16C_50/modifiers.lua") -Force
}
$kb = Join-Path $root 'kneeboard/F-16C_50'
if (-not (Test-Path $kb)) { throw "Missing kneeboard PNG folder: $kb — run npm run build:kneeboard first." }
New-Item -ItemType Directory -Force -Path (Join-Path $pkg "KNEEBOARD/F-16C_50") | Out-Null
Copy-Item (Join-Path $kb '*') (Join-Path $pkg "KNEEBOARD/F-16C_50/") -Force
$readme = (Get-Content (Join-Path $root 'packaging/ovgme/README.TXT') -Raw) -replace '\{\{VERSION\}\}', $Version
Set-Content -Path (Join-Path $stage 'README.TXT') -Value $readme -NoNewline
Set-Content -Path (Join-Path $stage 'VERSION.TXT') -Value $Version -NoNewline
$zip = Join-Path $dist "$pkgName-$Version-OVGME.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant()
Set-Content -Path (Join-Path $dist 'SHA256SUMS.txt') -Value "$hash  $(Split-Path $zip -Leaf)"
Write-Host "Wrote $zip"
