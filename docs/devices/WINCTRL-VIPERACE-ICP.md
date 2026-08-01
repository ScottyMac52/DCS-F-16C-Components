# WINCTRL ViperAce ICP

Scott's supplied profile is authoritative for this device. Its USB numbering differs from the generic DCS `Vipergear ICP` template.

## Primary ICP controls

| Buttons | DCS control |
|---|---|
| 18, 7–9, 11–13, 15–17 | Priority-function keys 0–9 |
| 1 / 2 / 3 / 4 | COM1 / COM2 / IFF / LIST |
| 14 / 10 | ENTR / RCL |
| 5 / 6 | A-A / A-G master mode |
| 19 / 20 | DED increment / decrement |
| 25 / 23 / 22 / 24 | DCS RET / SEQ / UP / DOWN |

## Additional controls

| Buttons | DCS control |
|---|---|
| 29 | FLIR polarity |
| 30 / 31 | FLIR increment / decrement |
| 32 / 33 / 34 | FLIR gain / level / auto |
| 26 / 27 / 28 | Drift cutout / norm / warn reset |

## Analog controls

| Physical axis | DCS control |
|---|---|
| JOY_Y | HUD symbology intensity |
| JOY_X | Reticle depression |
| JOY_RY | Raster intensity |
| JOY_RX | Raster contrast |

Pitch and Roll are explicitly removed before JOY_Y and JOY_X are reassigned to ICP knobs.

