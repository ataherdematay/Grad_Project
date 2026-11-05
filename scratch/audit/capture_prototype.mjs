// Prototipin tüm ekranlarını gerçek boyutunda görüntüler; JS hatası, yatay taşma, küçük dokunma alanı
// ve kırık görsel ölçer. Kullanım: node scratch/audit/capture_prototype.mjs [çıktı-klasörü]
import fs from 'fs';
import os from 'os';
import path from 'path';
import { openChrome, sleep } from './lib/cdp.mjs';

const dir = process.argv[2] || fs.mkdtempSync(path.join(os.tmpdir(), 'bitadilat-shots-'));
const base = process.env.PROTOTYPE_BASE || 'http://localhost:8090/preview/screens';
const map = JSON.parse(fs.readFileSync(new URL('../../screens_map.json', import.meta.url), 'utf8'));
fs.mkdirSync(dir, { recursive: true });

const MEASURE = `(()=>{const de=document.documentElement;const small=[];
document.querySelectorAll('button,a,input,select,[role=button]').forEach(e=>{const r=e.getBoundingClientRect();
 if(r.width>0&&r.height>0&&(r.height<44||r.width<44)&&!['checkbox','radio','hidden'].includes(e.type))small.push((e.innerText||e.getAttribute('aria-label')||e.tagName).replace(/\\s+/g,' ').trim().slice(0,24)+' '+Math.round(r.width)+'x'+Math.round(r.height))});
return {overflowX:de.scrollWidth>de.clientWidth+1,small,brokenImages:[...document.images].filter(i=>i.complete&&i.naturalWidth===0).length,
 prefilled:[...document.querySelectorAll('input,textarea')].filter(i=>i.value&&!['radio','checkbox','hidden','file'].includes(i.type)).map(i=>i.value.slice(0,28))}})()`;

const c = await openChrome({ port: 9344 });
const report = [];
for (const s of map) {
  const desktop = s.device !== 'MOBILE';
  await c.viewport(desktop ? 1280 : 390, desktop ? 800 : 844, !desktop);
  c.errors.clear();
  await c.goto(`${base}/${s.id}.html`);
  await sleep(1500);
  const m = await c.ev(MEASURE);
  await c.screenshot(path.join(dir, `p${String(s.step_num).padStart(2, '0')}.png`));
  report.push({ step: s.step_num, title: s.title, device: s.device, ...m, errors: [...c.errors] });
}
fs.writeFileSync(path.join(dir, 'metrics.json'), JSON.stringify(report, null, 1));
console.log(`Bitti: ${report.length} ekran -> ${dir}`);
c.close();
process.exit(0);
