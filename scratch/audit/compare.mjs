// İki tıklama sonucunu karşılaştırır. Düzeltmeden sonra neyin değiştiğini gösterir.
// Kullanım: node scratch/audit/compare.mjs baseline/prototype_TR.json yeni.json
import fs from 'fs';

const [a, b] = process.argv.slice(2).map((f) => JSON.parse(fs.readFileSync(f, 'utf8')));
const effect = (r) => (r.to != null ? `→${r.to}` : r.toast ? 'toast' : r.dom ? 'ekran' : r.r || 'etkisiz');
const key = (r) => `${r.s}|${r.t}`;
const before = new Map(a.results.map((r) => [key(r), r]));
const after = new Map(b.results.map((r) => [key(r), r]));
const changed = [];
for (const [k, r] of after) {
  const old = before.get(k);
  if (!old) changed.push(`YENİ    adım ${r.s}: ${r.t} ${effect(r)}`);
  else if (effect(old) !== effect(r)) changed.push(`DEĞİŞTİ adım ${r.s}: ${r.t} ${effect(old)} -> ${effect(r)}`);
}
for (const [k, r] of before) if (!after.has(k)) changed.push(`SİLİNDİ adım ${r.s}: ${r.t} ${effect(r)}`);
console.log(changed.length ? changed.join('\n') : 'Fark yok.');
