[CmdletBinding()]
param(
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Version = node (Join-Path $PSScriptRoot 'version.mjs') resolve $Version
if ($LASTEXITCODE -ne 0) { throw 'Failed to resolve the package-test version.' }
$PackageName = "Scott-F-16C-Control-Profiles-$Version"
$Archive = Join-Path $RepoRoot "dist/$PackageName.zip"
$VerifyRoot = Join-Path $RepoRoot '.build/verify'

if (-not (Test-Path $Archive -PathType Leaf)) { throw "Missing package: $Archive" }
Remove-Item $VerifyRoot -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive $Archive $VerifyRoot

$Container = Join-Path $VerifyRoot $PackageName
$Joystick = Join-Path $Container 'Config/Input/F-16C_50/joystick'
$Kneeboard = Join-Path $Container 'KNEEBOARD/F-16C_50'
if (-not (Test-Path $Joystick -PathType Container)) { throw 'Missing F-16C_50 joystick directory.' }
if (-not (Test-Path $Kneeboard -PathType Container)) { throw 'Missing F-16C_50 kneeboard directory.' }
$Profiles = Get-ChildItem $Joystick -Filter '*.diff.lua'
if ($Profiles.Count -lt 2) { throw 'Expected at least the two foundational MFD profiles.' }
if ((Get-Content (Join-Path $VerifyRoot 'VERSION.TXT') -Raw).Trim() -ne $Version) { throw 'VERSION.TXT mismatch.' }
$PackageReadme = Get-Content (Join-Path $VerifyRoot 'README.TXT') -Raw
if ($PackageReadme.Contains('{{VERSION}}')) { throw 'README.TXT contains an unresolved version token.' }
if ($PackageReadme -notmatch ('OVGME PACKAGE VERSION ' + [regex]::Escape($Version))) { throw 'README.TXT does not contain the package version.' }

$ExpectedKneeboardPages = 4
$ConditionalPages = @(
    @{ Profile = 'Viper TQS*.diff.lua'; Page = '04-VIPER-TQS.png' },
    @{ Profile = 'Ava *Viper*.diff.lua'; Page = '05-AVA-WARTHOG-GRIP.png' },
    @{ Profile = 'WINCTRL CarrierAce PTO 2*.diff.lua'; Page = '06-WINCTRL-PTO2.png' },
    @{ Profile = 'WINCTRL ViperAce ICP*.diff.lua'; Page = '07-WINCTRL-VIPERACE-ICP.png' }
)
foreach ($Conditional in $ConditionalPages) {
    if (Get-ChildItem $Joystick -Filter $Conditional.Profile) {
        $ExpectedKneeboardPages += 1
        if (-not (Test-Path (Join-Path $Kneeboard $Conditional.Page) -PathType Leaf)) {
            throw "Missing conditional kneeboard page: $($Conditional.Page)"
        }
    }
}
$Pages = Get-ChildItem $Kneeboard -Filter '*.png'
if ($Pages.Count -ne $ExpectedKneeboardPages) { throw "Expected $ExpectedKneeboardPages kneeboard pages, found $($Pages.Count)." }
foreach ($Page in '01-CONTROL-OVERVIEW.png', '02-LEFT-MFD.png', '03-RIGHT-MFD.png', '08-OPENKNEEBOARD-VAICOM.png') {
    if (-not (Test-Path (Join-Path $Kneeboard $Page) -PathType Leaf)) { throw "Missing foundational kneeboard page: $Page" }
}

foreach ($Profile in $Profiles) {
    $Lua = Get-Content -LiteralPath $Profile.FullName -Raw
    if ($Lua -notmatch '^local diff\s*=\s*\{' -or $Lua -notmatch 'return diff\s*$') {
        throw "$($Profile.Name) does not have the expected DCS diff.lua structure."
    }
}

foreach ($Validator in Get-ChildItem (Join-Path $RepoRoot 'scripts/validate') -Filter '*.ps1' | Sort-Object Name) {
    & $Validator.FullName -Joystick $Joystick
}

Write-Host 'Package validation passed.'

# Complete release validation when the bundle is present (preferred single Test-Package path).
$OvgmeName = "Scott-F-16C-Control-Profiles-$Version.zip"
$BundleName = "Scott-F-16C-Complete-Package-$Version"
$BundleArchive = Join-Path $RepoRoot "dist/$BundleName.zip"
if (Test-Path $BundleArchive -PathType Leaf) {
    $ReleaseVerifyRoot = Join-Path $RepoRoot '.build/release-verify'
    Remove-Item $ReleaseVerifyRoot -Recurse -Force -ErrorAction SilentlyContinue
    Expand-Archive $BundleArchive $ReleaseVerifyRoot
    $BundleRoot = Join-Path $ReleaseVerifyRoot $BundleName

    $RequiredFiles = @(
        "OVGME/$OvgmeName",
        'AutoHotKey/dcs-TQS.ahk',
        'Documentation/README.md',
        'Documentation/CHANGELOG.md',
        'Documentation/INSTALLATION.md',
        'Documentation/CONTROL-MAPPINGS.md',
        'Documentation/OPENKNEEBOARD-VAICOM.md',
        'Documentation/THIRD-PARTY-ASSETS.md',
        'Documentation/devices/VIPER-TQS.md',
        'SHA256SUMS.txt'
    )
    foreach ($RelativePath in $RequiredFiles) {
        if (-not (Test-Path (Join-Path $BundleRoot $RelativePath) -PathType Leaf)) {
            throw "Complete release bundle is missing $RelativePath."
        }
    }

    & (Join-Path $PSScriptRoot 'Test-AutoHotKey.ps1') -Path (Join-Path $BundleRoot 'AutoHotKey/dcs-TQS.ahk')

    $Checksums = Get-Content (Join-Path $BundleRoot 'SHA256SUMS.txt')
    foreach ($RelativePath in "OVGME/$OvgmeName", 'AutoHotKey/dcs-TQS.ahk') {
        $Expected = ($Checksums | Where-Object { $_ -match ('  ' + [regex]::Escape($RelativePath) + '$') }) -replace '\s+.*$', ''
        if ([string]::IsNullOrWhiteSpace($Expected)) { throw "Missing checksum for $RelativePath." }
        $Actual = (Get-FileHash (Join-Path $BundleRoot $RelativePath) -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($Actual -ne $Expected) { throw "Checksum mismatch for $RelativePath." }
    }

    Write-Host 'Complete release bundle validation passed.'
}
