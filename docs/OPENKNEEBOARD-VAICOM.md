# OpenKneeboard and VAICOM PRO

## Included tab

The OvGME package installs numbered PNG reference pages into:

```text
KNEEBOARD\F-16C_50
```

Numeric prefixes preserve page order. OpenKneeboard should discover the folder through its DCS Aircraft tab. If aircraft detection does not expose it, add the directory as a Folder tab.

The foundational pages cover the package overview, left MFD, right MFD, and OpenKneeboard/VAICOM operation. Device pages for the Viper TQS, AVA/Warthog grip, WINCTRL PTO2, and WINCTRL ViperAce ICP are generated only when the corresponding profile exists in the package. The PTO2 page includes its landing/taxi lights, arresting-hook UP/DOWN, and landing-gear mappings.

## VAICOM PRO

VAICOM PRO remains available for radio voice commands. The kneeboard does not replace, intercept, or modify VAICOM transmit bindings.

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

These commands can be added to the existing VoiceAttack profile without changing VAICOM's radio configuration.
