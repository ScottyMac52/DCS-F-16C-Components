# DCS F-16C Components

This release packages Scott's complete F-16C Block 50 cockpit-control configuration.

## Downloads

- **Scott-F-16C-Complete-Package** — complete bundle containing the installable OvGME archive, AutoHotKey/VAICOM bridge, documentation, and checksums.
- **Scott-F-16C-Control-Profiles** — direct OvGME package for the DCS profiles and OpenKneeboard pages.
- **SHA256SUMS.txt** — integrity hashes for both ZIP files.

## Included configuration

- one-to-one Thrustmaster Cougar MFD 1 → LMFD profile;
- one-to-one Thrustmaster Cougar MFD 2 → RMFD profile;
- MFD 3 intentionally reserved;
- OvGME-ready Saved Games directory layout;
- eight photo-backed OpenKneeboard pages under `KNEEBOARD\F-16C_50` with local hardware images and mapped-control callouts;
- Viper TQS buttons 1–5 reserved for the supplied AutoHotKey v2/VoiceAttack/VAICOM PRO TX1–TX5 bridge;
- VAICOM-safe optional VoiceAttack kneeboard navigation;
- tag-authoritative semantic versioning with automated patch/minor/major releases;
- automated Lua, AutoHotKey, version, archive, path, mapping, deterministic image, checksum, and offline-asset validation;
- GUID-qualified Viper TQS, AVA/Warthog grip, WINCTRL CarrierAce PTO2, and WINCTRL ViperAce ICP profiles;
- PTO2 landing/taxi lights, arresting-hook UP/DOWN, and landing-gear controls.

The OvGME package targets the DCS Saved Games root and installs into `Config\Input\F-16C_50` plus `KNEEBOARD\F-16C_50`. See `Documentation/INSTALLATION.md` inside the complete package before installation.
