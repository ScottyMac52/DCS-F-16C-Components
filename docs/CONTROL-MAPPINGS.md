# Control mappings

These mappings are also shown on the photo-backed pages installed under
`KNEEBOARD\F-16C_50`. The generated callouts are validated against every `JOY_BTN` present in
the corresponding device profile.

## Viper TQS — VAICOM TX bridge

| VAICOM TX | Physical input | VoiceAttack chord |
|---|---|---|
| TX1 — VHF AM | `5Joy1` / `JOY_BTN1` | `Ctrl+Alt+Shift+1` |
| TX2 — UHF | `5Joy2` / `JOY_BTN2` | `Ctrl+Alt+Shift+2` |
| TX3 — VHF FM | `5Joy3` / `JOY_BTN3` | `Ctrl+Alt+Shift+3` |
| TX4 — AUTO | `5Joy4` / `JOY_BTN4` | `Ctrl+Alt+Shift+4` |
| TX5 — Interphone | `5Joy5` / `JOY_BTN5` | `Ctrl+Alt+Shift+5` |

Buttons 1–5 are reserved for `autohotkey/dcs-TQS.ahk` and intentionally have no native DCS assignments. The profile explicitly removes the former VHF, UHF, IFF OUT, and IFF IN assignments from buttons 1–4. Button 5 was already unassigned. All other Viper TQS axes and buttons remain unchanged; see [the device mapping](devices/VIPER-TQS.md).

## Cougar MFD 1 — left MFD

| Physical control | DCS control |
|---|---|
| JOY_BTN1–JOY_BTN20 | Left MFD OSB 1–20 |
| JOY_BTN21 / JOY_BTN22 | Left MFD SYM increase / decrease |
| JOY_BTN23 / JOY_BTN24 | Left MFD CON increase / decrease |
| JOY_BTN25 / JOY_BTN26 | Left MFD BRT increase / decrease |
| JOY_BTN27 / JOY_BTN28 | Left MFD GAIN increase / decrease |

## Cougar MFD 2 — right MFD

| Physical control | DCS control |
|---|---|
| JOY_BTN1–JOY_BTN20 | Right MFD OSB 1–20 |
| JOY_BTN21 / JOY_BTN22 | Right MFD SYM increase / decrease |
| JOY_BTN23 / JOY_BTN24 | Right MFD CON increase / decrease |
| JOY_BTN25 / JOY_BTN26 | Right MFD BRT increase / decrease |
| JOY_BTN27 / JOY_BTN28 | Right MFD GAIN increase / decrease |

Both profiles explicitly remove the controller's automatically assigned Pitch, Roll, Rudder, and Thrust axes. This prevents a Cougar MFD from becoming an unintended flight-control source.

## Cougar MFD 3

Reserved. No MFD 3 profile is installed by this component.

## WINCTRL CarrierAce PTO2 — ground and landing controls

| Physical control | DCS control |
|---|---|
| JOY_BTN8 | Landing/taxi lights UP |
| JOY_BTN9 | Landing/taxi lights OFF |
| JOY_BTN12 | Landing/taxi lights TAXI (release returns OFF) |
| JOY_BTN32 | Arresting hook UP |
| JOY_BTN34 | Arresting hook DOWN |
| JOY_BTN35 | Landing gear UP |
| JOY_BTN37 | Landing gear DOWN |

The physical hook switch directly follows the F-16C HOOK switch. Unlisted PTO2 controls remain intentionally unbound.
