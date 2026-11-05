// Flutter web derlemesinde her ekrandaki her dokunulabilir öğeye basar ve sonucu kaydeder.
// Hedef ekran, adresten değil içerikten tanınır: go_router push geçişlerinde adresi değiştirmez.
// Kullanım: node scratch/audit/crawl_flutter.mjs [çıktı.json] [ekran-görüntüsü-klasörü]
import fs from 'fs';
import { openChrome, bootFlutter, sleep } from './lib/cdp.mjs';

const out = process.argv[2] || new URL('./baseline/flutter.json', import.meta.url).pathname;
const shots = process.argv[3];
const url = process.env.FLUTTER_URL || 'http://127.0.0.1:8092/';
const LAST_STEP = 33;

const c = await openChrome({ port: 9342 });
await bootFlutter(c, url);
let k = 0;
const go = async (n) => {
  // Önce başka bir ekrana gidilir: aynı rotada Flutter ekran durumunu korur, önceki seçim kalırdı.
  await c.ev(`location.hash='#/step/${n === 1 ? 2 : 1}?r=${++k}'`);
  await sleep(350);
  await c.ev(`location.hash='#/step/${n}?r=${++k}'`);
  await sleep(750);
  await c.ev('__f.sem()');
  await sleep(150);
};

const fingerprints = {};
const titles = {};
const enumC = {};
const inputs = {};
if (shots) fs.mkdirSync(shots, { recursive: true });
for (let n = 1; n <= LAST_STEP; n++) {
  await go(n);
  fingerprints[await c.ev('__f.fp()')] = n;
  titles[n] = await c.ev(`__f.texts().slice(0,4).join(' / ').slice(0,110)`);
  enumC[n] = await c.ev('__f.nodes().length');
  inputs[n] = await c.ev(`document.querySelectorAll('input,textarea').length`);
  if (shots) await c.screenshot(`${shots}/s${String(n).padStart(2, '0')}.png`);
}

const results = [];
for (let n = 1; n <= LAST_STEP; n++) {
  await go(n);
  for (let i = 0; i < enumC[n]; i++) {
    const info = await c.ev(`(()=>{const e=__f.nodes()[${i}];if(!e)return null;const b=e.getBoundingClientRect();return {t:__f.label(e),w:Math.round(b.width),h:Math.round(b.height),f:__f.fp(),u:location.hash}})()`);
    if (!info) { results.push({ s: n, i, t: '(kayboldu)' }); await go(n); continue; }
    await c.ev(`__f.nodes()[${i}].click()`);
    await sleep(1200); // Bazı düğmeler 900 ms bekleyip geçiş yapıyor (s22).
    await c.ev('__f.sem()');
    await sleep(100);
    const after = await c.ev('__f.fp()');
    const hash = await c.ev('location.hash');
    const rec = { s: n, i, t: info.t, w: info.w, h: info.h };
    if (after !== info.f) {
      rec.to = fingerprints[after] ?? `?${await c.ev(`__f.texts().slice(0,2).join(' / ').slice(0,60)`)}`;
    }
    if (hash !== info.u) rec.url = hash.replace(/[?]r=[0-9]+/, '');
    results.push(rec);
    // Her öğe temiz ekranda denensin.
    await go(n);
  }
  console.log(`ekran ${n} bitti`);
}
fs.writeFileSync(out, JSON.stringify({ titles, enum: enumC, inputs, results, errors: [...c.errors] }));
console.log(`Bitti: ${results.length} öğe -> ${out}`);
c.close();
process.exit(0);
