// Bir tıklama sonucunun özetini yazar. Kullanım: node scratch/audit/summarize.mjs baseline/prototype_TR.json
import fs from 'fs';

const d = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const R = d.results;
const nav = R.filter((r) => Number.isInteger(r.to));
const localChange = R.filter((r) => typeof r.to === 'string');
const edges = {};
nav.forEach((r) => { if (r.to !== r.s) (edges[r.s] ||= new Set()).add(r.to); });
const seen = new Set([1]);
const queue = [1];
while (queue.length) for (const t of edges[queue.shift()] || []) if (!seen.has(t)) { seen.add(t); queue.push(t); }
const screens = Object.keys(d.enum).map(Number);
console.log(JSON.stringify({
  ogeler: R.length,
  gecis: nav.length,
  yerelDegisim: localChange.length,
  yalnizToast: R.filter((r) => r.to == null && r.toast).length,
  ekranDegisikligi: R.filter((r) => r.to == null && !r.toast && r.dom).length,
  gorunurEtkisiz: R.filter((r) => r.to == null && !r.toast && !r.dom && !r.r && !r.dis).length,
  engellenenYazma: d.blockedPosts?.length,
  tiklamaylaUlasilamayan: screens.filter((s) => !seen.has(s)),
  jsHatalari: d.errors,
}, null, 1));
