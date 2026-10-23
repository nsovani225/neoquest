// Downloads the Figma images listed in figma-assets.json into assets/figma/.
// Run with: npm run fetch-assets   (add --force to re-download everything)
import { readFile, writeFile, mkdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const outDir = path.join(root, 'assets', 'figma');
const force = process.argv.includes('--force');
const { assets } = JSON.parse(await readFile(path.join(root, 'scripts', 'figma-assets.json'), 'utf8'));

await mkdir(outDir, { recursive: true });

let ok = 0;
const failed = [];
for (const [name, url] of Object.entries(assets)) {
  const dest = path.join(outDir, name);
  if (!force) {
    try {
      if ((await stat(dest)).size > 0) { ok++; continue; }
    } catch {}
  }
  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const buf = Buffer.from(await res.arrayBuffer());
    if (buf.length === 0) throw new Error('empty file');
    await writeFile(dest, buf);
    ok++;
    console.log(`✓ ${name}`);
  } catch (err) {
    failed.push(`${name} (${err.message})`);
  }
}

console.log(`\n${ok}/${Object.keys(assets).length} Figma images in assets/figma/`);
if (failed.length) {
  console.warn('Could not download:\n  ' + failed.join('\n  '));
  console.warn('The Figma links expire after a while. See README.md → "Refreshing images".');
  // Don't break `npm install`; the app needs these files before it can start.
  process.exitCode = process.argv.includes('--strict') ? 1 : 0;
}
