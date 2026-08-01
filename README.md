# DCS F-16C Components

OvGME-ready DCS F-16C Block 50 control profiles and VR-optimized OpenKneeboard references for Scott's cockpit hardware.

The project deliberately keeps each physical device in its own GUID-qualified DCS `diff.lua` file. That makes the package reversible, reviewable, and safe to extend one component at a time.

## Current components

- Thrustmaster Cougar MFD 1 → left MFD (LMFD), one-to-one
- Thrustmaster Cougar MFD 2 → right MFD (RMFD), one-to-one
- Thrustmaster Cougar MFD 3 → reserved; this package does not change it
- Thrustmaster Viper TQS and Mission Pack → throttle, HOTAS, defense, and panel controls
- Thrustmaster AVA base with Warthog grip → F-16 stick HOTAS controls
- WINCTRL CarrierAce PTO2 → landing/taxi lights, arresting hook, and landing gear
- WINCTRL ViperAce ICP → ICP, DED, FLIR, and display controls

## Install

Download the generated `Scott-F-16C-Control-Profiles-<version>.zip` artifact or release asset, add it to OvGME, and enable it against your DCS Saved Games directory. See [docs/INSTALLATION.md](docs/INSTALLATION.md) for the exact paths and backup procedure.

The package installs both the active control profiles and eight photo-backed reference pages under `KNEEBOARD\F-16C_50`. Each hardware page places the actual control image between its mapped-button callouts. OpenKneeboard can use its DCS Aircraft tab or that directory as a Folder tab. See [OpenKneeboard and VAICOM PRO](docs/OPENKNEEBOARD-VAICOM.md) and [third-party asset provenance](docs/THIRD-PARTY-ASSETS.md).

## Build and validate

```powershell
npm ci
npm run build:kneeboard
npm run test:kneeboard
./scripts/Build-OvGME.ps1 -Version 0.1.0
./scripts/Test-Package.ps1 -Version 0.1.0
```

The GitHub workflow parses every Lua profile, tests semantic versioning, generates and deterministically validates all kneeboard images, builds the archive, validates its contents, and uploads a prerelease-numbered CI package.

## Tag-based releases

Git tags in the form `vMAJOR.MINOR.PATCH` are the authoritative release versions. To publish, run **Create tagged OvGME release** from the Actions page and select a `patch`, `minor`, or `major` bump. The workflow calculates the next version from the newest stable tag, builds and validates that exact version, and only then creates the matching tag and GitHub Release.

Ordinary CI uses versions such as `0.0.0-ci.42`; local builds default to `0.0.0-local`. The build generates `VERSION.TXT` and replaces the packaged README's version token, preventing version drift between source metadata and the installable ZIP.

## Source of truth

The profiles in this repository preserve Scott's supplied Saved Games device identities and mappings. Device-specific validators lock the intended controls—including both PTO2 hook positions—to their exact DCS command and physical button assignments.
