import os, json

with open('/Users/ata/Documents/antigravity/BiTadilat/build_connected_screens.py') as f:
    text = f.read()

# We can import screen_specs directly
from build_connected_screens import screen_specs

# Order by step_num 1..33
sorted_screens = sorted(screen_specs.items(), key=lambda x: x[1]['step_num'])

options_html = ''
drawer_items_html = ''
for sid, spec in sorted_screens:
    snum = spec['step_num']
    title = spec['title']
    flow = spec['flow']
    options_html += f'  <option value="{sid}">Adım {snum:02d}: {title}</option>\n'
    drawer_items_html += f'''
    <button onclick="jumpTo('{sid}')" id="drawer-item-{sid}" class="drawer-step-btn w-full text-left p-2.5 rounded-xl hover:bg-slate-800 transition-all flex items-center justify-between border border-transparent hover:border-slate-700/60 group">
      <div class="flex items-center gap-2.5 truncate">
        <span class="w-6 h-6 rounded-full bg-slate-800 text-slate-300 font-bold text-[11px] flex items-center justify-center border border-slate-700 group-hover:bg-[#0F4C5C] group-hover:text-white transition-colors">{snum}</span>
        <div class="truncate">
          <p class="text-xs font-semibold text-slate-200 truncate group-hover:text-white">{title}</p>
          <p class="text-[10px] text-slate-400 font-medium truncate">{flow}</p>
        </div>
      </div>
      <span class="material-symbols-outlined text-[16px] text-slate-500 group-hover:text-[#4ADE80] transition-colors shrink-0">chevron_right</span>
    </button>
    '''

screens_data_json = json.dumps(screen_specs, ensure_ascii=False)

