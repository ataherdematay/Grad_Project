// Headless Chrome'u DevTools protokolüyle süren küçük yardımcı. Ek paket gerektirmez (Node 22+).
import { spawn } from 'child_process';
import fs from 'fs';
import os from 'os';
import path from 'path';

const CHROME = process.env.CHROME_PATH || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

export async function openChrome({ port, width = 390, height = 844, mobile = true }) {
  const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'bitadilat-audit-'));
  const chrome = spawn(CHROME, ['--headless=new', `--remote-debugging-port=${port}`, '--no-first-run',
    `--user-data-dir=${profile}`, `--window-size=${width},${height}`, 'about:blank'], { stdio: 'ignore' });

  let tab;
  for (let i = 0; i < 60 && !tab; i++) {
    try {
      tab = (await (await fetch(`http://127.0.0.1:${port}/json`)).json()).find((t) => t.type === 'page');
    } catch { /* Chrome henüz açılmadı */ }
    if (!tab) await sleep(250);
  }
  if (!tab) throw new Error('Chrome açılamadı. CHROME_PATH değişkenini kontrol edin.');

  const ws = new WebSocket(tab.webSocketDebuggerUrl);
  await new Promise((r) => { ws.onopen = r; });
  let id = 0;
  const pending = new Map();
  const errors = new Set();
  ws.onmessage = (e) => {
    const m = JSON.parse(e.data);
    if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
    if (m.method === 'Runtime.exceptionThrown') {
      const d = m.params.exceptionDetails;
      errors.add((d.exception?.description || d.text || '').split('\n')[0].slice(0, 180));
    }
  };
  const send = (method, params = {}) => new Promise((r) => {
    const i = ++id;
    pending.set(i, r);
    ws.send(JSON.stringify({ id: i, method, params }));
  });
  const ev = async (expression) => {
    const r = await send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true });
    if (r.result?.exceptionDetails) throw new Error(JSON.stringify(r.result.exceptionDetails).slice(0, 300));
    return r.result?.result?.value;
  };
  await send('Page.enable');
  await send('Runtime.enable');
  const viewport = (w, h, m) => send('Emulation.setDeviceMetricsOverride', { width: w, height: h, deviceScaleFactor: 1, mobile: m });
  await viewport(width, height, mobile);

  return {
    send, ev, errors, viewport,
    goto: (url) => send('Page.navigate', { url }),
    screenshot: async (file) => {
      const shot = await send('Page.captureScreenshot', { format: 'png' });
      fs.writeFileSync(file, Buffer.from(shot.result.data, 'base64'));
    },
    close: () => {
      chrome.kill();
      setTimeout(() => fs.rmSync(profile, { recursive: true, force: true }), 500);
    },
  };
}

// Flutter'ın erişilebilirlik katmanını okuyan sayfa içi yardımcılar.
export const FLUTTER_HELPERS = `window.__f={
 nodes:()=>[...document.querySelectorAll('[flt-tappable]')].filter(n=>{const r=n.getBoundingClientRect();return r.width>0&&r.height>0}),
 label:n=>(n.getAttribute('aria-label')||n.innerText||'').replace(/\\s+/g,' ').trim().slice(0,70),
 texts:()=>[...document.querySelectorAll('flt-semantics')].filter(n=>!n.querySelector('flt-semantics')).map(n=>(n.getAttribute('aria-label')||n.innerText||'').replace(/\\s+/g,' ').trim()).filter(Boolean),
 fp:()=>__f.texts().join('|').replace(/[0-9]/g,'').slice(0,240),
 sem:async()=>{for(let a=0;a<30;a++){if(document.querySelectorAll('flt-semantics').length>1)return true;const p=document.querySelector('flt-semantics-placeholder');if(p)p.click();await new Promise(r=>setTimeout(r,200))}return false}
};true`;

export async function bootFlutter(c, url) {
  await c.goto(url);
  for (let i = 0; i < 60; i++) {
    if (await c.ev(`!!document.querySelector('flutter-view')`)) break;
    await sleep(500);
  }
  await sleep(1500);
  await c.ev(FLUTTER_HELPERS);
  if (!(await c.ev('__f.sem()'))) throw new Error('Flutter erişilebilirlik katmanı açılamadı.');
}
