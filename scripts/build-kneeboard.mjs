import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import sharp from 'sharp';
import { resolvePackageVersion } from './version.mjs';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = resolve(scriptDir, '..');
const commonRoot = resolve(process.env.DCS_COMMON_ROOT ?? join(root, '.dcs-common'));
const { formatProvenanceFooter } = await import(pathToFileURL(join(commonRoot, 'scripts/shared-hardware-consumer.mjs')));
const profileDir = join(root, 'src', 'Config', 'Input', 'F-16C_50', 'joystick');
const svgDir = join(root, 'kneeboard', 'source');
const pngDir = join(root, 'kneeboard', 'F-16C_50');
const assetDir = join(root, 'kneeboard', 'assets', 'source');
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

function wrap(text, max = 28, limit = 2) {
  const words = String(text).split(/\s+/);
  const lines = [];
  let line = '';
  for (const word of words) {
    if (!line) line = word;
    else if (`${line} ${word}`.length <= max) line += ` ${word}`;
    else { lines.push(line); line = word; }
  }
  if (line) lines.push(line);
  if (lines.length <= limit) return lines;
  const clipped = lines.slice(0, limit);
  clipped[limit - 1] = `${clipped[limit - 1].replace(/[.,;:]$/, '')}…`;
  return clipped;
}

const item = (key, text, accent = 'cyan') => ({ key, text, accent });
const callout = (key, text, side, anchor, accent = 'cyan') => ({ key, text, side, anchor, accent });
const colors = { cyan: '#46d8ff', gold: '#ffc95c', red: '#ff6b76' };

function dataUri(buffer, mime) {
  return `data:${mime};base64,${buffer.toString('base64')}`;
}

function preparedAssets() {
  return {
    mfd: dataUri(readFileSync(join(assetDir, 'cougar-mfd-clean.png')), 'image/png'),
    pto2: dataUri(readFileSync(join(assetDir, 'pto2-clean.png')), 'image/png'),
    tqsHandle: dataUri(readFileSync(join(assetDir, 'viper-tqs-handle-controls.png')), 'image/png'),
    tqsPanel: dataUri(readFileSync(join(assetDir, 'viper-panel-controls.png')), 'image/png'),
    stickFront: dataUri(readFileSync(join(assetDir, 'warthog-grip-front.png')), 'image/png'),
    stickRear: dataUri(readFileSync(join(assetDir, 'warthog-grip-rear.png')), 'image/png'),
    icp: dataUri(readFileSync(join(assetDir, 'viperace-icp-clean.png')), 'image/png'),
  };
}

