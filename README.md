# DCS F-16C Components

OvGME-ready DCS F-16C Block 50 control profiles and VR-optimized OpenKneeboard references for Scott's cockpit hardware.

The project deliberately keeps each physical device in its own GUID-qualified DCS `diff.lua` file. That makes the package reversible, reviewable, and safe to extend one component at a time.

## Current component

- Thrustmaster Cougar MFD 1 → left MFD (LMFD), one-to-one
- Thrustmaster Cougar MFD 2 → right MFD (RMFD), one-to-one
- Thrustmaster Cougar MFD 3 → reserved; this package does not change it

## Install

Download the generated `Scott-F-16C-Control-Profiles-<version>.zip` artifact or release asset, add it to OvGME, and enable it against your DCS Saved Games directory. See [docs/INSTALLATION.md](docs/INSTALLATION.md) for the exact paths and backup procedure.

The package installs both the active control profiles and generated pages under `KNEEBOARD\F-16C_50`. OpenKneeboard can use its DCS Aircraft tab or that directory as a Folder tab. See [OpenKneeboard and VAICOM PRO](docs/OPENKNEEBOARD-VAICOM.md).

## Build and validate

```powershell
./scripts/Build-OvGME.ps1 -Version 0.1.0
./scripts/Test-Package.ps1 -Version 0.1.0
```

The GitHub workflow parses every Lua profile, tests semantic versioning, generates the kneeboard, builds the archive, validates its contents, and uploads a prerelease-numbered CI package.

## Tag-based releases

Git tags in the form `vMAJOR.MINOR.PATCH` are the authoritative release versions. To publish, run **Create tagged OvGME release** from the Actions page and select a `patch`, `minor`, or `major` bump. The workflow calculates the next version from the newest stable tag, builds and validates that exact version, and only then creates the matching tag and GitHub Release.

Ordinary CI uses versions such as `0.0.0-ci.42`; local builds default to `0.0.0-local`. The build generates `VERSION.TXT` and replaces the packaged README's version token, preventing version drift between source metadata and the installable ZIP.

## Source of truth

The MFD profiles in this repository preserve Scott's supplied Saved Games profile content, with only a final newline normalized for source control. Their mappings also match the DCS F-16C built-in Cougar MFD templates supplied with the same DCS installation.
