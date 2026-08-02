# Installation

## Requirements

- DCS with the `F-16C_50` input directory
- OvGME configured to manage your DCS Saved Games directory
- OpenKneeboard for the included VR reference pages
- AutoHotKey v2.0 for the Viper TQS push-to-talk bridge
- VoiceAttack with VAICOM PRO configured for TX1–TX5
- Scott's original device GUIDs, or a deliberate filename update for replacement hardware

## Release package

Download and extract `Scott-F-16C-Complete-Package-<version>.zip`. It contains:

- `OVGME` — the directly installable DCS profiles and kneeboard ZIP
- `AutoHotKey` — `dcs-TQS.ahk`, the Viper TQS-to-VAICOM transmit bridge
- `Documentation` — installation, mappings, device details, and OpenKneeboard guidance
- `SHA256SUMS.txt` — hashes for the included installable files

The direct `Scott-F-16C-Control-Profiles-<version>.zip` release asset is identical to the ZIP inside the complete package.

## Back up first

Copy this directory before enabling the package:

```text
C:\Users\<you>\Saved Games\DCS.openbeta\Config\Input\F-16C_50
```

If your DCS Saved Games folder is named `DCS` rather than `DCS.openbeta`, use that folder instead.

## OvGME setup

1. Use `OVGME\Scott-F-16C-Control-Profiles-<version>.zip` from the extracted complete package.
2. Configure an OvGME game configuration whose root is your DCS Saved Games folder, for example `C:\Users\<you>\Saved Games\DCS.openbeta`.
3. Add the ZIP to that configuration's mods repository.
4. Enable the package.
5. Start DCS and open **Options → Controls → F-16C Sim**.
6. Confirm MFD 1 operates the left MFD and MFD 2 operates the right MFD.
7. Confirm Viper TQS `JOY_BTN1` through `JOY_BTN5` have no DCS assignments.
8. Confirm the PTO2 hook switch commands HOOK UP with `JOY_BTN32` and HOOK DOWN with `JOY_BTN34`.
9. In OpenKneeboard, select the F-16C in the DCS Aircraft tab. If it is not discovered, add `KNEEBOARD\F-16C_50` as a Folder tab.

The package installs its device profiles and OpenKneeboard pages beneath:

```text
Config\Input\F-16C_50\joystick\
KNEEBOARD\F-16C_50\
```

MFD 3 is intentionally untouched.

The package contains a fixed set of eight 1200 × 1600 kneeboard pages. The six hardware pages use local control images and callouts, so OpenKneeboard does not need network access. Build validation verifies the exact page set, dimensions, offline assets, mapping coverage, and deterministic output.

## AutoHotKey and VAICOM

1. Install AutoHotKey v2.0. The script is not compatible with AutoHotKey v1.
2. In VoiceAttack/VAICOM, bind TX1 through TX5 to `Ctrl+Alt+Shift+1` through `Ctrl+Alt+Shift+5`, respectively.
3. Start VoiceAttack and VAICOM PRO.
4. Run `AutoHotKey\dcs-TQS.ahk` from the extracted complete package.
5. Confirm the AutoHotKey tray icon is present, then hold and release each TQS transmit position while watching VAICOM's TX indication.
6. Start DCS and verify those inputs do not open a native radio menu or trigger an IFF command.

The authoritative script expects the Viper TQS to be AutoHotKey joystick device 5 (`5Joy1` through `5Joy5`). If Windows changes the joystick number after USB re-enumeration, use AutoHotKey's joystick test utility to identify the new number and update all five prefixes together; do not change the button-to-TX order.

To start the bridge at Windows sign-in, press **Win+R**, enter `shell:startup`, and place a shortcut to `dcs-TQS.ahk` in the opened Startup folder. Keep the extracted script at a stable path so the shortcut remains valid.

## GUID note

DCS includes the USB instance GUID in each Saved Games filename. If Windows assigns a different GUID after replacement or re-enumeration, export one temporary binding for that device in DCS and rename the packaged file to use the new GUID. Do not change the Lua content merely to update a GUID.

## Remove or restore

Exit `dcs-TQS.ahk` from its tray icon and disable the package in OvGME. If DCS wrote changes into a managed profile while the package was enabled, restore your backup and re-import only the changes you intend to keep.
