import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { basename, join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');

test('build:kneeboard mirrors generated SVGs into the configured aircraft PNG folder', () => {
  const result = spawnSync('npm', ['run', 'build:kneeboard'], {
    cwd: root,
    encoding: 'utf8',
    shell: true,
    env: process.env,
  });
  assert.equal(result.status, 0, result.stderr || result.stdout);

  const config = JSON.parse(readFileSync(join(root, 'config', 'kneeboard.json'), 'utf8'));
  const svgDir = join(root, 'kneeboard', 'source');
  const pngDir = join(root, 'kneeboard', config.aircraft);

  assert.ok(existsSync(svgDir), 'expected the generated SVG source folder');
  assert.ok(
    existsSync(pngDir),
    `expected PNG output in the exact aircraft folder kneeboard/${config.aircraft}`,
  );

  const svgPages = readdirSync(svgDir)
    .filter((name) => name.endsWith('.svg'))
    .map((name) => basename(name, '.svg'))
    .sort();
  const pngPages = readdirSync(pngDir)
    .filter((name) => name.endsWith('.png'))
    .map((name) => basename(name, '.png'))
    .sort();

  assert.ok(svgPages.length > 0, 'expected at least one generated kneeboard page');
  assert.deepEqual(
    pngPages,
    svgPages,
    'aircraft PNG folder must contain exactly the current generated page set',
  );
});
