// HTML prototipte her ekrandaki her tıklanabilir öğeye basar ve sonucu kaydeder.
// Kullanım: node scratch/audit/crawl_prototype.mjs [TR|EN] [çıktı.json]
// Güvenlik: sayfanın yaptığı tüm POST istekleri engellenir, sandbox'ta ödeme başlatılamaz.
import fs from 'fs';
import { openChrome, sleep } from './lib/cdp.mjs';

const lang = (process.argv[2] || 'TR').toUpperCase();
const out = process.argv[3] || new URL(`./baseline/prototype_${lang}.json`, import.meta.url).pathname;
const base = process.env.PROTOTYPE_URL || 'http://localhost:8090/preview/index.html';

function crawl(langCode) {
  const C = (window.__crawl = { results: [], done: false, step: 0, err: null, enum: {}, blockedPosts: [] });
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  const frame = document.getElementById('screen-frame');
  let nav = null;
  window.addEventListener('message', (e) => { if (e.data && e.data.type === 'NAVIGATE') nav = { to: e.data.to, label: e.data.label }; }, true);
  const stepOf = (sid) => (specs[sid] ? specs[sid].step_num : null);
  const clean = () => {
    Object.keys(sessionStorage).filter((k) => k.startsWith('bitadilat_')).forEach((k) => sessionStorage.removeItem(k));
    sessionStorage.setItem('bitadilat_lang', langCode);
  };
  const guard = () => {
    const win = frame.contentWindow;
    const real = win.fetch;
    win.fetch = (url, opt) => {
      if (opt && opt.method && opt.method !== 'GET') {
        C.blockedPosts.push({ step: C.step, url: String(url) });
        return Promise.reject(new Error('audit: yazma isteği engellendi'));
      }
      return real.call(win, url, opt);
    };
    win.alert = () => {};
    win.confirm = () => false;
  };
  const load = (sid) => new Promise((res) => {
    clean();
    let done = false;
    const fin = () => {
      if (done) return;
      done = true;
      frame.removeEventListener('load', fin);
      try { guard(); } catch (e) { /* çerçeve başka origin'de */ }
      setTimeout(res, 300);
    };
    frame.addEventListener('load', fin);
    updateView(sid);
    setTimeout(fin, 6000);
  });
  const list = (doc, win) => {
    const set = new Set(doc.querySelectorAll('button,a,[role=button],[onclick],input[type=submit],input[type=button],input[type=radio],input[type=checkbox],select,label'));
    doc.querySelectorAll('body *').forEach((el) => {
      if (win.getComputedStyle(el).cursor === 'pointer' && !el.closest('button,a,label')
        && !(el.parentElement && win.getComputedStyle(el.parentElement).cursor === 'pointer')) set.add(el);
    });
    return [...set].filter((el) => {
      const r = el.getBoundingClientRect();
      return r.width > 0 && r.height > 0 && !el.closest('#bitadilat-toast-container');
    });
  };
  const txt = (el) => (el.innerText || el.getAttribute('aria-label') || el.value || el.getAttribute('placeholder') || '').replace(/\s+/g, ' ').trim().slice(0, 60);
  const hash = (doc) => doc.body.innerText.replace(/\d/g, '').length + ':' + doc.querySelectorAll('[class]').length;

  return (async () => {
    for (const sid of flowOrder) {
      C.step = stepOf(sid);
      await load(sid);
      const total = list(frame.contentDocument, frame.contentWindow).length;
      C.enum[C.step] = total;
      for (let i = 0; i < total; i++) {
        const doc = frame.contentDocument;
        const win = frame.contentWindow;
        const el = list(doc, win)[i];
        if (!el) { C.results.push({ s: C.step, i, t: '(kayboldu)', r: 'missing' }); await load(sid); continue; }
        const b = el.getBoundingClientRect();
        const rec = { s: C.step, i, t: txt(el) || el.tagName.toLowerCase(), w: Math.round(b.width), h: Math.round(b.height), dis: el.disabled || undefined };
        if (rec.t === 'EN' || rec.t === 'TR') { rec.r = 'dil'; C.results.push(rec); continue; }
        if (el.tagName === 'A' && /^(https?:|tel:|mailto:)/.test(el.getAttribute('href') || '')) { rec.r = 'dis-baglanti'; C.results.push(rec); continue; }
        if (el.tagName === 'INPUT' && el.type === 'file') { rec.r = 'dosya'; C.results.push(rec); continue; }
        if (el.tagName === 'SELECT') { rec.r = 'secim'; C.results.push(rec); continue; }
        nav = null;
        const h0 = hash(doc);
        const p0 = win.location.pathname;
        try { el.click(); } catch (e) { rec.clickErr = String(e); }
        await sleep(240);
        let toast = null;
        let p1 = 'cross';
        let h1 = '';
        try {
          const c = frame.contentDocument.getElementById('bitadilat-toast-container');
          toast = c ? c.innerText.replace(/\s+/g, ' ').trim().slice(0, 90) : null;
          p1 = frame.contentWindow.location.pathname;
          h1 = hash(frame.contentDocument);
        } catch (e) { /* çerçeve başka origin'de */ }
        if (nav) rec.to = stepOf(nav.to);
        if (p1 !== p0 && !nav) rec.frameNav = p1.split('/').pop().slice(0, 12);
        if (toast) rec.toast = toast;
        rec.dom = h1 !== h0;
        C.results.push(rec);
        // Her öğe temiz ekranda denensin: önceki tıklama (ör. test kartı) sonrakini etkilemesin.
        await load(sid);
      }
    }
    C.done = true;
  })().catch((e) => { C.err = String(e) + ' ' + (e.stack || ''); });
}

const c = await openChrome({ port: lang === 'EN' ? 9341 : 9340, width: 1280, height: 900, mobile: false });
await c.goto(base);
await sleep(2500);
await c.ev(`(${crawl.toString()})(${JSON.stringify(lang)}); true`);
for (;;) {
  await sleep(5000);
  const st = await c.ev(`({step:__crawl.step,n:__crawl.results.length,done:__crawl.done,err:__crawl.err})`);
  console.log(`adım ${st.step}, ${st.n} öğe`);
  if (st.err) throw new Error(st.err);
  if (st.done) break;
}
const data = await c.ev(`({lang:${JSON.stringify(lang)},enum:__crawl.enum,blockedPosts:__crawl.blockedPosts,results:__crawl.results})`);
data.errors = [...c.errors];
fs.writeFileSync(out, JSON.stringify(data, null, 0));
console.log(`Bitti: ${data.results.length} öğe, ${data.blockedPosts.length} engellenen yazma isteği -> ${out}`);
c.close();
process.exit(0);