function frame(title, kicker, body, index, pageCount) {
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1200" height="1600" viewBox="0 0 1200 1600">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#06101d"/><stop offset="1" stop-color="#0c1b2d"/></linearGradient>
    <filter id="deviceShadow" x="-25%" y="-25%" width="150%" height="150%"><feDropShadow dx="0" dy="12" stdDeviation="15" flood-color="#000" flood-opacity="0.65"/></filter>
  </defs>
  <rect width="1200" height="1600" fill="url(#bg)"/><rect x="0" y="0" width="1200" height="16" fill="#46d8ff"/>
  <text x="54" y="80" font-family="DejaVu Sans,Arial,sans-serif" font-size="44" font-weight="800" fill="#f5f9ff">${esc(title)}</text>
  <text x="56" y="126" font-family="DejaVu Sans,Arial,sans-serif" font-size="20" font-weight="700" letter-spacing="1.2" fill="#ffc95c">${esc(kicker)}</text>
  <line x1="54" y1="156" x2="1146" y2="156" stroke="#263a52" stroke-width="3"/>
  ${body}
  <line x1="54" y1="1532" x2="1146" y2="1532" stroke="#263a52" stroke-width="2"/>
  <text x="54" y="1570" font-family="DejaVu Sans,Arial,sans-serif" font-size="18" fill="#8ea5bd">${esc(formatProvenanceFooter({ commonRoot, consumer: 'DCS-F-16C-Components', consumerVersion: version }))}</text>
  <text x="1146" y="1570" text-anchor="end" font-family="DejaVu Sans,Arial,sans-serif" font-size="18" fill="#8ea5bd">${index + 1} / ${pageCount}</text>
</svg>`;
}

function summaryPage(page, index, pageCount) {
  const margin = 54;
  const gap = 32;
  const colWidth = (1200 - margin * 2 - gap) / 2;
  const split = Math.ceil(page.items.length / 2);
  const columns = [page.items.slice(0, split), page.items.slice(split)];
  const maxRows = Math.max(...columns.map((column) => column.length));
  const rowHeight = Math.min(88, Math.floor(1320 / maxRows));
  const startY = 182;
  let body = '<g font-family="DejaVu Sans,Arial,sans-serif">';

  for (let column = 0; column < 2; column += 1) {
    const x = margin + column * (colWidth + gap);
    columns[column].forEach((entry, row) => {
      const y = startY + row * rowHeight;
      const lines = wrap(entry.text, rowHeight < 72 ? 28 : 32, 3);
      const accent = colors[entry.accent] ?? colors.cyan;
      body += `<rect x="${x}" y="${y}" width="${colWidth}" height="${rowHeight - 8}" rx="13" fill="#101f33" stroke="#263a52" stroke-width="2"/>`;
      body += `<rect x="${x + 12}" y="${y + 12}" width="126" height="${rowHeight - 32}" rx="9" fill="#08111f" stroke="${accent}" stroke-width="2"/>`;
      body += `<text x="${x + 75}" y="${y + rowHeight / 2 + 2}" text-anchor="middle" dominant-baseline="middle" font-size="22" font-weight="700" fill="${accent}">${esc(entry.key)}</text>`;
      const lineHeight = rowHeight < 72 ? 19 : 22;
      const textY = y + (rowHeight - 8 - (lines.length - 1) * lineHeight) / 2 + 7;
      lines.forEach((line, lineIndex) => {
        body += `<text x="${x + 154}" y="${textY + lineIndex * lineHeight}" font-size="${rowHeight < 72 ? 18 : 21}" font-weight="500" fill="#f2f7ff">${esc(line)}</text>`;
      });
    });
  }
  body += '</g>';
  return frame(page.title, page.kicker, body, index, pageCount);
}

function imageElement(layer) {
  return `<image x="${layer.x}" y="${layer.y}" width="${layer.width}" height="${layer.height}" href="${layer.href}" preserveAspectRatio="xMidYMid meet" opacity="${layer.opacity ?? 1}" filter="url(#deviceShadow)"/>`;
}

function hardwarePage(page, index, pageCount) {
  const left = page.callouts.filter((entry) => entry.side === 'left');
  const right = page.callouts.filter((entry) => entry.side === 'right');
  const labelWidth = 286;
  const leftX = 54;
  const rightX = 860;
  const top = 182;
  const bottom = page.notes?.length ? 1250 : 1480;
  let body = '<g font-family="DejaVu Sans,Arial,sans-serif">';
  body += '<rect x="348" y="182" width="504" height="1288" rx="26" fill="#08121f" stroke="#1b334a" stroke-width="3"/>';
  for (const layer of page.images) body += imageElement(layer);

  if (page.directMarkers) {
    const markers = new Map();
    for (const entry of page.callouts) {
      const markerKey = entry.anchor.join(',');
      const marker = markers.get(markerKey) ?? { anchor: entry.anchor, entries: [] };
      marker.entries.push(entry);
      markers.set(markerKey, marker);
    }
    for (const marker of markers.values()) {
      const label = marker.entries.map((entry) => entry.key.replace(/^BTN\s+/, '')).join('/');
      const accentName = marker.entries.some((entry) => entry.accent === 'red') ? 'red' : marker.entries.some((entry) => entry.accent === 'gold') ? 'gold' : 'cyan';
      const accent = colors[accentName];
      const markerWidth = Math.max(28, label.length * 7 + 12);
      body += `<rect x="${marker.anchor[0] - markerWidth / 2}" y="${marker.anchor[1] - 13}" width="${markerWidth}" height="26" rx="8" fill="#06101d" stroke="${accent}" stroke-width="2"/>`;
      body += `<text x="${marker.anchor[0]}" y="${marker.anchor[1] + 1}" text-anchor="middle" dominant-baseline="middle" font-size="10" font-weight="800" fill="${accent}">${esc(label)}</text>`;
    }
  }

  const drawSide = (entries, side) => {
    if (!entries.length) return;
    const routedEntries = [...entries].sort((a, b) => a.anchor[1] - b.anchor[1]);
    const spacing = (bottom - top) / routedEntries.length;
    routedEntries.forEach((entry, row) => {
      const cardHeight = Math.min(72, spacing - 7);
      const y = top + row * spacing + (spacing - cardHeight) / 2;
      const x = side === 'left' ? leftX : rightX;
      const lineStartX = side === 'left' ? x + labelWidth : x;
      const accent = colors[entry.accent] ?? colors.cyan;
      const lines = wrap(entry.text, 22, 2);
      if (!page.directMarkers) {
        body += `<path d="M ${lineStartX} ${y + cardHeight / 2} L ${entry.anchor[0]} ${entry.anchor[1]}" fill="none" stroke="${accent}" stroke-width="2.5" opacity="0.9"/>`;
        body += `<circle cx="${entry.anchor[0]}" cy="${entry.anchor[1]}" r="7" fill="#06101d" stroke="${accent}" stroke-width="3"/>`;
      }
      body += `<rect x="${x}" y="${y}" width="${labelWidth}" height="${cardHeight}" rx="11" fill="#0d1b2b" stroke="${accent}" stroke-width="2"/>`;
      body += `<rect x="${x + 9}" y="${y + 9}" width="82" height="${cardHeight - 18}" rx="7" fill="#06101d" stroke="${accent}" stroke-width="1.5"/>`;
      const keySize = Math.max(8, 16 - Math.max(0, entry.key.length - 8) * 0.9);
      body += `<text x="${x + 50}" y="${y + cardHeight / 2 + 1}" text-anchor="middle" dominant-baseline="middle" font-size="${keySize}" font-weight="800" fill="${accent}">${esc(entry.key)}</text>`;
      const textY = y + (cardHeight - (lines.length - 1) * 17) / 2 + 6;
      lines.forEach((line, lineIndex) => {
        body += `<text x="${x + 101}" y="${textY + lineIndex * 17}" font-size="16" font-weight="600" fill="#f2f7ff">${esc(line)}</text>`;
      });
    });
  };

  drawSide(left, 'left');
  drawSide(right, 'right');
  if (page.notes?.length) {
    const noteTop = 1260;
    const noteWidth = (1092 - (page.notes.length - 1) * 14) / page.notes.length;
    page.notes.forEach((note, noteIndex) => {
      const x = 54 + noteIndex * (noteWidth + 14);
      const accent = colors[note.accent] ?? colors.cyan;
      const lines = wrap(note.text, Math.floor(noteWidth / 12), 3);
      body += `<rect x="${x}" y="${noteTop}" width="${noteWidth}" height="210" rx="15" fill="#101f33" stroke="${accent}" stroke-width="2"/>`;
      body += `<text x="${x + 18}" y="${noteTop + 36}" font-size="18" font-weight="800" fill="${accent}">${esc(note.key)}</text>`;
      lines.forEach((line, lineIndex) => {
        body += `<text x="${x + 18}" y="${noteTop + 72 + lineIndex * 25}" font-size="18" font-weight="600" fill="#f2f7ff">${esc(line)}</text>`;
      });
    });
  }
  body += '</g>';
  return frame(page.title, page.kicker, body, index, pageCount);
}

function mfdAnchors() {
  const top = [430, 505, 580, 655, 730].map((x) => [x, 555]);
  const right = [640, 710, 780, 850, 920].map((y) => [805, y]);
  const bottom = [730, 655, 580, 505, 430].map((x) => [x, 1030]);
  const left = [920, 850, 780, 710, 640].map((y) => [395, y]);
  return [...top, ...right, ...bottom, ...left, [820, 615], [820, 660], [820, 960], [820, 1005], [380, 1005], [380, 960], [380, 660], [380, 615]];
}

function mfdCallouts(sideName) {
  const anchors = mfdAnchors();
  const items = [
    ...Array.from({ length: 20 }, (_, index) => item(`BTN ${index + 1}`, `${sideName} MFD OSB ${index + 1}`)),
    item('BTN 21', 'SYM increase'), item('BTN 22', 'SYM decrease'),
    item('BTN 23', 'CON increase'), item('BTN 24', 'CON decrease'),
    item('BTN 25', 'BRT increase'), item('BTN 26', 'BRT decrease'),
    item('BTN 27', 'GAIN increase'), item('BTN 28', 'GAIN decrease'),
  ];
  return items.map((entry, index) => callout(entry.key, entry.text, anchors[index][0] < 600 ? 'left' : 'right', anchors[index], entry.accent));
}

const assets = preparedAssets();
const pages = [
  {
    type: 'summary', file: '01-CONTROL-OVERVIEW', title: 'F-16C COCKPIT CONTROL OVERVIEW', kicker: 'ONE-TO-ONE HARDWARE • GUID-QUALIFIED PROFILES • VR READY',
    items: [
      item('MFD 1', 'Left MFD • OSB 1–20 and four rockers', 'gold'), item('MFD 2', 'Right MFD • OSB 1–20 and four rockers', 'gold'),
      item('MFD 3', 'Reserved • no bindings installed', 'red'), item('TQS', hasProfile('Viper TQS') ? 'Throttle and Mission Pack profile installed' : 'Component not installed yet'),
      item('AVA', hasProfile('Ava [R] Viper') ? 'Warthog grip profile installed' : 'Component not installed yet'), item('PTO2', hasProfile('WINCTRL CarrierAce PTO 2') ? 'Ground and landing profile installed' : 'Component not installed yet'),
      item('ICP', hasProfile('WINCTRL ViperAce ICP') ? 'ViperAce ICP profile installed' : 'Component not installed yet'), item('PATH', 'Config\\Input\\F-16C_50\\joystick'),
      item('KNEE', 'KNEEBOARD\\F-16C_50'), item('VOICE', 'TQS BTN 1–5 drive VAICOM TX1–TX5 through AHK'),
      item('RULE', 'Physical controls own deterministic cockpit actions'), item('BACKUP', 'Back up F-16C_50 before enabling OvGME', 'red'),
    ],
  },
  {
    type: 'hardware', file: '02-LEFT-MFD', title: 'COUGAR MFD 1 • LEFT MFD', kicker: 'ONE-TO-ONE LEFT BEZEL',
    images: [{ href: assets.mfd, x: 360, y: 500, width: 480, height: 590, opacity: 0.8 }], directMarkers: true, callouts: mfdCallouts('Left'),
  },
  {
    type: 'hardware', file: '03-RIGHT-MFD', title: 'COUGAR MFD 2 • RIGHT MFD', kicker: 'ONE-TO-ONE RIGHT BEZEL',
    images: [{ href: assets.mfd, x: 360, y: 500, width: 480, height: 590, opacity: 0.8 }], directMarkers: true, callouts: mfdCallouts('Right'),
  },
  hasProfile('Viper TQS') && {
    type: 'hardware', file: '04-VIPER-TQS', title: 'VIPER TQS + MISSION PACK', kicker: 'THROTTLE, HOTAS, DEFENSE AND PANEL CONTROLS',
    images: [
      { href: assets.tqsHandle, x: 365, y: 220, width: 470, height: 650, opacity: 0.96 },
      { href: assets.tqsPanel, x: 365, y: 820, width: 470, height: 600, opacity: 0.96 },
    ],
    callouts: [
      callout('BTN 1–5', 'Reserved for VAICOM AHK • TX1–TX5', 'left', [555, 330], 'red'),
      callout('BTN 6', 'UNCAGE', 'left', [675, 330]), callout('RX / RY', 'Range / antenna elevation', 'left', [710, 350], 'gold'),
      callout('BTN 9/10', 'Speed brake extend / retract', 'left', [730, 410]), callout('BTN 7/8', 'DOGFIGHT / missile override', 'left', [715, 455]),
      callout('BTN 13–16', 'DCS up / sequence / down / return', 'left', [610, 455]), callout('X / Y', 'Radar cursor X / Y', 'left', [675, 600], 'gold'),
      callout('BTN 12', 'ENABLE depress', 'left', [675, 600]), callout('BTN 17', 'Chaff / flare dispense', 'left', [520, 750]),
      callout('BTN 18', 'Throttle OFF hold ↔ IDLE', 'left', [470, 770]),
      callout('BTN 22', 'Emergency stores jettison', 'right', [520, 970], 'red'), callout('BTN 38/57', 'Landing gear up / down', 'right', [660, 990], 'gold'),
      callout('BTN 23/24', 'Master arm / simulate', 'right', [520, 1080], 'red'), callout('BTN 25–28/55', 'CMDS program selector', 'right', [650, 1080]),
      callout('BTN 29–33/56', 'CMDS mode selector', 'right', [735, 1080]), callout('BTN 34–37', 'RWR controls', 'right', [515, 1150]),
      callout('RZ', 'Zoom view • inverted', 'right', [690, 1150]), callout('BTN 45/59', 'Stores CAT I / CAT III', 'right', [560, 1190]),
      callout('BTN 46/47', 'RF normal / silent', 'right', [520, 1220]), callout('BTN 39–41/58', 'Exterior-light master', 'right', [720, 1220]),
      callout('BTN 48/61', 'Laser arm / off', 'right', [560, 1250], 'red'), callout('BTN 49/62', 'Jammer source on / off', 'right', [650, 1250]),
      callout('BTN 42–44', 'Heading set controls', 'right', [735, 1300]), callout('BTN 50–53/63–64', 'Autopilot roll and pitch modes', 'right', [580, 1320]),
    ],
  },
  hasProfile('Ava [R] Viper') && {
    type: 'hardware', file: '05-AVA-WARTHOG-GRIP', title: 'AVA BASE + WARTHOG GRIP', kicker: 'F-16 HOTAS STICK CONTROLS',
    images: [
      { href: assets.stickFront, x: 390, y: 230, width: 420, height: 950, opacity: 0.96 },
      { href: assets.stickRear, x: 510, y: 1060, width: 230, height: 330, opacity: 0.9 },
    ],
    callouts: [
      callout('BTN 2', 'Weapon release', 'left', [515, 390], 'red'), callout('BTN 3', 'NWS / A-R DISC / missile step', 'left', [760, 510], 'gold'),
      callout('BTN 7', 'TMS up', 'left', [480, 430]), callout('BTN 8', 'TMS right', 'left', [480, 430]),
      callout('BTN 9', 'TMS down', 'left', [480, 430]), callout('BTN 10', 'TMS left', 'left', [480, 430]),
      callout('BTN 11', 'DMS up', 'left', [600, 500]), callout('BTN 12', 'DMS right', 'right', [600, 500]),
      callout('BTN 13', 'DMS down', 'right', [600, 500]), callout('BTN 14', 'DMS left', 'right', [600, 500]),
      callout('BTN 15', 'CMS forward', 'right', [610, 1180]), callout('BTN 16', 'CMS right', 'right', [610, 1180]),
      callout('BTN 17', 'CMS aft', 'right', [610, 1180]), callout('BTN 18', 'CMS left', 'right', [610, 1180]),
    ],
    notes: [item('AXES', 'Rudder and thrust auto-assignments are intentionally removed from this profile.', 'red')],
  },
  hasProfile('WINCTRL CarrierAce PTO 2') && {
    type: 'hardware', file: '06-WINCTRL-PTO2', title: 'WINCTRL CARRIERACE PTO2', kicker: 'F-16 GROUND AND LANDING CONTROLS',
    images: [{ href: assets.pto2, x: 350, y: 390, width: 500, height: 760, opacity: 0.76 }], directMarkers: true,
    callouts: [
      callout('BTN 8', 'Landing / taxi lights switch up', 'left', [510, 690]), callout('BTN 9', 'Landing / taxi lights off', 'left', [510, 690]),
      callout('BTN 12', 'Taxi while held; release returns off', 'left', [535, 790]), callout('BTN 32', 'Arresting hook up', 'right', [710, 720], 'gold'),
      callout('BTN 34', 'Arresting hook down', 'right', [710, 720], 'gold'), callout('BTN 35', 'Landing gear up', 'right', [455, 510], 'gold'),
      callout('BTN 37', 'Landing gear down', 'right', [455, 510], 'gold'),
    ],
    notes: [item('OTHER', 'All other PTO2 controls are intentionally unbound in the F-16C profile.', 'red')],
  },
  hasProfile('WINCTRL ViperAce ICP') && {
    type: 'hardware', file: '07-WINCTRL-VIPERACE-ICP', title: 'WINCTRL VIPERACE ICP', kicker: 'DEVICE-SPECIFIC USB NUMBERING • DO NOT SUBSTITUTE GENERIC PROFILE',
    images: [{ href: assets.icp, x: 360, y: 380, width: 480, height: 720, opacity: 0.94 }],
    callouts: [
      callout('BTN 1/2', 'COM1 / COM2', 'left', [500, 655]), callout('BTN 3/4', 'IFF / LIST', 'left', [600, 655]),
      callout('BTN 5/6', 'A-A / A-G master modes', 'left', [705, 655]), callout('BTN 7–9/11–13/15–18', 'ICP keypad digits 1–9 and 0', 'left', [560, 800]),
      callout('BTN 10/14', 'Recall / enter', 'left', [680, 800]), callout('BTN 19/20', 'DED increment / decrement', 'left', [435, 970]),
      callout('BTN 22–25', 'DCS up / sequence / down / return', 'right', [540, 990]), callout('BTN 26–28', 'Drift cutout / norm / warn reset', 'right', [620, 1010]),
      callout('BTN 29–31', 'FLIR polarity / increment / decrement', 'right', [735, 790]), callout('BTN 32–34', 'FLIR gain / level / auto', 'right', [735, 980]),
      callout('JOY Y', 'HUD symbology intensity', 'right', [425, 735], 'gold'), callout('JOY X', 'Reticle depression', 'right', [790, 735], 'gold'),
      callout('JOY RY', 'Raster intensity', 'right', [425, 920]), callout('JOY RX', 'Raster contrast', 'right', [790, 920]),
    ],
    notes: [item('AXES', 'Pitch and roll are removed before the four knob assignments are applied.', 'red')],
  },
  {
    type: 'summary', file: '08-OPENKNEEBOARD-VAICOM', title: 'OPENKNEEBOARD + VAICOM PRO', kicker: 'TQS PUSH-TO-TALK BRIDGE • VR REFERENCE PAGES',
    items: [
      item('TAB', 'DCS Aircraft tab should discover F-16C_50', 'gold'), item('FOLDER', 'Fallback: add KNEEBOARD\\F-16C_50 as Folder tab'),
      item('AHK', 'Run dcs-TQS.ahk with AutoHotKey v2', 'red'), item('RESERVE', 'DCS BTN 1–5 must remain unassigned', 'red'),
      item('TX1', '5Joy1 • VHF AM • Ctrl+Alt+Shift+1'), item('TX2', '5Joy2 • UHF • Ctrl+Alt+Shift+2'),
      item('TX3', '5Joy3 • VHF FM • Ctrl+Alt+Shift+3'), item('TX4', '5Joy4 • AUTO • Ctrl+Alt+Shift+4'),
      item('TX5', '5Joy5 • Interphone • Ctrl+Alt+Shift+5'), item('VOICE', 'VAICOM PRO remains primary for radio commands'),
      item('NEXT', 'NEXT_PAGE.exe'), item('PREV', 'PREVIOUS_PAGE.exe'), item('NEXT TAB', 'NEXT_TAB.exe'), item('PREV TAB', 'PREVIOUS_TAB.exe'),
      item('PHRASES', 'Keep kneeboard phrases distinct from VAICOM', 'gold'), item('ORDER', 'Numeric filenames preserve page order'),
    ],
  },
].filter(Boolean);

for (let index = 0; index < pages.length; index += 1) {
  const page = pages[index];
  const svg = page.type === 'summary' ? summaryPage(page, index, pages.length) : hardwarePage(page, index, pages.length);
  writeFileSync(join(svgDir, `${page.file}.svg`), svg, 'utf8');
  await sharp(Buffer.from(svg)).png().toFile(join(pngDir, `${page.file}.png`));
}

console.log(`Generated ${pages.length} F-16C OpenKneeboard SVG and PNG pages for package ${version}.`);
