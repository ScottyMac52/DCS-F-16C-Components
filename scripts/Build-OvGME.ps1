param(
  [Parameter(Mandatory = $true)][string]$Version
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$commonRoot = if ($env:DCS_COMMON_ROOT) { $env:DCS_COMMON_ROOT } else { Join-Path $root '.dcs-common' }
$uiLayerSource = Join-Path $commonRoot 'assets/shared/ui-layer/input/UiLayer'
$uiLayerPackager = Join-Path $commonRoot 'scripts/package-ui-layer-input.mjs'
if (-not (Test-Path $uiLayerSource)) { throw "Missing shared UI Layer input payload: $uiLayerSource" }
if (-not (Test-Path $uiLayerPackager)) { throw "Missing shared UI Layer packager: $uiLayerPackager" }
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$stage = Join-Path $dist "stage-$Version"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
$pkgName = 'DCS-F-16C-50-Components'
$archiveBase = "$pkgName-$Version-OVGME"
$pkg = Join-Path $stage $archiveBase
$consumerJoystick = Join-Path $root 'src/Config/Input/F-16C_50/joystick'
New-Item -ItemType Directory -Force -Path (Join-Path $pkg "Config/Input/F-16C_50/joystick") | Out-Null
Copy-Item (Join-Path $consumerJoystick '*') (Join-Path $pkg "Config/Input/F-16C_50/joystick/") -Force
$modSrc = Join-Path $root 'src/Config/Input/F-16C_50/modifiers.lua'
if (Test-Path $modSrc) {
  Copy-Item $modSrc (Join-Path $pkg "Config/Input/F-16C_50/modifiers.lua") -Force
}
New-Item -ItemType Directory -Force -Path (Join-Path $pkg 'Config/Input') | Out-Null
$uiLayerDestination = Join-Path $pkg 'Config/Input/UiLayer'
& node $uiLayerPackager $commonRoot $consumerJoystick $uiLayerDestination
if ($LASTEXITCODE -ne 0) { throw "UI Layer packaging failed with exit code $LASTEXITCODE" }
$kb = Join-Path $root 'kneeboard/F-16C_50'
if (-not (Test-Path $kb)) { throw "Missing kneeboard PNG folder: $kb — run npm run build:kneeboard first." }
New-Item -ItemType Directory -Force -Path (Join-Path $pkg "KNEEBOARD/F-16C_50") | Out-Null
Copy-Item (Join-Path $kb '*') (Join-Path $pkg "KNEEBOARD/F-16C_50/") -Force
$readme = (Get-Content (Join-Path $root 'packaging/ovgme/README.TXT') -Raw) -replace '\{\{VERSION\}\}', $Version
Set-Content -Path (Join-Path $stage 'README.TXT') -Value $readme -NoNewline
Set-Content -Path (Join-Path $stage 'VERSION.TXT') -Value $Version -NoNewline
$zip = Join-Path $dist "$archiveBase.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant()
Set-Content -Path (Join-Path $dist 'SHA256SUMS.txt') -Value "$hash  $(Split-Path $zip -Leaf)"
Write-Host "Wrote $zip"
