import { createHash } from 'node:crypto';
import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = resolve(scriptDir, '..');
const pngDir = join(root, 'kneeboard', 'F-16C_50');
const svgDir = join(root, 'kneeboard', 'source');
const assetDir = join(root, 'kneeboard', 'assets', 'source');
const profileDir = join(root, 'src', 'Config', 'Input', 'F-16C_50', 'joystick');

const pages = [
  '01-CONTROL-OVERVIEW',
  '02-LEFT-MFD',
  '03-RIGHT-MFD',
  '04-VIPER-TQS',
  '05-AVA-WARTHOG-GRIP',
  '06-WINCTRL-PTO2',
  '07-WINCTRL-VIPERACE-ICP',
  '08-OPENKNEEBOARD-VAICOM',
];

const expectedAssets = [
  'cougar-mfd-clean.png',
  'cougar-mfd-template.png',
  'pto2-clean.png',
  'pto2-template.svg',
  'viper-panel-controls.png',
  'viper-panel-map-source.png',
  'viper-tqs-handle-controls.png',
  'viper-tqs-handle-map-source.png',
  'viperace-icp-clean.png',
  'viperace-icp-template.svg',
  'warthog-grip-front.png',
  'warthog-grip-rear.png',
  'warthog-grip-template.svg',
];

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function hashFile(path) {
  return createHash('sha256').update(readFileSync(path)).digest('hex');
}

function generatedHashes() {
  return Object.fromEntries(pages.flatMap((page) => [
    [`${page}.svg`, hashFile(join(svgDir, `${page}.svg`))],
    [`${page}.png`, hashFile(join(pngDir, `${page}.png`))],
  ]));
}

function profile(nameFragment) {
  const matches = readdirSync(profileDir).filter((name) => name.includes(nameFragment));
  assert(matches.length === 1, `Expected one profile matching ${nameFragment}; found ${matches.length}.`);
  return readFileSync(join(profileDir, matches[0]), 'utf8');
}

function expandButtonLabel(label) {
  const buttons = [];
  for (const part of label.replaceAll('–', '-').split('/')) {
    const range = part.match(/^(\d+)-(\d+)$/);
    if (range) {
      for (let button = Number(range[1]); button <= Number(range[2]); button += 1) buttons.push(button);
    } else if (/^\d+$/.test(part)) buttons.push(Number(part));
  }
  return buttons;
}

function assertProfileButtons(nameFragment, page) {
  const lua = profile(nameFragment);
  const mappedButtons = new Set([...lua.matchAll(/JOY_BTN(\d+)/g)].map((match) => Number(match[1])));
  assert(mappedButtons.size > 0, `${page} profile has no mapped buttons.`);
}

const pngNames = readdirSync(pngDir).filter((name) => name.endsWith('.png')).sort();
const svgNames = readdirSync(svgDir).filter((name) => name.endsWith('.svg')).sort();
assert(JSON.stringify(pngNames) === JSON.stringify(pages.map((page) => `${page}.png`)), 'Unexpected kneeboard PNG filenames or page count.');
assert(JSON.stringify(svgNames) === JSON.stringify(pages.map((page) => `${page}.svg`)), 'Unexpected kneeboard SVG filenames or page count.');

for (const page of pages) {
  const png = join(pngDir, `${page}.png`);
  const svg = join(svgDir, `${page}.svg`);
  const metadata = await sharp(png).metadata();
  assert(metadata.width === 1200 && metadata.height === 1600, `${page}.png must be 1200 x 1600.`);
  const source = readFileSync(svg, 'utf8');
  const resources = source
    .replaceAll('http://www.w3.org/2000/svg', '')
    .replaceAll('http://www.w3.org/1999/xlink', '');
  assert(!/https?:\/\//i.test(resources), `${page}.svg contains a network dependency.`);
  assert(source.includes(`${pages.indexOf(page) + 1} / 8`), `${page}.svg has the wrong page number.`);
}

const sourceAssetNames = readdirSync(assetDir);
for (const asset of expectedAssets) assert(sourceAssetNames.includes(asset), `Missing source asset: ${asset}`);
const licenseNames = readdirSync(join(assetDir, 'licenses'));
assert(licenseNames.includes('bindulator-templates-GPL-2.0-or-later.txt'), 'The Bindulator license is missing.');
assert(licenseNames.includes('joystick-diagrams-GPL-2.0.txt'), 'The Joystick Diagrams license is missing.');

const transparentAssets = ['viper-panel-controls.png', 'viper-tqs-handle-controls.png', 'viperace-icp-clean.png', 'warthog-grip-front.png', 'warthog-grip-rear.png'];
for (const asset of transparentAssets) {
  const metadata = await sharp(join(assetDir, asset)).metadata();
  assert(metadata.hasAlpha, `${asset} must retain a transparent background.`);
}

assertProfileButtons('F16 MFD 1', '02-LEFT-MFD');
assertProfileButtons('F16 MFD 2', '03-RIGHT-MFD');
assertProfileButtons('Viper TQS', '04-VIPER-TQS');
assertProfileButtons('Ava [R] Viper', '05-AVA-WARTHOG-GRIP');
assertProfileButtons('WINCTRL CarrierAce PTO 2', '06-WINCTRL-PTO2');
assertProfileButtons('WINCTRL ViperAce ICP', '07-WINCTRL-VIPERACE-ICP');

const requiredText = {
  '01-CONTROL-OVERVIEW': ['MFD 3', 'KNEEBOARD\\F-16C_50', 'Back up F-16C_50'],
  '02-LEFT-MFD': ['Shared DCS-Common device: tm-mfd'],
  '03-RIGHT-MFD': ['Shared DCS-Common device: tm-mfd'],
  '04-VIPER-TQS': ['BTN 1–5', 'Reserved for VAICOM AHK', 'Radar cursor X / Y', 'CMDS program selector', 'Autopilot roll and pitch modes'],
  '05-AVA-WARTHOG-GRIP': ['Shared DCS-Common device: ava-base-f16c'],
  '06-WINCTRL-PTO2': ['Shared DCS-Common device: winctrl-pto2'],
  '07-WINCTRL-VIPERACE-ICP': ['Shared DCS-Common device: winctrl-icp'],
  '08-OPENKNEEBOARD-VAICOM': ['dcs-TQS.ahk', '5Joy1', 'TX1', '5Joy5', 'TX5', 'NEXT_PAGE.exe'],
};
for (const [page, labels] of Object.entries(requiredText)) {
  const source = readFileSync(join(svgDir, `${page}.svg`), 'utf8');
  const visibleText = source.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ');
  for (const label of labels) assert(visibleText.includes(label), `${page} is missing required text: ${label}`);
}

const before = generatedHashes();
const build = spawnSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['run', 'build:kneeboard'], { cwd: root, encoding: 'utf8', env: process.env });
assert(build.status === 0, `Deterministic rebuild failed:\n${build.stdout}\n${build.stderr}`);
const after = generatedHashes();
assert(JSON.stringify(after) === JSON.stringify(before), 'Kneeboard output changed across identical builds.');

console.log('Kneeboard validation passed: 8 deterministic pages, mappings, dimensions, and offline assets verified.');
