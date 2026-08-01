# Control mappings

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
