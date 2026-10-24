import json
from build_authoritative_prototype import screens_spec

# Build Drawer HTML Items
drawer_items_html = []
current_group = ""
for s in screens_spec:
    if s['flow'] != current_group:
        current_group = s['flow']
        role_label = 'MÜŞTERİ' if s['role']=='CUSTOMER' else ('USTA' if s['role']=='PRO' else 'WEB')
        drawer_items_html.append(f'''
        <div class="pt-3 pb-1 px-2 text-[11px] font-bold text-slate-400 uppercase tracking-wider flex items-center justify-between border-t border-slate-800/80 mt-2 first:mt-0 first:border-0">
          <span>{current_group}</span>
          <span class="text-[9px] px-1.5 py-0.5 rounded bg-slate-800 text-slate-400 font-mono">{role_label}</span>
        </div>''')

    role_badge = ''
    if s['role'] == 'CUSTOMER':
        role_badge = '<span class="w-1.5 h-1.5 rounded-full bg-[#0F4C5C]"></span>'
    elif s['role'] == 'PRO':
        role_badge = '<span class="w-1.5 h-1.5 rounded-full bg-[#107A5B]"></span>'
    else:
        role_badge = '<span class="w-1.5 h-1.5 rounded-full bg-[#E87525]"></span>'

    drawer_items_html.append(f'''
    <button onclick="jumpTo('{s['id']}')" id="drawer-item-{s['id']}" class="drawer-step-btn w-full text-left p-2.5 rounded-xl hover:bg-slate-800/80 transition-all flex items-center justify-between border border-transparent hover:border-slate-700/60 group">
      <div class="flex items-center gap-2.5 truncate">
        <span class="w-6 h-6 rounded-lg bg-slate-800 text-slate-300 font-bold text-[11px] flex items-center justify-center border border-slate-700 group-hover:bg-[#0F4C5C] group-hover:text-white transition-colors">{s['step_num']}</span>
        <div class="truncate">
          <p class="text-xs font-semibold text-slate-200 truncate group-hover:text-white flex items-center gap-1.5">
            {role_badge} <span>{s['title']}</span>
          </p>
        </div>
      </div>
      <span class="material-symbols-outlined text-[16px] text-slate-600 group-hover:text-[#4ADE80] transition-colors shrink-0">chevron_right</span>
    </button>''')

# Build Dropdown options
options_html = []
for s in screens_spec:
    role_prefix = '🏠 Müşteri' if s['role'] == 'CUSTOMER' else ('🛠️ Usta' if s['role'] == 'PRO' else '💻 Web')
    options_html.append(f'<option value="{s["id"]}">Adım {s["step_num"]:02d}: [{role_prefix}] {s["title"]}</option>')

specs_json = json.dumps({s['id']: s for s in screens_spec}, ensure_ascii=False)
order_json = json.dumps([s['id'] for s in screens_spec])

total_screens = len(screens_spec)
cust_count = sum(1 for s in screens_spec if s['role'] == 'CUSTOMER')
pro_count = sum(1 for s in screens_spec if s['role'] == 'PRO')
web_count = sum(1 for s in screens_spec if s['role'] in ('ADMIN', 'WEB'))

