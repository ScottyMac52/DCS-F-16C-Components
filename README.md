# DCS-F-16C-50-Components

Scaffolded by **DCS Input Profile Importer** (DCS-Common).

| Identity | Value |
| --- | --- |
| Display name | F-16C_50 |
| DCS input module | `F-16C_50` |
| Kneeboard folder | `F-16C_50` |

## Local build

```bash
npm ci
export DCS_COMMON_ROOT=/path/to/DCS-Common   # or checkout at .dcs-common
npm run build:kneeboard
npm run test:kneeboard
```

Review `SCAFFOLD-REPORT.md` and refine `config/kneeboard.json` before the first release.

See DCS-Common [consumer-repository-setup.md](https://github.com/ScottyMac52/DCS-Common/blob/main/docs/consumer-repository-setup.md).
