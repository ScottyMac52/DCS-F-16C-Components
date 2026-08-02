# OpenKneeboard and VAICOM PRO

## Included tab

The OvGME package installs numbered PNG reference pages into:

```text
KNEEBOARD\F-16C_50
```

Numeric prefixes preserve page order. OpenKneeboard should discover the folder through its DCS Aircraft tab. If aircraft detection does not expose it, add the directory as a Folder tab.

The fixed eight-page set covers the package overview, both Cougar MFDs, Viper TQS and Mission Pack, AVA/Warthog grip, WINCTRL PTO2, WINCTRL ViperAce ICP, and OpenKneeboard/VAICOM operation. Each hardware page uses a local control image with mapped-button callouts; no image is downloaded while building or using the package. The TQS page marks buttons 1–5 as reserved for the VAICOM bridge, and the final page lists the five physical inputs and TX channels.

The source image provenance, transformations, and redistribution terms are documented in [THIRD-PARTY-ASSETS.md](THIRD-PARTY-ASSETS.md).

## VAICOM PRO

VAICOM PRO remains the primary radio voice interface. Run `AutoHotKey\dcs-TQS.ahk` with AutoHotKey v2.0 to bridge the five Viper TQS transmit positions to VoiceAttack:

| TX | TQS input | VoiceAttack chord |
|---|---|---|
| TX1 — VHF AM | `5Joy1` | `Ctrl+Alt+Shift+1` |
| TX2 — UHF | `5Joy2` | `Ctrl+Alt+Shift+2` |
| TX3 — VHF FM | `5Joy3` | `Ctrl+Alt+Shift+3` |
| TX4 — AUTO | `5Joy4` | `Ctrl+Alt+Shift+4` |
| TX5 — Interphone | `5Joy5` | `Ctrl+Alt+Shift+5` |

Configure the same five chords in VoiceAttack/VAICOM before starting the bridge. DCS `JOY_BTN1` through `JOY_BTN5` must remain unassigned so one physical press cannot trigger both VAICOM and a native cockpit command. The script releases every synthetic modifier and number key when the physical switch is released and again when the script exits.

OpenKneeboard's optional VoiceAttack phrases should be unique and should not overlap VAICOM keywords.

## Optional VoiceAttack navigation

OpenKneeboard installs remote-control programs under:

```text
C:\Program Files\OpenKneeboard\utilities
```

| Suggested phrase | Program |
|---|---|
| Kneeboard next page | `OpenKneeboard-RemoteControl-NEXT_PAGE.exe` |
| Kneeboard previous page | `OpenKneeboard-RemoteControl-PREVIOUS_PAGE.exe` |
| Kneeboard next tab | `OpenKneeboard-RemoteControl-NEXT_TAB.exe` |
| Kneeboard previous tab | `OpenKneeboard-RemoteControl-PREVIOUS_TAB.exe` |
| Kneeboard brighter | `OpenKneeboard-RemoteControl-INCREASE_BRIGHTNESS.exe` |
| Kneeboard dimmer | `OpenKneeboard-RemoteControl-DECREASE_BRIGHTNESS.exe` |
| Kneeboard night | `OpenKneeboard-RemoteControl-ENABLE_TINT.exe` |
| Kneeboard day | `OpenKneeboard-RemoteControl-DISABLE_TINT.exe` |

These commands can be added to the existing VoiceAttack profile without changing VAICOM's TX bindings. Use phrases that do not overlap VAICOM keywords.
