# DCS F-16C Components

OvGME-ready DCS F-16C Block 50 control profiles, a Viper TQS-to-VAICOM push-to-talk bridge, and VR-optimized OpenKneeboard references for Scott's cockpit hardware.

The project deliberately keeps each physical device in its own GUID-qualified DCS `diff.lua` file. That makes the package reversible, reviewable, and safe to extend one component at a time.

## Current components

- Thrustmaster Cougar MFD 1 → left MFD (LMFD), one-to-one
- Thrustmaster Cougar MFD 2 → right MFD (RMFD), one-to-one
- Thrustmaster Cougar MFD 3 → reserved; this package does not change it
- Thrustmaster Viper TQS and Mission Pack → throttle, HOTAS, defense, panel controls, and five AutoHotKey-managed VAICOM transmit positions
- Thrustmaster AVA base with Warthog grip → F-16 stick HOTAS controls
- WINCTRL CarrierAce PTO2 → landing/taxi lights, arresting hook, and landing gear
- WINCTRL ViperAce ICP → ICP, DED, FLIR, and display controls

## Install

Download and extract `Scott-F-16C-Complete-Package-<version>.zip`. Add the OVGME ZIP inside it to OvGME, then configure the included `AutoHotKey\dcs-TQS.ahk` bridge. The direct `Scott-F-16C-Control-Profiles-<version>.zip` remains available for users who only need the DCS profiles and kneeboard pages. See [docs/INSTALLATION.md](docs/INSTALLATION.md) for the exact paths, VoiceAttack bindings, and startup procedure.

The OvGME package installs both the active control profiles and eight photo-backed reference pages under `KNEEBOARD\F-16C_50`. Each hardware page places the actual control image between its mapped-button callouts. OpenKneeboard can use its DCS Aircraft tab or that directory as a Folder tab. See [OpenKneeboard and VAICOM PRO](docs/OPENKNEEBOARD-VAICOM.md) and [third-party asset provenance](docs/THIRD-PARTY-ASSETS.md).

## VAICOM PRO bridge

The supplied AutoHotKey v2 script maps Viper TQS joystick device 5 to VoiceAttack/VAICOM while keeping those buttons unassigned in DCS:

| VAICOM TX | Physical input | VoiceAttack chord |
|---|---|---|
| TX1 — VHF AM | `5Joy1` | `Ctrl+Alt+Shift+1` |
| TX2 — UHF | `5Joy2` | `Ctrl+Alt+Shift+2` |
| TX3 — VHF FM | `5Joy3` | `Ctrl+Alt+Shift+3` |
| TX4 — AUTO | `5Joy4` | `Ctrl+Alt+Shift+4` |
| TX5 — Interphone | `5Joy5` | `Ctrl+Alt+Shift+5` |

`JOY_BTN1` through `JOY_BTN5` are reserved exclusively for this bridge. The Viper TQS profile explicitly removes the former native DCS bindings on buttons 1–4, and validation prevents any of the five positions from being assigned to DCS again.

## Shared kneeboard pipeline

One script builds every page: `scripts/build-kneeboard.mjs`.

- Consumer-owned summary pages (overview + OpenKneeboard/VAICOM notes) are generated locally.
- Hardware pages are rendered from `config/kneeboard.json` through DCS-Common (`shared-hardware-consumer.mjs` and `profile-driven-kneeboard.mjs`).

DCS-Common is located via `DCS_COMMON_ROOT` or the CI checkout at `.dcs-common`. There is no separate `apply-shared-hardware` step.

## Build and validate

Requirements: Node.js 22, PowerShell 7, and a [DCS-Common](https://github.com/ScottyMac52/DCS-Common) checkout.

```powershell
npm ci
$env:DCS_COMMON_ROOT = 'C:\path\to\DCS-Common'
npm run build:kneeboard
npm run test:kneeboard
npm run test:versioning
./scripts/Build-OvGME.ps1 -Version 0.1.0
./scripts/Test-Package.ps1 -Version 0.1.0
./scripts/Test-AutoHotKey.ps1
./scripts/Build-Release.ps1 -Version 0.1.0
./scripts/Test-Package.ps1 -Version 0.1.0
```

`Test-Package.ps1` validates the OVGME package and, when the complete release ZIP is present, the complete release bundle. There is no `Test-Release.ps1`.

The GitHub workflow parses every Lua profile, tests semantic versioning, generates and deterministically validates all kneeboard images, validates the AutoHotKey bridge, builds both archives, verifies their contents and checksums, and uploads a prerelease-numbered complete package.

## Tag-based releases

Git tags in the form `vMAJOR.MINOR.PATCH` are the authoritative release versions. To publish, run **Create tagged OvGME release** from the Actions page and select a `patch`, `minor`, or `major` bump. The workflow calculates the next version from the newest stable tag, builds and validates that exact version, and only then creates the matching tag and GitHub Release.

Ordinary CI uses versions such as `0.0.0-ci.42`; local builds default to `0.0.0-local`. The build generates `VERSION.TXT` and replaces the packaged README's version token, preventing version drift between source metadata and the installable ZIP.

## Source of truth

The profiles in this repository preserve Scott's supplied Saved Games device identities and mappings. Device-specific validators lock the intended controls—including both PTO2 hook positions and the TQS VAICOM reservation—to their exact DCS command and physical button assignments.