html_content = f'''<!DOCTYPE html>
<html lang="tr" class="h-full bg-[#071318]">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BiTadilat — 33 Ekran Bağlantılı Mobil Prototip Simülatörü</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    body {{
      font-family: 'Manrope', sans-serif;
    }}
    .phone-shadow {{
      box-shadow: 0 25px 60px -15px rgba(0, 0, 0, 0.8), 0 0 0 12px #1E293B, 0 0 0 14px #0F172A;
    }}
    .desktop-shadow {{
      box-shadow: 0 25px 60px -15px rgba(0, 0, 0, 0.8), 0 0 0 1px rgba(255, 255, 255, 0.1);
    }}
    iframe {{
      border: none;
      width: 100%;
      height: 100%;
      background: #F7F8F6;
    }}
    /* Custom scrollbar */
    ::-webkit-scrollbar {{
      width: 6px;
      height: 6px;
    }}
    ::-webkit-scrollbar-track {{
      background: rgba(15, 23, 42, 0.6);
    }}
    ::-webkit-scrollbar-thumb {{
      background: rgba(100, 116, 139, 0.5);
      border-radius: 9999px;
    }}
    ::-webkit-scrollbar-thumb:hover {{
      background: rgba(148, 163, 184, 0.8);
    }}
  </style>
</head>
<body class="h-full flex flex-col text-slate-100 overflow-hidden select-none">

  <!-- TOP HEADER -->
  <header class="h-16 bg-[#0E2833] border-b border-slate-700/60 px-5 flex items-center justify-between shrink-0 shadow-lg z-30">
    <!-- App Logo -->
    <div class="flex items-center gap-3">
      <div class="w-10 h-10 rounded-xl bg-[#0F4C5C] flex items-center justify-center text-white font-bold text-lg shadow-sm border border-[#1a657a]">
        <span class="material-symbols-outlined text-[24px]">handyman</span>
      </div>
      <div>
        <div class="flex items-center gap-2">
          <span class="font-bold tracking-tight text-[17px] text-white">BiTadilat</span>
          <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-[#107A5B]/30 text-[#4ADE80] border border-[#107A5B]/50">33 Ekran Sıralı &amp; Bağlantılı</span>
        </div>
        <p class="text-[11px] text-slate-400 font-medium">Doğrulanmış Uygulama Akışı &amp; Canlı Prototip</p>
      </div>
    </div>

    <!-- Center Navigation Controls -->
    <div class="flex items-center gap-3 max-w-2xl w-full justify-center">
      <!-- Step Back / Forward -->
      <div class="flex items-center bg-slate-800/90 rounded-xl p-1 border border-slate-700">
        <button id="btn-prev-step" title="Önceki Adım" class="h-9 px-3 rounded-lg flex items-center gap-1 text-slate-300 hover:text-white hover:bg-slate-700 transition-all font-semibold text-xs disabled:opacity-30 disabled:pointer-events-none">
          <span class="material-symbols-outlined text-[18px]">arrow_back</span>
          <span>Önceki</span>
        </button>
        <div class="h-5 w-px bg-slate-700 mx-1"></div>
        <button id="btn-next-step" title="Sonraki Adım" class="h-9 px-3 rounded-lg flex items-center gap-1 bg-[#0F4C5C] hover:bg-[#156073] text-white transition-all font-semibold text-xs shadow-sm disabled:opacity-30 disabled:pointer-events-none">
          <span>Sonraki</span>
          <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
        </button>
      </div>

      <!-- Quick Screen Jump Dropdown -->
      <div class="relative flex-1 max-w-md">
        <select id="screen-selector" class="w-full h-11 pl-3 pr-8 rounded-xl bg-slate-800/90 border border-slate-700 text-xs font-semibold text-slate-100 focus:outline-none focus:border-[#0F4C5C] focus:ring-1 focus:ring-[#0F4C5C] appearance-none truncate cursor-pointer shadow-inner">
          {options_html}
        </select>
        <span class="material-symbols-outlined absolute right-2.5 top-3 text-[18px] text-slate-400 pointer-events-none">unfold_more</span>
      </div>

      <!-- Reload current screen -->
      <button id="btn-reload" title="Ekranı Yenile" class="w-11 h-11 rounded-xl bg-slate-800/90 hover:bg-slate-700 text-slate-300 hover:text-white flex items-center justify-center border border-slate-700 transition-all">
        <span class="material-symbols-outlined text-[20px]">refresh</span>
      </button>
    </div>

    <!-- Right Actions -->
    <div class="flex items-center gap-3">
      <!-- Open standalone tab -->
      <button id="btn-open-tab" title="Bu ekranı yeni sekmede tam ekran aç" class="h-10 px-3.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold flex items-center gap-1.5 border border-slate-700 transition-all shadow-sm">
        <span class="material-symbols-outlined text-[16px]">open_in_new</span>
        <span>Tam Ekran Aç</span>
      </button>

      <!-- Toggle Drawer -->
      <button id="btn-toggle-drawer" class="h-10 px-3.5 rounded-xl bg-[#0F4C5C] hover:bg-[#145d70] text-white text-xs font-bold flex items-center gap-1.5 transition-all shadow-sm">
        <span class="material-symbols-outlined text-[18px]">list</span>
        <span>33 Ekran Listesi</span>
      </button>
    </div>
  </header>

  <!-- WORKSPACE BODY (DRAWER + VIEWER) -->
  <div class="flex-1 flex overflow-hidden relative">

    <!-- LEFT DRAWER: 33 SCREENS ORDERED LIST -->
    <aside id="flow-drawer" class="w-80 bg-[#0B1E26] border-r border-slate-800 flex flex-col shrink-0 z-20 transition-all duration-300">
      <div class="p-3.5 border-b border-slate-800 flex items-center justify-between">
        <span class="text-xs font-bold text-slate-300 uppercase tracking-wider flex items-center gap-1.5">
          <span class="w-2 h-2 rounded-full bg-[#107A5B]"></span> Adım Adım Akış Haritası
        </span>
        <span class="text-[11px] font-mono text-slate-400">33 Ekran</span>
      </div>
      <div class="flex-1 overflow-y-auto p-2 space-y-1" id="drawer-list">
        {drawer_items_html}
      </div>
    </aside>

    <!-- MAIN SIMULATOR CENTER VIEWPORT -->
    <main class="flex-1 bg-[#061014] p-4 flex flex-col items-center justify-center overflow-auto relative">

      <!-- Breadcrumb Bar above Phone -->
      <div class="mb-3 px-4 py-1.5 rounded-full bg-slate-900/90 border border-slate-800 text-xs font-semibold text-slate-300 flex items-center gap-2 shadow-md">
        <span id="active-step-badge" class="px-2 py-0.5 rounded-full bg-[#0F4C5C] text-white text-[11px] font-bold">Adım 1 / 33</span>
        <span id="active-step-title" class="text-white truncate max-w-md">Hoş Geldiniz &amp; Rol Seçimi</span>
        <span class="text-slate-500">•</span>
        <span id="active-step-flow" class="text-slate-400 text-[11px]">1. Müşteri Giriş &amp; Onboarding</span>
      </div>

      <!-- PHONE FRAME -->
      <div id="phone-shell" class="w-[390px] h-[844px] rounded-[52px] bg-black phone-shadow relative overflow-hidden flex flex-col border-[5px] border-[#2A3746] shrink-0 transition-all duration-300">
        
        <!-- Status Bar & Dynamic Island -->
        <div class="h-11 bg-white/95 backdrop-blur-md px-7 flex items-center justify-between text-xs font-semibold text-slate-900 shrink-0 select-none z-20 border-b border-slate-100/50">
          <span class="text-[14px] font-bold tracking-tight text-slate-800">09:41</span>
          
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

        <!-- IFRAME CONTAINER -->
        <div class="flex-1 w-full h-full relative overflow-hidden bg-[#F7F8F6]">
          <iframe id="screen-frame" src="./screens/0c06b06e422b40daacbc0b8e6e8fb7bf.html" class="w-full h-full"></iframe>
        </div>

        <!-- Phone Home Indicator -->
        <div class="h-6 bg-white/95 backdrop-blur-md flex items-center justify-center shrink-0 z-20">
          <div class="w-32 h-1 bg-slate-900/40 rounded-full"></div>
        </div>
      </div>

      <!-- BOTTOM CONTROL BAR -->
      <div class="mt-3 flex items-center gap-2">
        <button onclick="setDeviceMode('mobile')" id="btn-mode-phone" class="px-3 py-1 rounded-lg bg-[#0F4C5C] text-white text-xs font-semibold flex items-center gap-1 shadow-sm">
          <span class="material-symbols-outlined text-[16px]">smartphone</span> Mobil Telefon (390×844)
        </button>
        <button onclick="setDeviceMode('desktop')" id="btn-mode-web" class="px-3 py-1 rounded-lg bg-slate-800 text-slate-300 hover:text-white text-xs font-semibold flex items-center gap-1 border border-slate-700">
          <span class="material-symbols-outlined text-[16px]">desktop_windows</span> Geniş Web / Masaüstü (1200×820)
        </button>
      </div>

    </main>

  </div>

  <script>
    const specs = {screens_data_json};
    const flowOrder = {json.dumps([s[0] for s in sorted_screens])};

    let currentSid = flowOrder[0];
    let currentIndex = 0;

    const frame = document.getElementById('screen-frame');
    const selector = document.getElementById('screen-selector');
    const badge = document.getElementById('active-step-badge');
    const titleEl = document.getElementById('active-step-title');
    const flowEl = document.getElementById('active-step-flow');
    const btnPrev = document.getElementById('btn-prev-step');
    const btnNext = document.getElementById('btn-next-step');
    const btnReload = document.getElementById('btn-reload');
    const btnOpenTab = document.getElementById('btn-open-tab');
    const phoneShell = document.getElementById('phone-shell');
    const drawer = document.getElementById('flow-drawer');
    const btnToggleDrawer = document.getElementById('btn-toggle-drawer');
    const btnModePhone = document.getElementById('btn-mode-phone');
    const btnModeWeb = document.getElementById('btn-mode-web');

    function updateView(sid) {{
      currentSid = sid;
      currentIndex = flowOrder.indexOf(sid);
      if (currentIndex === -1) currentIndex = 0;

      const spec = specs[sid] || {{ title: 'Ekran', flow: 'BiTadilat', step_num: currentIndex + 1 }};

      // Update frame
      frame.src = './screens/' + sid + '.html';

      // Update selectors & labels
      selector.value = sid;
      badge.textContent = `Adım ${{spec.step_num}} / 33`;
      titleEl.textContent = spec.title;
      flowEl.textContent = spec.flow;

      // Update nav buttons
      btnPrev.disabled = (currentIndex <= 0);
      btnNext.disabled = (currentIndex >= flowOrder.length - 1);

      // Highlight in drawer
      document.querySelectorAll('.drawer-step-btn').forEach(btn => {{
        btn.classList.remove('bg-[#0F4C5C]/30', 'border-[#0F4C5C]', 'text-white');
      }});
      const activeDrawerBtn = document.getElementById('drawer-item-' + sid);
      if (activeDrawerBtn) {{
        activeDrawerBtn.classList.add('bg-[#0F4C5C]/30', 'border-[#0F4C5C]', 'text-white');
        activeDrawerBtn.scrollIntoView({{ block: 'nearest', behavior: 'smooth' }});
      }}

      // Auto toggle desktop frame for admin/web screens
      if (spec.step_num >= 30) {{
        setDeviceMode('desktop');
      }} else {{
        setDeviceMode('mobile');
      }}
    }}

    function jumpTo(sid) {{
      if (!sid) return;
      updateView(sid);
    }}

    function setDeviceMode(mode) {{
      if (mode === 'desktop') {{
        phoneShell.className = 'w-[1200px] max-w-[94vw] h-[820px] max-h-[80vh] rounded-2xl bg-slate-900 desktop-shadow relative overflow-hidden flex flex-col border border-slate-700 shrink-0';
        btnModeWeb.className = 'px-3 py-1 rounded-lg bg-[#0F4C5C] text-white text-xs font-semibold flex items-center gap-1 shadow-sm';
        btnModePhone.className = 'px-3 py-1 rounded-lg bg-slate-800 text-slate-300 hover:text-white text-xs font-semibold flex items-center gap-1 border border-slate-700';
      }} else {{
        phoneShell.className = 'w-[390px] h-[844px] rounded-[52px] bg-black phone-shadow relative overflow-hidden flex flex-col border-[5px] border-[#2A3746] shrink-0';
        btnModePhone.className = 'px-3 py-1 rounded-lg bg-[#0F4C5C] text-white text-xs font-semibold flex items-center gap-1 shadow-sm';
        btnModeWeb.className = 'px-3 py-1 rounded-lg bg-slate-800 text-slate-300 hover:text-white text-xs font-semibold flex items-center gap-1 border border-slate-700';
      }}
    }}

    // Prev / Next button handlers
    btnPrev.addEventListener('click', () => {{
      if (currentIndex > 0) {{
        updateView(flowOrder[currentIndex - 1]);
      }}
    }});

    btnNext.addEventListener('click', () => {{
      if (currentIndex < flowOrder.length - 1) {{
        updateView(flowOrder[currentIndex + 1]);
      }}
    }});

    btnReload.addEventListener('click', () => {{
      frame.src = frame.src;
    }});

    btnOpenTab.addEventListener('click', () => {{
      window.open('./screens/' + currentSid + '.html', '_blank');
    }});

    selector.addEventListener('change', (e) => {{
      jumpTo(e.target.value);
    }});

    // Toggle drawer
    btnToggleDrawer.addEventListener('click', () => {{
      if (drawer.style.display === 'none') {{
        drawer.style.display = 'flex';
      }} else {{
        drawer.style.display = 'none';
      }}
    }});

    // Listen to messages from inside iframe screens
    window.addEventListener('message', (event) => {{
      if (event.data && event.data.type === 'NAVIGATE') {{
        const targetSid = event.data.to;
        if (targetSid) {{
          console.log('[Parent Simulator] Transitioning to:', targetSid);
          updateView(targetSid);
        }}
      }}
    }});

    // Keyboard shortcuts
    window.addEventListener('keydown', (e) => {{
      if (e.altKey && e.key === 'ArrowLeft') {{
        btnPrev.click();
      }} else if (e.altKey && e.key === 'ArrowRight') {{
        btnNext.click();
      }}
    }});

    // Initial View
    updateView(flowOrder[0]);
  </script>
</body>
</html>
'''

with open('/Users/ata/Documents/antigravity/BiTadilat/preview/index.html', 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f'Successfully built perfect master simulator index.html ({len(html_content)} bytes)!')
