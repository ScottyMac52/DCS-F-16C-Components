import { mkdirSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import sharp from 'sharp';

const root = resolve(import.meta.dirname, '..');
const commonRoot = resolve(process.env.DCS_COMMON_ROOT ?? join(root, '.dcs-common'));
const { renderSharedHardwarePage } = await import(pathToFileURL(join(commonRoot, 'scripts/shared-hardware-consumer.mjs')));
const svgDir = join(root, 'kneeboard/source');
const pngDir = join(root, 'kneeboard/F-16C_50');
mkdirSync(svgDir, { recursive: true }); mkdirSync(pngDir, { recursive: true });
const mfdIds = ['mfd-osb-t1','mfd-osb-t2','mfd-osb-t3','mfd-osb-t4','mfd-osb-t5','mfd-osb-r1','mfd-osb-r2','mfd-osb-r3','mfd-osb-r4','mfd-osb-r5','mfd-osb-b5','mfd-osb-b4','mfd-osb-b3','mfd-osb-b2','mfd-osb-b1','mfd-osb-l5','mfd-osb-l4','mfd-osb-l3','mfd-osb-l2','mfd-osb-l1','mfd-rocker-gain','mfd-rocker-lvl','mfd-rocker-con-up','mfd-rocker-con-down','mfd-rocker-brt-up','mfd-rocker-brt-down','mfd-rocker-sym','mfd-rocker-int'];
const mfdLabels = (side) => Object.fromEntries(mfdIds.map((id, index) => [id, index < 20 ? `${side} MFD OSB ${index + 1}` : ['SYM increase','SYM decrease','CON increase','CON decrease','BRT increase','BRT decrease','GAIN increase','GAIN decrease'][index - 20]]));
const pages = [
  { file:'02-LEFT-MFD', deviceId:'tm-mfd', title:'COUGAR MFD 1 • LEFT MFD', kicker:'ONE-TO-ONE LEFT BEZEL', labels:mfdLabels('Left') },
  { file:'03-RIGHT-MFD', deviceId:'tm-mfd', title:'COUGAR MFD 2 • RIGHT MFD', kicker:'ONE-TO-ONE RIGHT BEZEL', labels:mfdLabels('Right') },
  { file:'05-AVA-WARTHOG-GRIP', deviceId:'ava-base-f16c', title:'AVA BASE + WARTHOG GRIP', kicker:'F-16 HOTAS STICK CONTROLS', labels:['BTN 2: Weapon release','BTN 3: NWS / A-R DISC','BTN 7–10: TMS','BTN 11–14: DMS','BTN 15–18: CMS'] },
  { file:'06-WINCTRL-PTO2', deviceId:'winctrl-pto2', title:'WINCTRL CARRIERACE PTO2', kicker:'F-16 GROUND AND LANDING CONTROLS', labels:['BTN 35/37: Landing gear','','','','','BTN 32/34: Arresting hook','','BTN 8/9: Landing lights','BTN 12: Taxi while held'] },
  { file:'07-WINCTRL-VIPERACE-ICP', deviceId:'winctrl-icp', title:'WINCTRL VIPERACE ICP', kicker:'DEVICE-SPECIFIC USB NUMBERING', labels:['BTN 1/2: COM1 / COM2','BTN 3/4: IFF / LIST','BTN 5/6: A-A / A-G','BTN 7–18: Keypad','BTN 19/20: DED rocker','BTN 22–25: DCS switch','BTN 26–34: FLIR controls','JOY axes: four knobs'] },
];
for (const spec of pages) {
  const number = Number(spec.file.slice(0, 2));
  const { svg } = renderSharedHardwarePage({ ...spec, commonRoot, footer:`F-16C_50 • shared DCS-Common hardware template • ${number} / 8` });
  writeFileSync(join(svgDir, `${spec.file}.svg`), svg);
  await sharp(Buffer.from(svg)).png().toFile(join(pngDir, `${spec.file}.png`));
}
