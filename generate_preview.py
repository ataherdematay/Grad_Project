import os, json

with open('/Users/ata/Documents/antigravity/BiTadilat/screens_map.json') as f:
    screens_list = json.load(f)

flows = {
    '1. Müşteri Giriş & Onboarding': [
        ('0c06b06e422b40daacbc0b8e6e8fb7bf', 'Hoş Geldiniz & Rol Seçimi (SCR-01)', 'MOBILE'),
        ('fbbe0f405e1f4531a14dcdd6b1c5736a', 'Telefon Doğrulama', 'MOBILE'),
        ('42c148a1fb25400ca549481fa6abe01f', 'SMS Doğrulama Kodu', 'MOBILE')
    ],
    '2. Müşteri Talep Sihirbazı (4 Adım)': [
        ('cc1f55661a1a4036a890b43d9f15596a', 'Müşteri Ana Sayfası (Yeni Kullanıcı)', 'MOBILE'),
        ('44c003fee81d4a188f187608554efdd5', 'Yeni Talep — Adım 1 / 4: Hizmet & Öncelik (SCR-02)', 'MOBILE'),
        ('b3c3c2845017451fb1b85b89f04fd4b8', 'Yeni Talep — Adım 2 / 4: Konum & İş Detayı', 'MOBILE'),
        ('585d649f4ea046ffa70e4cb481ddd030', 'Yeni Talep — Adım 3 / 4: Fotoğraflar & Ek Bilgi', 'MOBILE'),
        ('a0949c91cbe34557b16273c8e91d067a', 'Yeni Talep — Adım 4 / 4: Talebi Gözden Geçir', 'MOBILE')
    ],
    '3. Teklif Karşılaştırma & Randevu': [
        ('94a730cef5374f2ab9632d9acf0d7e19', 'Talep Yayınlandı — Teklif Bekleniyor', 'MOBILE'),
        ('994e3b4ffce942ce8778f7a6cfaa42c0', 'Gelen Teklifler Listesi (SCR-04)', 'MOBILE'),
        ('ea7af2d7298b4b6cb24e4603935503f0', 'Teklif Detayı & Kapsam', 'MOBILE'),
        ('1fc70722168942c4a1933cd9c641ad68', 'Teklifleri Karşılaştır (Matris)', 'MOBILE'),
        ('98cd20d6ab4e4f8fbc29bc462ce55cca', 'Hizmet Profesyoneli Profili (SCR-05)', 'MOBILE'),
        ('58f9993b5f444ff3a9f9361cb8d3b731', 'Teklif Kabul Onayı (Güvence Havuzu)', 'MOBILE'),
        ('7c6ec3a02d3347a997a3fc5b1a2c91d0', 'Randevu Zamanı Seç (SCR-06)', 'MOBILE'),
        ('3bd2afe80ced4d2498ec9f16c7099326', 'Randevu Talebi İletildi', 'MOBILE')
    ],
    '4. Aktif İş, Mesajlaşma, Teslim & Şikayet': [
        ('f3e7de808fdb49c18e3c5d430cb72528', 'İş Alanı — Randevu Onaylandı', 'MOBILE'),
        ('c9aa92f5a4e04897952d05f30c2aef10', 'Usta ile Mesajlaşma — Mavi Hat Tesisat (SCR-07)', 'MOBILE'),
        ('b89d998c02d34e67b8e8f34334f87f02', 'İş Aşamaları ve İlerleme Takibi (SCR-08)', 'MOBILE'),
        ('6acc9307352f497ca6bd878d628c6a1a', 'Randevu İptal ve Değişiklik Talebi (SCR-09)', 'MOBILE'),
        ('d485263b3ae244a9b35500665b5c759b', 'İş Tamamlama ve Teslim Onayı (SCR-10)', 'MOBILE'),
        ('db8a1b368a7749cbb5fd6cf497f34de6', 'Hizmet Değerlendirme ve Puanlama (SCR-11)', 'MOBILE'),
        ('488f3698f93c454099ca2382585aeb66', 'Şikayet ve Uyuşmazlık Bildirimi (SCR-12)', 'MOBILE'),
        ('3bb4b954e5224b0097b2bee12be9bcbf', 'Şikayet İletildi ve Durum Takibi (SCR-13)', 'MOBILE')
    ],
    '5. Hizmet Profesyoneli (Usta Pro Flow)': [
        ('11b9cb02877746d580c5484512d0928f', 'Usta Eşleşen Talepler Akışı (SCR-14)', 'MOBILE'),
        ('b9086f1030784def8eb267fd9110addd', 'Usta Yapılandırılmış Teklif Hazırlama (SCR-15)', 'MOBILE'),
        ('82f9d783b88b40ec8ca6260566c0f5cb', 'Usta Teklif Gönderildi Onayı (SCR-16)', 'MOBILE'),
        ('fc6f0f8e9b724365a5a0f124617dbe7a', 'Usta Profil ve Müsaitlik Yönetimi (SCR-17)', 'MOBILE'),
        ('8ba8c346d11c46f39163fd6ebf06dae1', 'Usta İş Yürütme ve Aşama Yönetimi (SCR-18)', 'MOBILE')
    ],
    '6. Yönetici Portalı & Tanıtım Web': [
        ('612429fdea1b42a1bf9e628883f7e58f', 'Yönetici Web Portalı — Belge İnceleme (SCR-19)', 'DESKTOP'),
        ('cb00d67723e34ec990786a82d25c77ca', 'Yönetici Web Portalı — Şikayet Merkezi (SCR-20)', 'DESKTOP'),
        ('5ce8968e2703443ca129c0e7c9e9d145', 'Yönetici Web Portalı — Hesap Yönetimi (SCR-21)', 'DESKTOP'),
        ('164cd33666284338b929a8325dc5ea20', 'BiTadilat Tanıtım ve Karşılama Sitesi (SCR-22)', 'DESKTOP')
    ]
}

