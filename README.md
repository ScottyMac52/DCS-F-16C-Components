# DCS F-16C Components

OvGME-ready DCS F-16C Block 50 control profiles for Scott's cockpit hardware.

The project deliberately keeps each physical device in its own GUID-qualified DCS `diff.lua` file. That makes the package reversible, reviewable, and safe to extend one component at a time.

## Current component

- Thrustmaster Cougar MFD 1 → left MFD (LMFD), one-to-one
- Thrustmaster Cougar MFD 2 → right MFD (RMFD), one-to-one
- Thrustmaster Cougar MFD 3 → reserved; this package does not change it

## Install

Download the generated `Scott-F-16C-Control-Profiles-<version>.zip` artifact or release asset, add it to OvGME, and enable it against your DCS Saved Games directory. See [docs/INSTALLATION.md](docs/INSTALLATION.md) for the exact paths and backup procedure.

## Build and validate

```powershell
./scripts/Build-OvGME.ps1
./scripts/Test-Package.ps1
```

The GitHub workflow also parses every Lua profile with `luac`, builds the archive, validates its paths and mappings, and uploads the finished package.

## Source of truth

The MFD profiles in this repository preserve Scott's supplied Saved Games profile content, with only a final newline normalized for source control. Their mappings also match the DCS F-16C built-in Cougar MFD templates supplied with the same DCS installation.
