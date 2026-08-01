# Installation

## Requirements

- DCS with the `F-16C_50` input directory
- OvGME configured to manage your DCS Saved Games directory
- OpenKneeboard for the included VR reference pages
- Scott's original device GUIDs, or a deliberate filename update for replacement hardware

## Back up first

Copy this directory before enabling the package:

```text
C:\Users\<you>\Saved Games\DCS.openbeta\Config\Input\F-16C_50
```

If your DCS Saved Games folder is named `DCS` rather than `DCS.openbeta`, use that folder instead.

## OvGME setup

1. Download `Scott-F-16C-Control-Profiles-<version>.zip`.
2. Configure an OvGME game configuration whose root is your DCS Saved Games folder, for example `C:\Users\<you>\Saved Games\DCS.openbeta`.
3. Add the ZIP to that configuration's mods repository.
4. Enable the package.
5. Start DCS and open **Options → Controls → F-16C Sim**.
6. Confirm MFD 1 operates the left MFD and MFD 2 operates the right MFD.
7. Confirm the PTO2 hook switch commands HOOK UP with `JOY_BTN32` and HOOK DOWN with `JOY_BTN34`.
8. In OpenKneeboard, select the F-16C in the DCS Aircraft tab. If it is not discovered, add `KNEEBOARD\F-16C_50` as a Folder tab.

The package installs its device profiles and OpenKneeboard pages beneath:

```text
Config\Input\F-16C_50\joystick\
KNEEBOARD\F-16C_50\
```

MFD 3 is intentionally untouched.

The package contains a fixed set of eight 1200 × 1600 kneeboard pages. The six hardware pages use local control images and callouts, so OpenKneeboard does not need network access. Build validation verifies the exact page set, dimensions, offline assets, mapping coverage, and deterministic output.

## GUID note

DCS includes the USB instance GUID in each Saved Games filename. If Windows assigns a different GUID after replacement or re-enumeration, export one temporary binding for that device in DCS and rename the packaged file to use the new GUID. Do not change the Lua content merely to update a GUID.

## Remove or restore

Disable the package in OvGME. If DCS wrote changes into either managed file while the package was enabled, restore your backup and re-import only the changes you intend to keep.