options_html = ''
all_screens_dict = {}

for gname, items in flows.items():
    options_html += f'<optgroup label="{gname}">\n'
    for sid, title, dev in items:
        all_screens_dict[sid] = {'title': title, 'device': dev, 'flow': gname}
        options_html += f'  <option value="{sid}" data-device="{dev}">[{sid[:6]}] {title}</option>\n'
    options_html += '</optgroup>\n'

screens_data_json = json.dumps(all_screens_dict, ensure_ascii=False)

html_content = f'''<!DOCTYPE html>
<html lang="tr" class="h-full bg-[#0B1E26]">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BiTadilat — Canlı Prototip & Bağlantılı Önizleme Simülatörü</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    body {{
      font-family: 'Manrope', sans-serif;
    }}
    .phone-shadow {{
      box-shadow: 0 25px 60px -15px rgba(0, 0, 0, 0.7), 0 0 0 12px #1E293B, 0 0 0 14px #0F172A;
    }}
    .desktop-shadow {{
      box-shadow: 0 25px 60px -15px rgba(0, 0, 0, 0.7), 0 0 0 1px rgba(255, 255, 255, 0.1);
    }}
    iframe {{
      border: none;
      width: 100%;
      height: 100%;
      background: #F7F8F6;
    }}
  </style>
</head>
<body class="h-full flex flex-col text-slate-100 overflow-hidden select-none">

  <!-- TOP HEADER / CONTROL BAR -->
  <header class="h-16 bg-[#0E2833] border-b border-slate-700/60 px-5 flex items-center justify-between shrink-0 shadow-lg z-30">
    <!-- App Logo & Badge -->
    <div class="flex items-center gap-3.5">
      <div class="w-10 h-10 rounded-xl bg-[#0F4C5C] flex items-center justify-center text-white font-bold text-lg shadow-sm border border-[#1a657a]">
        <span class="material-symbols-outlined text-[24px]">handyman</span>
      </div>
      <div>
        <div class="flex items-center gap-2">
          <span class="font-bold tracking-tight text-[17px] text-white">BiTadilat</span>
          <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-[#107A5B]/30 text-[#4ADE80] border border-[#107A5B]/50">33 Ekran Bağlantılı</span>
        </div>
        <p class="text-[11px] text-slate-400 font-medium">Google Stitch Prototip ve Canlı Uygulama Test Alanı</p>
      </div>
    </div>

    <!-- Center Navigation & Screen Selector -->
    <div class="flex items-center gap-3 max-w-2xl w-full justify-center">
      <!-- Back / Forward Buttons -->
      <div class="flex items-center bg-slate-800/80 rounded-lg p-1 border border-slate-700/80">
        <button id="btn-nav-back" title="Geri (Önceki Ekran)" class="w-8 h-8 rounded flex items-center justify-center text-slate-300 hover:text-white hover:bg-slate-700/60 transition-all disabled:opacity-30 disabled:pointer-events-none">
          <span class="material-symbols-outlined text-[20px]">arrow_back</span>
        </button>
        <button id="btn-nav-forward" title="İleri" class="w-8 h-8 rounded flex items-center justify-center text-slate-300 hover:text-white hover:bg-slate-700/60 transition-all disabled:opacity-30 disabled:pointer-events-none">
          <span class="material-symbols-outlined text-[20px]">arrow_forward</span>
        </button>
        <button id="btn-nav-reload" title="Yeniden Yükle" class="w-8 h-8 rounded flex items-center justify-center text-slate-300 hover:text-white hover:bg-slate-700/60 transition-all">
          <span class="material-symbols-outlined text-[19px]">refresh</span>
        </button>
      </div>

      <!-- Quick Screen Jump Dropdown -->
      <div class="relative flex-1 max-w-md">
        <select id="screen-selector" class="w-full h-10 pl-3 pr-8 rounded-lg bg-slate-800/90 border border-slate-700 text-xs font-medium text-slate-200 focus:outline-none focus:border-[#0F4C5C] focus:ring-1 focus:ring-[#0F4C5C] appearance-none truncate cursor-pointer">
          {options_html}
        </select>
        <span class="material-symbols-outlined absolute right-2.5 top-2.5 text-[18px] text-slate-400 pointer-events-none">unfold_more</span>
      </div>
    </div>

    <!-- Right Flow Tabs & Device Switcher -->
    <div class="flex items-center gap-3">
      <!-- Device Mode Buttons -->
      <div class="flex items-center bg-slate-800/80 rounded-lg p-1 border border-slate-700/80">
        <button id="btn-mode-mobile" class="px-2.5 py-1 rounded text-xs font-semibold flex items-center gap-1.5 bg-[#0F4C5C] text-white transition-all shadow-sm">
          <span class="material-symbols-outlined text-[16px]">smartphone</span> Mobil
        </button>
        <button id="btn-mode-desktop" class="px-2.5 py-1 rounded text-xs font-semibold flex items-center gap-1.5 text-slate-400 hover:text-white transition-all">
          <span class="material-symbols-outlined text-[16px]">desktop_windows</span> Masaüstü
        </button>
      </div>

      <!-- Open current screen in new tab -->
      <button id="btn-open-direct" title="Bu ekranı doğrudan aç" class="h-9 px-3 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold flex items-center gap-1 border border-slate-700 transition-all">
        <span class="material-symbols-outlined text-[16px]">open_in_new</span> Tam Ekran
      </button>

      <!-- Stitch Info Link -->
      <a href="https://stitch.withgoogle.com" target="_blank" class="h-9 px-3.5 rounded-lg bg-[#E87525] hover:bg-[#d46519] text-white text-xs font-bold flex items-center gap-1.5 shadow-sm transition-all" title="Stitch Projesini Aç">
        <span class="material-symbols-outlined text-[17px]">hub</span> Stitch
      </a>
    </div>
  </header>

  <!-- QUICK FLOW SELECTOR SUB-BAR -->
  <div class="h-11 bg-[#09181F] border-b border-slate-800 px-6 flex items-center justify-between text-xs font-medium shrink-0">
    <div class="flex items-center gap-2 overflow-x-auto py-1">
      <span class="text-slate-400 text-[11px] font-bold uppercase tracking-wider shrink-0">Hızlı Akışlar:</span>
      <button onclick="jumpTo('0c06b06e422b40daacbc0b8e6e8fb7bf')" class="px-2.5 py-1 rounded-md bg-slate-800/60 hover:bg-slate-700 text-slate-200 transition-colors border border-slate-700/50 flex items-center gap-1 shrink-0">
        <span class="w-2 h-2 rounded-full bg-emerald-400"></span> Müşteri Giriş &amp; Sihirbaz
      </button>
      <button onclick="jumpTo('94a730cef5374f2ab9632d9acf0d7e19')" class="px-2.5 py-1 rounded-md bg-slate-800/60 hover:bg-slate-700 text-slate-200 transition-colors border border-slate-700/50 flex items-center gap-1 shrink-0">
        <span class="w-2 h-2 rounded-full bg-teal-400"></span> Teklifler &amp; Kabul
      </button>
      <button onclick="jumpTo('f3e7de808fdb49c18e3c5d430cb72528')" class="px-2.5 py-1 rounded-md bg-slate-800/60 hover:bg-slate-700 text-slate-200 transition-colors border border-slate-700/50 flex items-center gap-1 shrink-0">
        <span class="w-2 h-2 rounded-full bg-sky-400"></span> Aktif İş &amp; Mesajlaşma
      </button>
      <button onclick="jumpTo('11b9cb02877746d580c5484512d0928f')" class="px-2.5 py-1 rounded-md bg-slate-800/60 hover:bg-slate-700 text-slate-200 transition-colors border border-slate-700/50 flex items-center gap-1 shrink-0">
        <span class="w-2 h-2 rounded-full bg-amber-400"></span> Usta (Pro) Akışı
      </button>
      <button onclick="jumpTo('612429fdea1b42a1bf9e628883f7e58f')" class="px-2.5 py-1 rounded-md bg-slate-800/60 hover:bg-slate-700 text-slate-200 transition-colors border border-slate-700/50 flex items-center gap-1 shrink-0">
        <span class="w-2 h-2 rounded-full bg-indigo-400"></span> Yönetici Web Portalı
      </button>
      <button onclick="jumpTo('164cd33666284338b929a8325dc5ea20')" class="px-2.5 py-1 rounded-md bg-slate-800/60 hover:bg-slate-700 text-slate-200 transition-colors border border-slate-700/50 flex items-center gap-1 shrink-0">
        <span class="w-2 h-2 rounded-full bg-orange-400"></span> Web Tanıtım Sitesi
      </button>
    </div>

    <!-- Current Flow Badge Indicator -->
    <div id="active-flow-label" class="text-slate-400 text-[11px] font-semibold flex items-center gap-1.5 shrink-0 pl-3">
      <span class="w-2 h-2 rounded-full bg-[#107A5B] animate-pulse"></span>
      <span>1. Müşteri Giriş &amp; Onboarding</span>
    </div>
  </div>

  <!-- MAIN SIMULATOR VIEWPORT -->
  <main class="flex-1 bg-[#071318] p-4 flex items-center justify-center overflow-auto relative">

    <!-- PHONE FRAME CONTAINER -->
    <div id="device-container" class="relative transition-all duration-300 flex flex-col items-center justify-center">
      
      <!-- Realistic Mobile Phone Shell -->
      <div id="phone-shell" class="w-[390px] h-[844px] rounded-[52px] bg-black phone-shadow relative overflow-hidden flex flex-col border-[5px] border-[#2A3746]">
        
        <!-- Status Bar & Dynamic Island -->
        <div class="h-11 bg-white/95 backdrop-blur-md px-7 flex items-center justify-between text-xs font-semibold text-slate-900 shrink-0 select-none z-20 border-b border-slate-100/50">
          <span class="text-[14px] font-bold tracking-tight text-slate-800">09:41</span>
          
          <!-- Dynamic Island Notch -->
          <div class="w-28 h-6 bg-black rounded-full flex items-center justify-center gap-2 px-2 shadow-inner">
            <div class="w-2.5 h-2.5 rounded-full bg-slate-900"></div>
            <div class="w-2.5 h-2.5 rounded-full bg-[#0F4C5C]/60"></div>
          </div>

          <div class="flex items-center gap-1.5 text-slate-700">
            <span class="material-symbols-outlined text-[16px]">signal_cellular_4_bar</span>
            <span class="material-symbols-outlined text-[16px]">wifi</span>
            <span class="material-symbols-outlined text-[18px]">battery_full</span>
          </div>
        </div>

        <!-- IFRAME SCREEN VIEWER -->
        <div class="flex-1 w-full h-full relative overflow-hidden bg-[#F7F8F6]">
          <iframe id="screen-frame" src="./screens/0c06b06e422b40daacbc0b8e6e8fb7bf.html" class="w-full h-full"></iframe>
        </div>

        <!-- Phone Bottom Bar Home Indicator -->
        <div class="h-6 bg-white/95 backdrop-blur-md flex items-center justify-center shrink-0 z-20">
          <div class="w-32 h-1 bg-slate-900/40 rounded-full"></div>
        </div>
      </div>

    </div>

    <!-- FLOATING HINT PANEL (BOTTOM RIGHT) -->
    <div class="absolute bottom-5 right-5 max-w-xs bg-slate-900/90 backdrop-blur-md border border-slate-700/80 rounded-2xl p-4 shadow-2xl text-xs z-30 pointer-events-auto">
      <div class="flex items-center justify-between pb-2 mb-2 border-b border-slate-700/60 font-bold text-white">
        <span class="flex items-center gap-1.5 text-[#4ADE80]">
          <span class="material-symbols-outlined text-[16px]">touch_app</span> Canlı Prototip
        </span>
        <span id="hint-step-counter" class="text-slate-400 font-mono text-[10px]">1 / 33</span>
      </div>
      <p class="text-slate-300 leading-relaxed mb-3">
        Mobil ekranda butonlara basarak formu doldurabilir, usta tekliflerini karşılaştırıp kabul edebilir ve mesajlaşmayı test edebilirsiniz.
      </p>
      <div class="flex items-center justify-between text-[11px] text-slate-400">
        <span>Geri / İleri:</span>
        <span class="bg-slate-800 px-1.5 py-0.5 rounded font-mono text-slate-300">Alt + &larr; / &rarr;</span>
      </div>
    </div>

  </main>

  <script>
    const screensData = {screens_data_json};
    let historyStack = ['0c06b06e422b40daacbc0b8e6e8fb7bf'];
    let historyIndex = 0;

    const frame = document.getElementById('screen-frame');
    const selector = document.getElementById('screen-selector');
    const flowLabel = document.getElementById('active-flow-label');
    const stepCounter = document.getElementById('hint-step-counter');
    const btnBack = document.getElementById('btn-nav-back');
    const btnForward = document.getElementById('btn-nav-forward');
    const btnReload = document.getElementById('btn-nav-reload');
    const phoneShell = document.getElementById('phone-shell');
    const btnModeMobile = document.getElementById('btn-mode-mobile');
    const btnModeDesktop = document.getElementById('btn-mode-desktop');
    const btnOpenDirect = document.getElementById('btn-open-direct');

    function renderScreen(sid) {{
      frame.src = './screens/' + sid + '.html';
    }}

    function updateNavUI() {{
      const currentSid = historyStack[historyIndex];
      selector.value = currentSid;
      
      const info = screensData[currentSid] || {{ title: 'Ekran', flow: 'BiTadilat', device: 'MOBILE' }};
      flowLabel.innerHTML = `<span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span><span>${{info.flow}} — ${{info.title}}</span>`;
      stepCounter.textContent = `${{historyIndex + 1}} / ${{historyStack.length}} (${{info.device}})`;

      btnBack.disabled = (historyIndex <= 0);
      btnForward.disabled = (historyIndex >= historyStack.length - 1);

      if (info.device === 'DESKTOP') {{
        setDeviceMode('desktop');
      }} else {{
        setDeviceMode('mobile');
      }}
    }}

    function jumpTo(sid, pushToHistory = true) {{
      if (!sid) return;
      if (pushToHistory) {{
        historyStack = historyStack.slice(0, historyIndex + 1);
        historyStack.push(sid);
        historyIndex = historyStack.length - 1;
      }}
      renderScreen(sid);
      updateNavUI();
    }}

    function setDeviceMode(mode) {{
      if (mode === 'desktop') {{
        phoneShell.className = 'w-[1200px] max-w-[94vw] h-[820px] max-h-[82vh] rounded-2xl bg-slate-900 desktop-shadow relative overflow-hidden flex flex-col border border-slate-700';
        btnModeDesktop.className = 'px-2.5 py-1 rounded text-xs font-semibold flex items-center gap-1.5 bg-[#0F4C5C] text-white transition-all shadow-sm';
        btnModeMobile.className = 'px-2.5 py-1 rounded text-xs font-semibold flex items-center gap-1.5 text-slate-400 hover:text-white transition-all';
      }} else {{
        phoneShell.className = 'w-[390px] h-[844px] rounded-[52px] bg-black phone-shadow relative overflow-hidden flex flex-col border-[5px] border-[#2A3746]';
        btnModeMobile.className = 'px-2.5 py-1 rounded text-xs font-semibold flex items-center gap-1.5 bg-[#0F4C5C] text-white transition-all shadow-sm';
        btnModeDesktop.className = 'px-2.5 py-1 rounded text-xs font-semibold flex items-center gap-1.5 text-slate-400 hover:text-white transition-all';
      }}
    }}

    btnModeMobile.addEventListener('click', () => setDeviceMode('mobile'));
    btnModeDesktop.addEventListener('click', () => setDeviceMode('desktop'));

    btnOpenDirect.addEventListener('click', () => {{
      const currentSid = historyStack[historyIndex];
      window.open('./screens/' + currentSid + '.html', '_blank');
    }});

    btnBack.addEventListener('click', () => {{
      if (historyIndex > 0) {{
        historyIndex--;
        renderScreen(historyStack[historyIndex]);
        updateNavUI();
      }}
    }});

    btnForward.addEventListener('click', () => {{
      if (historyIndex < historyStack.length - 1) {{
        historyIndex++;
        renderScreen(historyStack[historyIndex]);
        updateNavUI();
      }}
    }});

    btnReload.addEventListener('click', () => {{
      renderScreen(historyStack[historyIndex]);
    }});

    selector.addEventListener('change', (e) => {{
      jumpTo(e.target.value);
    }});

    window.addEventListener('message', (event) => {{
      if (event.data && event.data.type === 'NAVIGATE') {{
        const targetSid = event.data.to;
        if (targetSid) {{
          jumpTo(targetSid);
        }}
      }}
    }});

    window.addEventListener('keydown', (e) => {{
      if (e.altKey && e.key === 'ArrowLeft') {{
        btnBack.click();
      }} else if (e.altKey && e.key === 'ArrowRight') {{
        btnForward.click();
      }}
    }});

    // Initialize UI
    renderScreen(historyStack[0]);
    updateNavUI();
  </script>
</body>
</html>
'''

with open('/Users/ata/Documents/antigravity/BiTadilat/preview/index.html', 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f'Clean index.html successfully generated ({len(html_content)} bytes)!')