html_template = f'''<!DOCTYPE html>
<html lang="tr" class="h-full bg-[#071318]">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BiTadilat — {total_screens} Ekran Bağlantılı Mobil Prototip Simülatörü</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    body {{
      font-family: 'Manrope', sans-serif;
    }}
    .phone-shadow {{
      box-shadow: 0 25px 60px -15px rgba(0, 0, 0, 0.9), 0 0 0 12px #1E293B, 0 0 0 14px #0F172A;
    }}
    .desktop-shadow {{
      box-shadow: 0 25px 60px -15px rgba(0, 0, 0, 0.9), 0 0 0 1px rgba(255, 255, 255, 0.1);
    }}
    iframe {{
      border: none;
      width: 100%;
      height: 100%;
      background: #F7F8F6;
    }}
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
          <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-[#107A5B]/30 text-[#4ADE80] border border-[#107A5B]/50">{total_screens} Ekran Bağlantılı</span>
        </div>
        <p class="text-[11px] text-slate-400 font-medium">Doğrulanmış Rol Ayrımı &amp; Canlı Prototip</p>
      </div>
    </div>

    <!-- Center Role Switcher Bar -->
    <div class="flex items-center gap-1.5 bg-slate-900/90 p-1 rounded-xl border border-slate-700/80 shadow-inner">
      <button onclick="filterRole('CUSTOMER')" id="tab-role-customer" class="px-3.5 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all bg-[#0F4C5C] text-white shadow-sm">
        <span class="material-symbols-outlined text-[16px]">home</span>
        <span>Müşteri Akışı ({cust_count})</span>
      </button>
      <button onclick="filterRole('PRO')" id="tab-role-pro" class="px-3.5 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all text-slate-400 hover:text-white hover:bg-slate-800">
        <span class="material-symbols-outlined text-[16px]">construction</span>
        <span>Usta Akışı ({pro_count})</span>
      </button>
      <button onclick="filterRole('WEB')" id="tab-role-web" class="px-3.5 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all text-slate-400 hover:text-white hover:bg-slate-800">
        <span class="material-symbols-outlined text-[16px]">desktop_windows</span>
        <span>Yönetici &amp; Web ({web_count})</span>
      </button>
    </div>

    <!-- Center Navigation Controls -->
    <div class="flex items-center gap-3">
      <!-- Step Back / Forward -->
      <div class="flex items-center bg-slate-800/90 rounded-xl p-1 border border-slate-700">
        <button id="btn-prev-step" title="Önceki Adım (Alt + Sol Ok)" class="h-9 px-3 rounded-lg flex items-center gap-1 text-slate-300 hover:text-white hover:bg-slate-700 transition-all font-semibold text-xs disabled:opacity-30 disabled:pointer-events-none">
          <span class="material-symbols-outlined text-[18px]">arrow_back</span>
          <span>Önceki</span>
        </button>
        <div class="h-5 w-px bg-slate-700 mx-1"></div>
        <button id="btn-next-step" title="Sonraki Adım (Alt + Sağ Ok)" class="h-9 px-3 rounded-lg flex items-center gap-1 bg-[#0F4C5C] hover:bg-[#156073] text-white transition-all font-semibold text-xs shadow-sm disabled:opacity-30 disabled:pointer-events-none">
          <span>Sonraki</span>
          <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
        </button>
      </div>

      <!-- Quick Screen Jump Dropdown -->
      <div class="relative w-64">
        <select id="screen-selector" class="w-full h-11 pl-3 pr-8 rounded-xl bg-slate-800/90 border border-slate-700 text-xs font-semibold text-slate-100 focus:outline-none focus:border-[#0F4C5C] focus:ring-1 focus:ring-[#0F4C5C] appearance-none truncate cursor-pointer shadow-inner">
          {'\n'.join(options_html)}
        </select>
        <span class="material-symbols-outlined absolute right-2.5 top-3 text-[18px] text-slate-400 pointer-events-none">unfold_more</span>
      </div>

      <!-- Reload current screen -->
      <button id="btn-reload" title="Ekranı Yenile" class="w-11 h-11 rounded-xl bg-slate-800/90 hover:bg-slate-700 text-slate-300 hover:text-white flex items-center justify-center border border-slate-700 transition-all">
        <span class="material-symbols-outlined text-[20px]">refresh</span>
      </button>

      <!-- Toggle Drawer -->
      <button id="btn-toggle-drawer" class="h-11 px-3.5 rounded-xl bg-[#0F4C5C] hover:bg-[#145d70] text-white text-xs font-bold flex items-center gap-1.5 transition-all shadow-sm">
        <span class="material-symbols-outlined text-[18px]">menu</span>
        <span>Ekranlar ({total_screens})</span>
      </button>
    </div>
  </header>

  <!-- WORKSPACE BODY (DRAWER + VIEWER) -->
  <div class="flex-1 flex overflow-hidden relative">

    <!-- LEFT DRAWER: 41 SCREENS ORDERED LIST -->
    <aside id="flow-drawer" class="w-80 bg-[#0B1E26] border-r border-slate-800 flex flex-col shrink-0 z-20 transition-all duration-300">
      <div class="p-3.5 border-b border-slate-800 flex items-center justify-between">
        <span class="text-xs font-bold text-slate-300 uppercase tracking-wider flex items-center gap-1.5">
          <span class="w-2 h-2 rounded-full bg-[#107A5B]"></span> Akış &amp; Ekran Haritası
        </span>
        <span class="text-[11px] font-mono text-slate-400">{total_screens} Ekran</span>
      </div>

      <div class="flex-1 overflow-y-auto p-2 space-y-1" id="drawer-list">
        {''.join(drawer_items_html)}
      </div>
    </aside>

    <!-- MAIN SIMULATOR CENTER VIEWPORT -->
    <main class="flex-1 bg-[#061014] p-4 flex flex-col items-center justify-center overflow-auto relative">

      <!-- Breadcrumb Bar above Phone -->
      <div class="mb-3 px-4 py-1.5 rounded-full bg-slate-900/90 border border-slate-800 text-xs font-semibold text-slate-300 flex items-center gap-2 shadow-md">
        <span id="active-step-badge" class="px-2 py-0.5 rounded-full bg-[#0F4C5C] text-white text-[11px] font-bold">Adım 1 / {total_screens}</span>
        <span id="active-role-badge" class="px-2 py-0.5 rounded-full bg-slate-800 text-[#4ADE80] text-[10px] font-bold border border-slate-700">MÜŞTERİ</span>
        <span id="active-step-title" class="text-white truncate max-w-md">Hoş Geldiniz &amp; Rol Seçimi</span>
        <span class="text-slate-500">•</span>
        <span id="active-step-flow" class="text-slate-400 text-[11px]">1. Müşteri Giriş &amp; Onboarding</span>
      </div>

      <!-- PHONE FRAME -->
      <div id="phone-shell" class="w-[390px] h-[844px] rounded-[52px] bg-black phone-shadow relative overflow-hidden flex flex-col border-[5px] border-[#2A3746] shrink-0 transition-all duration-300">
        
        <!-- Status Bar & Dynamic Island -->
        <div id="phone-status-bar" class="h-11 bg-white/95 backdrop-blur-md px-7 flex items-center justify-between text-xs font-semibold text-slate-900 shrink-0 select-none z-20 border-b border-slate-100/50">
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
        <div id="phone-home-indicator" class="h-6 bg-white/95 backdrop-blur-md flex items-center justify-center shrink-0 z-20">
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
    const specs = {specs_json};
    const flowOrder = {order_json};

    let currentSid = flowOrder[0];
    let currentIndex = 0;

    const frame = document.getElementById('screen-frame');
    const selector = document.getElementById('screen-selector');
    const badge = document.getElementById('active-step-badge');
    const roleBadge = document.getElementById('active-role-badge');
    const titleEl = document.getElementById('active-step-title');
    const flowEl = document.getElementById('active-step-flow');
    const btnPrev = document.getElementById('btn-prev-step');
    const btnNext = document.getElementById('btn-next-step');
    const btnReload = document.getElementById('btn-reload');
    const phoneShell = document.getElementById('phone-shell');
    const statusBar = document.getElementById('phone-status-bar');
    const homeIndicator = document.getElementById('phone-home-indicator');
    const drawer = document.getElementById('flow-drawer');
    const btnToggleDrawer = document.getElementById('btn-toggle-drawer');
    const btnModePhone = document.getElementById('btn-mode-phone');
    const btnModeWeb = document.getElementById('btn-mode-web');

    const tabCustomer = document.getElementById('tab-role-customer');
    const tabPro = document.getElementById('tab-role-pro');
    const tabWeb = document.getElementById('tab-role-web');

    function updateRoleTabs(role) {{
      tabCustomer.className = 'px-3.5 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all text-slate-400 hover:text-white hover:bg-slate-800';
      tabPro.className = 'px-3.5 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all text-slate-400 hover:text-white hover:bg-slate-800';
      tabWeb.className = 'px-3.5 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all text-slate-400 hover:text-white hover:bg-slate-800';

      if (role === 'CUSTOMER') {{
        tabCustomer.className = 'px-3.5 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all bg-[#0F4C5C] text-white shadow-sm';
        roleBadge.className = 'px-2 py-0.5 rounded-full bg-[#0F4C5C]/40 text-[#4ADE80] text-[10px] font-bold border border-[#0F4C5C]';
        roleBadge.textContent = 'MÜŞTERİ';
      }} else if (role === 'PRO') {{
        tabPro.className = 'px-3.5 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all bg-[#107A5B] text-white shadow-sm';
        roleBadge.className = 'px-2 py-0.5 rounded-full bg-[#107A5B]/40 text-[#4ADE80] text-[10px] font-bold border border-[#107A5B]';
        roleBadge.textContent = 'USTA';
      }} else {{
        tabWeb.className = 'px-3.5 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all bg-[#E87525] text-white shadow-sm';
        roleBadge.className = 'px-2 py-0.5 rounded-full bg-[#E87525]/40 text-[#FDBA74] text-[10px] font-bold border border-[#E87525]';
        roleBadge.textContent = 'YÖNETİCİ / WEB';
      }}
    }}

    function filterRole(role) {{
      if (role === 'CUSTOMER') {{
        jumpTo('0c06b06e422b40daacbc0b8e6e8fb7bf');
      }} else if (role === 'PRO') {{
        jumpTo('11b9cb02877746d580c5484512d0928f');
      }} else {{
        jumpTo('612429fdea1b42a1bf9e628883f7e58f');
      }}
    }}

    function updateView(sid) {{
      currentSid = sid;
      currentIndex = flowOrder.indexOf(sid);
      if (currentIndex === -1) currentIndex = 0;

      const spec = specs[sid] || {{ title: 'Ekran', flow: 'BiTadilat', step_num: currentIndex + 1, role: 'CUSTOMER', device: 'MOBILE' }};

      // Update frame
      frame.src = './screens/' + sid + '.html';

      // Update selectors & labels
      selector.value = sid;
      badge.textContent = `Adım ${{spec.step_num}} / {total_screens}`;
      titleEl.textContent = spec.title;
      flowEl.textContent = spec.flow;

      updateRoleTabs(spec.role);

      // Update nav buttons
      btnPrev.disabled = (currentIndex <= 0);
      btnNext.disabled = (currentIndex >= flowOrder.length - 1);

      // Highlight in drawer
      document.querySelectorAll('.drawer-step-btn').forEach(btn => {{
        btn.classList.remove('bg-[#0F4C5C]/40', 'border-[#0F4C5C]', 'text-white');
      }});
      const activeDrawerBtn = document.getElementById('drawer-item-' + sid);
      if (activeDrawerBtn) {{
        activeDrawerBtn.classList.add('bg-[#0F4C5C]/40', 'border-[#0F4C5C]', 'text-white');
        activeDrawerBtn.scrollIntoView({{ block: 'nearest', behavior: 'smooth' }});
      }}

      // Auto toggle desktop frame for admin/web screens
      if (spec.device === 'DESKTOP') {{
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
        phoneShell.className = 'w-[1200px] max-w-[94vw] h-[820px] max-h-[82vh] rounded-2xl bg-slate-900 desktop-shadow relative overflow-hidden flex flex-col border border-slate-700 shrink-0';
        statusBar.style.display = 'none';
        homeIndicator.style.display = 'none';
        btnModeWeb.className = 'px-3 py-1 rounded-lg bg-[#0F4C5C] text-white text-xs font-semibold flex items-center gap-1 shadow-sm';
        btnModePhone.className = 'px-3 py-1 rounded-lg bg-slate-800 text-slate-300 hover:text-white text-xs font-semibold flex items-center gap-1 border border-slate-700';
      }} else {{
        phoneShell.className = 'w-[390px] h-[844px] rounded-[52px] bg-black phone-shadow relative overflow-hidden flex flex-col border-[5px] border-[#2A3746] shrink-0';
        statusBar.style.display = 'flex';
        homeIndicator.style.display = 'flex';
        btnModePhone.className = 'px-3 py-1 rounded-lg bg-[#0F4C5C] text-white text-xs font-semibold flex items-center gap-1 shadow-sm';
        btnModeWeb.className = 'px-3 py-1 rounded-lg bg-slate-800 text-slate-300 hover:text-white text-xs font-semibold flex items-center gap-1 border border-slate-700';
      }}
    }}

    btnPrev.addEventListener('click', () => {{
      if (currentIndex > 0) updateView(flowOrder[currentIndex - 1]);
    }});

    btnNext.addEventListener('click', () => {{
      if (currentIndex < flowOrder.length - 1) updateView(flowOrder[currentIndex + 1]);
    }});

    btnReload.addEventListener('click', () => {{
      frame.src = frame.src;
    }});

    selector.addEventListener('change', (e) => {{
      jumpTo(e.target.value);
    }});

    btnToggleDrawer.addEventListener('click', () => {{
      if (drawer.style.display === 'none') {{
        drawer.style.display = 'flex';
      }} else {{
        drawer.style.display = 'none';
      }}
    }});

    window.addEventListener('message', (event) => {{
      if (event.data && event.data.type === 'NAVIGATE') {{
        const targetSid = event.data.to;
        if (targetSid) {{
          console.log('[Parent Simulator] Transitioning to:', targetSid, event.data.label);
          updateView(targetSid);
        }}
      }}
    }});

    window.addEventListener('keydown', (e) => {{
      if (e.altKey && e.key === 'ArrowLeft') {{
        btnPrev.click();
      }} else if (e.altKey && e.key === 'ArrowRight') {{
        btnNext.click();
      }}
    }});

    updateView(flowOrder[0]);
  </script>
</body>
</html>
'''

with open('/Users/ata/Documents/antigravity/BiTadilat/preview/index.html', 'w', encoding='utf-8') as f:
    f.write(html_template)

print(f'Generated authoritative preview/index.html with all {total_screens} screens!')
