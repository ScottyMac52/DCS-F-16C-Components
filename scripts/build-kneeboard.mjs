import { existsSync, mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';
import { resolvePackageVersion } from './version.mjs';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = resolve(scriptDir, '..');
const profileDir = join(root, 'src', 'Config', 'Input', 'F-16C_50', 'joystick');
const svgDir = join(root, 'kneeboard', 'source');
const pngDir = join(root, 'kneeboard', 'F-16C_50');
const version = resolvePackageVersion(process.env.PACKAGE_VERSION);
mkdirSync(svgDir, { recursive: true });
mkdirSync(pngDir, { recursive: true });

const profiles = existsSync(profileDir) ? readdirSync(profileDir) : [];
const hasProfile = (fragment) => profiles.some((name) => name.includes(fragment));
const esc = (value) => String(value)
  .replaceAll('&', '&amp;')
  .replaceAll('<', '&lt;')
  .replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;');

function wrap(text, max = 31) {
  const words = String(text).split(/\s+/);
  const lines = [];
  let line = '';
  for (const word of words) {
    if (!line) line = word;
    else if (`${line} ${word}`.length <= max) line += ` ${word}`;
    else { lines.push(line); line = word; }
  }
  if (line) lines.push(line);
  return lines.slice(0, 3);
}

const item = (key, text, accent = 'cyan') => ({ key, text, accent });
const pages = [
  {
    file: '01-CONTROL-OVERVIEW',
    title: 'F-16C COCKPIT CONTROL OVERVIEW',
    kicker: 'ONE-TO-ONE HARDWARE • GUID-QUALIFIED PROFILES • VR READY',
    items: [
      item('MFD 1', 'Left MFD • OSB 1–20 and four rockers', 'gold'),
      item('MFD 2', 'Right MFD • OSB 1–20 and four rockers', 'gold'),
      item('MFD 3', 'Reserved • no bindings installed', 'red'),
      item('TQS', hasProfile('Viper TQS') ? 'Throttle and Mission Pack profile installed' : 'Component not installed yet'),
      item('AVA', hasProfile('Ava [R] Viper') ? 'Warthog grip profile installed' : 'Component not installed yet'),
      item('PTO2', hasProfile('WINCTRL CarrierAce PTO 2') ? 'Ground-control profile installed' : 'Component not installed yet'),
      item('ICP', hasProfile('WINCTRL ViperAce ICP') ? 'ViperAce ICP profile installed' : 'Component not installed yet'),
      item('PATH', 'Config\\Input\\F-16C_50\\joystick'),
      item('KNEE', 'KNEEBOARD\\F-16C_50'),
      item('VOICE', 'VAICOM PRO remains available for radio voice commands'),
      item('RULE', 'Physical controls own deterministic cockpit actions'),
      item('BACKUP', 'Back up F-16C_50 before enabling OvGME', 'red'),
    ],
  },
  {
    file: '02-LEFT-MFD', title: 'COUGAR MFD 1 • LEFT MFD', kicker: 'ONE-TO-ONE LEFT BEZEL',
    items: [
      ...Array.from({ length: 20 }, (_, index) => item(`BTN ${index + 1}`, `Left MFD OSB ${index + 1}`)),
      item('BTN 21', 'SYM increase'), item('BTN 22', 'SYM decrease'),
      item('BTN 23', 'CON increase'), item('BTN 24', 'CON decrease'),
      item('BTN 25', 'BRT increase'), item('BTN 26', 'BRT decrease'),
      item('BTN 27', 'GAIN increase'), item('BTN 28', 'GAIN decrease'),
    ],
  },
  {
    file: '03-RIGHT-MFD', title: 'COUGAR MFD 2 • RIGHT MFD', kicker: 'ONE-TO-ONE RIGHT BEZEL',
    items: [
      ...Array.from({ length: 20 }, (_, index) => item(`BTN ${index + 1}`, `Right MFD OSB ${index + 1}`)),
      item('BTN 21', 'SYM increase'), item('BTN 22', 'SYM decrease'),
      item('BTN 23', 'CON increase'), item('BTN 24', 'CON decrease'),
      item('BTN 25', 'BRT increase'), item('BTN 26', 'BRT decrease'),
      item('BTN 27', 'GAIN increase'), item('BTN 28', 'GAIN decrease'),
    ],
  },
  hasProfile('Viper TQS') && {
    file: '04-VIPER-TQS', title: 'VIPER TQS + MISSION PACK', kicker: 'THROTTLE, HOTAS, DEFENSE AND PANEL CONTROLS',
    items: [
      item('X / Y', 'Radar cursor X / Y • curve 0.12 • DZ 0.02', 'gold'),
      item('RX / RY', 'Manual range / antenna elevation', 'gold'), item('RZ', 'Zoom view • inverted'),
      item('BTN 1–4', 'IFF OUT • UHF • IFF IN • VHF'), item('BTN 6', 'UNCAGE'),
      item('BTN 7 / 8', 'DOGFIGHT / missile override'), item('BTN 9 / 10', 'Speed brake extend / retract'),
      item('BTN 12', 'ENABLE depress'), item('BTN 13–16', 'DCS up / sequence / down / return'),
      item('BTN 17', 'Chaff / flare dispense'), item('BTN 18', 'Throttle OFF hold ↔ IDLE'),
      item('BTN 22', 'Emergency stores jettison', 'red'), item('BTN 23 / 24', 'Master arm / simulate', 'red'),
      item('25–33', 'CMDS program and mode selectors'), item('34–37', 'RWR controls'),
      item('38 / 57', 'Landing gear up / down'), item('39–41 / 58', 'Exterior-light master'),
      item('42–44', 'Heading set decrease / increase / depress'), item('45 / 59', 'Stores CAT I / CAT III'),
      item('46 / 47', 'RF normal / silent'), item('48 / 61', 'Laser arm / off', 'red'),
      item('49 / 62', 'Jammer source on / off'), item('50–53 / 63–64', 'Autopilot roll and pitch modes'),
    ],
  },
  hasProfile('Ava [R] Viper') && {
    file: '05-AVA-WARTHOG-GRIP', title: 'AVA BASE + WARTHOG GRIP', kicker: 'F-16 HOTAS STICK CONTROLS',
    items: [
      item('BTN 2', 'Weapon release', 'red'), item('BTN 3', 'NWS / A-R DISC / missile step', 'gold'),
      item('BTN 11', 'DMS up'), item('BTN 13', 'DMS down'), item('BTN 14', 'DMS left'), item('BTN 12', 'DMS right'),
      item('BTN 7', 'TMS up'), item('BTN 9', 'TMS down'), item('BTN 10', 'TMS left'), item('BTN 8', 'TMS right'),
      item('BTN 15', 'CMS forward'), item('BTN 17', 'CMS aft'), item('BTN 18', 'CMS left'), item('BTN 16', 'CMS right'),
      item('AXES', 'Rudder and thrust auto-assignments removed', 'red'),
    ],
  },
  hasProfile('WINCTRL CarrierAce PTO 2') && {
    file: '06-WINCTRL-PTO2', title: 'WINCTRL CARRIERACE PTO2', kicker: 'F-16 GROUND AND LANDING CONTROLS',
    items: [
      item('BTN 8', 'Landing / taxi lights switch up'), item('BTN 9', 'Landing / taxi lights off'),
      item('BTN 12', 'Taxi else off'), item('BTN 35', 'Landing gear up', 'gold'),
      item('BTN 37', 'Landing gear down', 'gold'), item('RESERVED', 'All other PTO2 controls intentionally unbound', 'red'),
    ],
  },
  hasProfile('WINCTRL ViperAce ICP') && {
    file: '07-WINCTRL-VIPERACE-ICP', title: 'WINCTRL VIPERACE ICP', kicker: 'DEVICE-SPECIFIC USB NUMBERING • DO NOT SUBSTITUTE GENERIC PROFILE',
    items: [
      item('0–9', 'BTN 18, 7–9, 11–13, 15–17'), item('BTN 1 / 2', 'COM1 / COM2'),
      item('BTN 3 / 4', 'IFF / LIST'), item('BTN 14 / 10', 'Enter / recall'),
      item('BTN 5 / 6', 'A-A / A-G master modes'), item('BTN 19 / 20', 'DED increment / decrement'),
      item('BTN 25', 'DCS return'), item('BTN 23', 'DCS sequence'), item('BTN 22 / 24', 'DCS up / down'),
      item('BTN 29', 'FLIR polarity'), item('BTN 30 / 31', 'FLIR increment / decrement'),
      item('BTN 32–34', 'FLIR gain / level / auto'), item('BTN 26–28', 'Drift cutout / norm / warn reset'),
      item('JOY Y', 'HUD symbology intensity', 'gold'), item('JOY X', 'Reticle depression', 'gold'),
      item('JOY RY', 'Raster intensity'), item('JOY RX', 'Raster contrast'),
      item('AXES', 'Pitch and roll removed before knob assignment', 'red'),
    ],
  },
  {
    file: '08-OPENKNEEBOARD-VAICOM', title: 'OPENKNEEBOARD + VAICOM PRO', kicker: 'VR REFERENCE PAGES • OPTIONAL VOICE NAVIGATION',
    items: [
      item('TAB', 'DCS Aircraft tab should discover F-16C_50', 'gold'),
      item('FOLDER', 'Fallback: add KNEEBOARD\\F-16C_50 as Folder tab'),
      item('VOICE', 'VAICOM PRO remains primary for radio commands'),
      item('PHRASES', 'Use unique phrases that do not overlap VAICOM', 'red'),
      item('NEXT', 'NEXT_PAGE.exe'),
      item('PREV', 'PREVIOUS_PAGE.exe'),
      item('NEXT TAB', 'NEXT_TAB.exe'),
      item('PREV TAB', 'PREVIOUS_TAB.exe'),
      item('BRIGHT+', 'INCREASE_BRIGHTNESS.exe'),
      item('BRIGHT−', 'DECREASE_BRIGHTNESS.exe'),
      item('NIGHT', 'ENABLE_TINT.exe'),
      item('DAY', 'DISABLE_TINT.exe'),
      item('UTILITIES', 'C:\\Program Files\\OpenKneeboard\\utilities'),
      item('ORDER', 'Numeric filenames preserve page order'),
    ],
  },
].filter(Boolean);

function render(page, index) {
  const width = 1200;
  const height = 1600;
  const margin = 54;
  const gap = 32;
  const colWidth = (width - margin * 2 - gap) / 2;
  const split = Math.ceil(page.items.length / 2);
  const columns = [page.items.slice(0, split), page.items.slice(split)];
  const maxRows = Math.max(...columns.map((column) => column.length));
  const rowHeight = Math.min(88, Math.floor(1270 / maxRows));
  const startY = 218;
  const colors = { cyan: '#58ddff', gold: '#ffd166', red: '#ff6f7d' };
  let body = '';

  for (let column = 0; column < 2; column += 1) {
    const x = margin + column * (colWidth + gap);
    columns[column].forEach((entry, row) => {
      const y = startY + row * rowHeight;
      const lines = wrap(entry.text, rowHeight < 72 ? 28 : 32);
      const accent = colors[entry.accent] ?? colors.cyan;
      body += `<rect x="${x}" y="${y}" width="${colWidth}" height="${rowHeight - 8}" rx="13" fill="#101f33" stroke="#263a52" stroke-width="2"/>`;
      body += `<rect x="${x + 12}" y="${y + 12}" width="126" height="${rowHeight - 32}" rx="9" fill="#08111f" stroke="${accent}" stroke-width="2"/>`;
      body += `<text x="${x + 75}" y="${y + rowHeight / 2 + 2}" text-anchor="middle" dominant-baseline="middle" font-size="23" font-weight="700" fill="${accent}">${esc(entry.key)}</text>`;
      const lineHeight = rowHeight < 72 ? 20 : 23;
      const textY = y + (rowHeight - 8 - (lines.length - 1) * lineHeight) / 2 + 7;
      lines.forEach((line, lineIndex) => {
        body += `<text x="${x + 154}" y="${textY + lineIndex * lineHeight}" font-size="${rowHeight < 72 ? 19 : 22}" font-weight="500" fill="#f2f7ff">${esc(line)}</text>`;
      });
    });
  }

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
  <defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#06101d"/><stop offset="1" stop-color="#0c1b2d"/></linearGradient></defs>
  <rect width="1200" height="1600" fill="url(#bg)"/><rect x="0" y="0" width="1200" height="16" fill="#58ddff"/>
  <text x="54" y="82" font-family="DejaVu Sans, Arial, sans-serif" font-size="47" font-weight="800" fill="#f5f9ff">${esc(page.title)}</text>
  <text x="56" y="132" font-family="DejaVu Sans, Arial, sans-serif" font-size="22" font-weight="700" letter-spacing="1.5" fill="#ffd166">${esc(page.kicker)}</text>
  <line x1="54" y1="166" x2="1146" y2="166" stroke="#263a52" stroke-width="3"/><g font-family="DejaVu Sans, Arial, sans-serif">${body}</g>
  <line x1="54" y1="1532" x2="1146" y2="1532" stroke="#263a52" stroke-width="2"/>
  <text x="54" y="1570" font-family="DejaVu Sans, Arial, sans-serif" font-size="19" fill="#8ea5bd">F-16C Block 50 • Scott's cockpit • VAICOM PRO • Package ${esc(version)}</text>
  <text x="1146" y="1570" text-anchor="end" font-family="DejaVu Sans, Arial, sans-serif" font-size="19" fill="#8ea5bd">${index + 1} / ${pages.length}</text>
</svg>`;
}

for (let index = 0; index < pages.length; index += 1) {
  const page = pages[index];
  const svg = render(page, index);
  writeFileSync(join(svgDir, `${page.file}.svg`), svg, 'utf8');
  await sharp(Buffer.from(svg)).png().toFile(join(pngDir, `${page.file}.png`));
}

console.log(`Generated ${pages.length} F-16C OpenKneeboard SVG and PNG pages for package ${version}.`);
