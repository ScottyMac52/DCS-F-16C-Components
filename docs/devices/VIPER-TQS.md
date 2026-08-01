# Thrustmaster Viper TQS and Mission Pack

This component preserves Scott's supplied Viper TQS USB numbering, maintained-switch positions, and axis tuning.

The matching OpenKneeboard page uses the locally committed Thrustmaster handle and panel control
maps from the official user manual, with callouts covering every mapped button and axis.

## Axes

| Physical axis | DCS control | Tuning |
|---|---|---|
| JOY_X | RDR CURSOR X | curvature 0.12, deadzone 0.02 |
| JOY_Y | RDR CURSOR Y | curvature 0.12, deadzone 0.02, inverted |
| JOY_RX | MAN RNG | direct |
| JOY_RY | ANT ELEV | direct |
| JOY_RZ | Zoom View | inverted |

Pitch, Roll, and Rudder are explicitly removed from this device profile. The supplied profile does not add a thrust axis.

## Throttle grip

| Buttons | DCS control |
|---|---|
| 1 / 2 / 3 / 4 | IFF OUT / UHF / IFF IN / VHF transmit switch positions |
| 6 | UNCAGE |
| 7 / 8 | DOGFIGHT / MISSILE OVERRIDE |
| 9 / 10 | Speed brake EXTEND / RETRACT |
| 12 | ENABLE depress |
| 13 / 14 / 15 / 16 | ICP DCS UP / SEQ / DOWN / RET |
| 17 | CHAFF/FLARE dispense |
| 18 | Throttle OFF (hold) ↔ IDLE |

## Mission Pack and console controls

| Buttons | DCS control |
|---|---|
| 22 | Emergency stores jettison |
| 23 / 24 | MASTER ARM / SIMULATE (center is OFF) |
| 25–28 / 55 | CMDS program 1–4 / BIT |
| 29–33 / 56 | CMDS mode STBY–BYP / OFF |
| 34–37 | RWR SEARCH / ACT-PWR / ALTITUDE / POWER |
| 38 / 57 | Landing gear UP / DOWN |
| 39–41 / 58 | Exterior-light master ALL / FORM / NORM / OFF |
| 42 / 43 / 44 | HDG set CW / CCW / depress |
| 45 / 59 | Stores configuration CAT I / CAT III |
| 46 / 47 | RF NORM / SILENT (center is QUIET) |
| 48 / 61 | LASER ARM / OFF |
| 49 / 62 | Jammer source ON / OFF |
| 50 / 51 / 63 | Autopilot roll HDG SEL / STRG SEL / ATT HOLD |
| 52 / 53 / 64 | Autopilot pitch ALT HOLD / ATT HOLD / OFF |

Safety note: confirm MASTER ARM, LASER ARM, stores configuration, and emergency-jettison switch positions in the DCS cockpit before flight.
