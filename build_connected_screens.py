import os, json, re

screens_dir = '/Users/ata/Documents/antigravity/BiTadilat/preview/screens'

# The authoritative, comprehensive 33-screen step configuration
# Each entry defines:
#   step_num: Order 1..33
#   sid: Screen ID
#   title: Clean descriptive title
#   flow: Category/Flow name
#   back_sid: Screen to go back to (None if root)
#   next_sid: Primary forward screen
#   custom_actions: Specific selectors and their target screen IDs
screen_specs = {
    # Flow 1: Onboarding & Auth
    '0c06b06e422b40daacbc0b8e6e8fb7bf': {
        'step_num': 1,
        'title': 'Hoş Geldiniz & Rol Seçimi (SCR-01)',
        'flow': '1. Müşteri Giriş & Onboarding',
        'back_sid': None,
        'next_sid': 'fbbe0f405e1f4531a14dcdd6b1c5736a',
        'role_homeowner': 'fbbe0f405e1f4531a14dcdd6b1c5736a',
        'role_pro': '11b9cb02877746d580c5484512d0928f'
    },
    'fbbe0f405e1f4531a14dcdd6b1c5736a': {
        'step_num': 2,
        'title': 'Telefon Doğrulama',
        'flow': '1. Müşteri Giriş & Onboarding',
        'back_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'next_sid': '42c148a1fb25400ca549481fa6abe01f'
    },
    '42c148a1fb25400ca549481fa6abe01f': {
        'step_num': 3,
        'title': 'SMS Doğrulama Kodu',
        'flow': '1. Müşteri Giriş & Onboarding',
        'back_sid': 'fbbe0f405e1f4531a14dcdd6b1c5736a',
        'next_sid': 'cc1f55661a1a4036a890b43d9f15596a'
    },

    # Flow 2: 4-Step Request Wizard
    'cc1f55661a1a4036a890b43d9f15596a': {
        'step_num': 4,
        'title': 'Müşteri Ana Sayfası (Yeni Kullanıcı)',
        'flow': '2. Müşteri Talep Sihirbazı',
        'back_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'next_sid': '44c003fee81d4a188f187608554efdd5',
        'tab_requests': '94a730cef5374f2ab9632d9acf0d7e19',
        'tab_messages': 'c9aa92f5a4e04897952d05f30c2aef10',
        'tab_pro': '11b9cb02877746d580c5484512d0928f'
    },
    '44c003fee81d4a188f187608554efdd5': {
        'step_num': 5,
        'title': 'Yeni Talep — Adım 1 / 4: Hizmet & Öncelik (SCR-02)',
        'flow': '2. Müşteri Talep Sihirbazı',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'b3c3c2845017451fb1b85b89f04fd4b8'
    },
    'b3c3c2845017451fb1b85b89f04fd4b8': {
        'step_num': 6,
        'title': 'Yeni Talep — Adım 2 / 4: Konum & İş Detayı',
        'flow': '2. Müşteri Talep Sihirbazı',
        'back_sid': '44c003fee81d4a188f187608554efdd5',
        'next_sid': '585d649f4ea046ffa70e4cb481ddd030'
    },
    '585d649f4ea046ffa70e4cb481ddd030': {
        'step_num': 7,
        'title': 'Yeni Talep — Adım 3 / 4: Fotoğraflar & Ek Bilgi',
        'flow': '2. Müşteri Talep Sihirbazı',
        'back_sid': 'b3c3c2845017451fb1b85b89f04fd4b8',
        'next_sid': 'a0949c91cbe34557b16273c8e91d067a'
    },
    'a0949c91cbe34557b16273c8e91d067a': {
        'step_num': 8,
        'title': 'Yeni Talep — Adım 4 / 4: Talebi Gözden Geçir',
        'flow': '2. Müşteri Talep Sihirbazı',
        'back_sid': '585d649f4ea046ffa70e4cb481ddd030',
        'next_sid': '94a730cef5374f2ab9632d9acf0d7e19'
    },

    # Flow 3: Proposals, Comparison & Appointment
    '94a730cef5374f2ab9632d9acf0d7e19': {
        'step_num': 9,
        'title': 'Talep Yayınlandı — Teklif Bekleniyor',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': '994e3b4ffce942ce8778f7a6cfaa42c0'
    },
    '994e3b4ffce942ce8778f7a6cfaa42c0': {
        'step_num': 10,
        'title': 'Gelen Teklifler Listesi (SCR-04)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'back_sid': '94a730cef5374f2ab9632d9acf0d7e19',
        'next_sid': 'ea7af2d7298b4b6cb24e4603935503f0',
        'compare_sid': '1fc70722168942c4a1933cd9c641ad68'
    },
    'ea7af2d7298b4b6cb24e4603935503f0': {
        'step_num': 11,
        'title': 'Teklif Detayı & Kapsam',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'back_sid': '994e3b4ffce942ce8778f7a6cfaa42c0',
        'next_sid': '58f9993b5f444ff3a9f9361cb8d3b731',
        'profile_sid': '98cd20d6ab4e4f8fbc29bc462ce55cca',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10'
    },
    '1fc70722168942c4a1933cd9c641ad68': {
        'step_num': 12,
        'title': 'Teklifleri Karşılaştır (Matris)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'back_sid': '994e3b4ffce942ce8778f7a6cfaa42c0',
        'next_sid': 'ea7af2d7298b4b6cb24e4603935503f0'
    },
    '98cd20d6ab4e4f8fbc29bc462ce55cca': {
        'step_num': 13,
        'title': 'Hizmet Profesyoneli Profili (SCR-05)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'back_sid': 'ea7af2d7298b4b6cb24e4603935503f0',
        'next_sid': 'ea7af2d7298b4b6cb24e4603935503f0',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10'
    },
    '58f9993b5f444ff3a9f9361cb8d3b731': {
        'step_num': 14,
        'title': 'Teklif Kabul Onayı (Güvence Havuzu)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'back_sid': 'ea7af2d7298b4b6cb24e4603935503f0',
        'next_sid': '7c6ec3a02d3347a997a3fc5b1a2c91d0'
    },
    '7c6ec3a02d3347a997a3fc5b1a2c91d0': {
        'step_num': 15,
        'title': 'Randevu Zamanı Seç (SCR-06)',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'back_sid': '58f9993b5f444ff3a9f9361cb8d3b731',
        'next_sid': '3bd2afe80ced4d2498ec9f16c7099326'
    },
    '3bd2afe80ced4d2498ec9f16c7099326': {
        'step_num': 16,
        'title': 'Randevu Talebi İletildi',
        'flow': '3. Teklif Karşılaştırma & Randevu',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'f3e7de808fdb49c18e3c5d430cb72528'
    },

    # Flow 4: Active Job, Messaging, Completion, Rating & Disputes
    'f3e7de808fdb49c18e3c5d430cb72528': {
        'step_num': 17,
        'title': 'İş Alanı — Randevu Onaylandı',
        'flow': '4. Aktif İş, Mesajlaşma, Teslim & Şikayet',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'd485263b3ae244a9b35500665b5c759b',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10',
        'milestones_sid': 'b89d998c02d34e67b8e8f34334f87f02',
        'reschedule_sid': '6acc9307352f497ca6bd878d628c6a1a'
    },
    'c9aa92f5a4e04897952d05f30c2aef10': {
        'step_num': 18,
        'title': 'Usta ile Mesajlaşma (SCR-07)',
        'flow': '4. Aktif İş, Mesajlaşma, Teslim & Şikayet',
        'back_sid': 'f3e7de808fdb49c18e3c5d430cb72528',
        'next_sid': 'f3e7de808fdb49c18e3c5d430cb72528'
    },
    'b89d998c02d34e67b8e8f34334f87f02': {
        'step_num': 19,
        'title': 'İş Aşamaları ve İlerleme Takibi (SCR-08)',
        'flow': '4. Aktif İş, Mesajlaşma, Teslim & Şikayet',
        'back_sid': 'f3e7de808fdb49c18e3c5d430cb72528',
        'next_sid': 'd485263b3ae244a9b35500665b5c759b',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10',
        'dispute_sid': '488f3698f93c454099ca2382585aeb66'
    },
    '6acc9307352f497ca6bd878d628c6a1a': {
        'step_num': 20,
        'title': 'Randevu İptal ve Değişiklik Talebi (SCR-09)',
        'flow': '4. Aktif İş, Mesajlaşma, Teslim & Şikayet',
        'back_sid': 'f3e7de808fdb49c18e3c5d430cb72528',
        'next_sid': 'f3e7de808fdb49c18e3c5d430cb72528'
    },
    'd485263b3ae244a9b35500665b5c759b': {
        'step_num': 21,
        'title': 'İş Tamamlama ve Teslim Onayı (SCR-10)',
        'flow': '4. Aktif İş, Mesajlaşma, Teslim & Şikayet',
        'back_sid': 'f3e7de808fdb49c18e3c5d430cb72528',
        'next_sid': 'db8a1b368a7749cbb5fd6cf497f34de6',
        'dispute_sid': '488f3698f93c454099ca2382585aeb66'
    },
    'db8a1b368a7749cbb5fd6cf497f34de6': {
        'step_num': 22,
        'title': 'Hizmet Değerlendirme ve Puanlama (SCR-11)',
        'flow': '4. Aktif İş, Mesajlaşma, Teslim & Şikayet',
        'back_sid': 'd485263b3ae244a9b35500665b5c759b',
        'next_sid': 'cc1f55661a1a4036a890b43d9f15596a'
    },
    '488f3698f93c454099ca2382585aeb66': {
        'step_num': 23,
        'title': 'Şikayet ve Uyuşmazlık Bildirimi (SCR-12)',
        'flow': '4. Aktif İş, Mesajlaşma, Teslim & Şikayet',
        'back_sid': 'd485263b3ae244a9b35500665b5c759b',
        'next_sid': '3bb4b954e5224b0097b2bee12be9bcbf'
    },
    '3bb4b954e5224b0097b2bee12be9bcbf': {
        'step_num': 24,
        'title': 'Şikayet İletildi ve Durum Takibi (SCR-13)',
        'flow': '4. Aktif İş, Mesajlaşma, Teslim & Şikayet',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10'
    },

    # Flow 5: Professional Flow
    '11b9cb02877746d580c5484512d0928f': {
        'step_num': 25,
        'title': 'Usta Eşleşen Talepler Akışı (SCR-14)',
        'flow': '5. Hizmet Profesyoneli (Usta)',
        'back_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'next_sid': 'b9086f1030784def8eb267fd9110addd',
        'tab_availability': 'fc6f0f8e9b724365a5a0f124617dbe7a',
        'tab_active_jobs': '8ba8c346d11c46f39163fd6ebf06dae1'
    },
    'b9086f1030784def8eb267fd9110addd': {
        'step_num': 26,
        'title': 'Usta Yapılandırılmış Teklif Hazırlama (SCR-15)',
        'flow': '5. Hizmet Profesyoneli (Usta)',
        'back_sid': '11b9cb02877746d580c5484512d0928f',
        'next_sid': '82f9d783b88b40ec8ca6260566c0f5cb'
    },
    '82f9d783b88b40ec8ca6260566c0f5cb': {
        'step_num': 27,
        'title': 'Usta Teklif Gönderildi Onayı (SCR-16)',
        'flow': '5. Hizmet Profesyoneli (Usta)',
        'back_sid': '11b9cb02877746d580c5484512d0928f',
        'next_sid': '11b9cb02877746d580c5484512d0928f',
        'tab_availability': 'fc6f0f8e9b724365a5a0f124617dbe7a'
    },
    'fc6f0f8e9b724365a5a0f124617dbe7a': {
        'step_num': 28,
        'title': 'Usta Profil ve Müsaitlik Yönetimi (SCR-17)',
        'flow': '5. Hizmet Profesyoneli (Usta)',
        'back_sid': '11b9cb02877746d580c5484512d0928f',
        'next_sid': '11b9cb02877746d580c5484512d0928f'
    },
    '8ba8c346d11c46f39163fd6ebf06dae1': {
        'step_num': 29,
        'title': 'Usta İş Yürütme ve Aşama Yönetimi (SCR-18)',
        'flow': '5. Hizmet Profesyoneli (Usta)',
        'back_sid': '11b9cb02877746d580c5484512d0928f',
        'next_sid': 'd485263b3ae244a9b35500665b5c759b',
        'chat_sid': 'c9aa92f5a4e04897952d05f30c2aef10'
    },

    # Flow 6: Admin Web & Landing Web
    '612429fdea1b42a1bf9e628883f7e58f': {
        'step_num': 30,
        'title': 'Yönetici Web Portalı — Belge İnceleme (SCR-19)',
        'flow': '6. Yönetici Portalı & Web',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': 'cb00d67723e34ec990786a82d25c77ca',
        'disputes_sid': 'cb00d67723e34ec990786a82d25c77ca',
        'accounts_sid': '5ce8968e2703443ca129c0e7c9e9d145'
    },
    'cb00d67723e34ec990786a82d25c77ca': {
        'step_num': 31,
        'title': 'Yönetici Web Portalı — Şikayet Merkezi (SCR-20)',
        'flow': '6. Yönetici Portalı & Web',
        'back_sid': '612429fdea1b42a1bf9e628883f7e58f',
        'next_sid': '5ce8968e2703443ca129c0e7c9e9d145',
        'documents_sid': '612429fdea1b42a1bf9e628883f7e58f',
        'accounts_sid': '5ce8968e2703443ca129c0e7c9e9d145'
    },
    '5ce8968e2703443ca129c0e7c9e9d145': {
        'step_num': 32,
        'title': 'Yönetici Web Portalı — Hesap Yönetimi (SCR-21)',
        'flow': '6. Yönetici Portalı & Web',
        'back_sid': 'cb00d67723e34ec990786a82d25c77ca',
        'next_sid': '612429fdea1b42a1bf9e628883f7e58f',
        'documents_sid': '612429fdea1b42a1bf9e628883f7e58f',
        'disputes_sid': 'cb00d67723e34ec990786a82d25c77ca'
    },
    '164cd33666284338b929a8325dc5ea20': {
        'step_num': 33,
        'title': 'BiTadilat Tanıtım ve Karşılama Sitesi (SCR-22)',
        'flow': '6. Yönetici Portalı & Web',
        'back_sid': 'cc1f55661a1a4036a890b43d9f15596a',
        'next_sid': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'start_customer': '0c06b06e422b40daacbc0b8e6e8fb7bf',
        'start_pro': '11b9cb02877746d580c5484512d0928f'
    }
}

def clean_and_enhance_screen(sid, spec):
    filepath = os.path.join(screens_dir, f'{sid}.html')
    if not os.path.exists(filepath):
        print(f'Warning: {filepath} does not exist')
        return

    with open(filepath, 'r', encoding='utf-8') as f:
        html = f.read()

    # 1. Remove any previous injected adapter script
    html = re.sub(r'<!-- BiTadilat Interactive Prototype Navigation Adapter -->.*?</body>', '</body>', html, flags=re.DOTALL)
    html = re.sub(r'<!-- BiTadilat Injected Top Breadcrumb -->.*?</div>\s*</div>\s*</div>', '', html, flags=re.DOTALL)

    # 2. Add safe area bottom padding if has fixed bottom
    if 'fixed bottom-0' in html and 'pb-28' not in html and 'pb-32' not in html:
        html = html.replace('class="min-h-screen', 'class="min-h-screen pb-28')
        html = html.replace('class="flex flex-col min-h-screen', 'class="flex flex-col min-h-screen pb-28')

    # 3. Create the robust in-page Navigation Engine
    spec_json = json.dumps(spec, ensure_ascii=False)
    
    injected_js = f'''
<!-- BiTadilat Authoritative Navigation Controller -->
<script>
(function() {{
  const SPEC = {spec_json};
  const CURRENT_SID = "{sid}";

  // Universal Navigation Dispatcher
  window.bitadilatNav = function(targetSid, label) {{
    if (!targetSid) return;
    console.log('[BiTadilat Router] Navigating from', CURRENT_SID, '->', targetSid, '(', label || '', ')');
    
    // Provide instant feedback
    if (window.parent && window.parent !== window) {{
      window.parent.postMessage({{
        type: 'NAVIGATE',
        from: CURRENT_SID,
        to: targetSid,
        label: label || ''
      }}, '*');
    }} else {{
      window.location.href = './' + targetSid + '.html';
    }}
  }};

  document.addEventListener('DOMContentLoaded', function() {{
    
    // 1. Force enable and cursor pointer on all action buttons
    document.querySelectorAll('button, [role="button"], input[type="submit"]').forEach(btn => {{
      btn.style.cursor = 'pointer';
      // If button has disabled attribute, make it interactive for prototype flow
      if (btn.hasAttribute('disabled')) {{
        btn.removeAttribute('disabled');
        btn.classList.remove('pointer-events-none', 'disabled:opacity-40', 'disabled:cursor-not-allowed', 'opacity-60');
      }}
    }});

    // 2. Intercept and bypass all default form submissions that block navigation
    document.querySelectorAll('form').forEach(form => {{
      form.onsubmit = function(e) {{
        e.preventDefault();
        e.stopPropagation();
        if (SPEC.next_sid) {{
          window.bitadilatNav(SPEC.next_sid, 'Form Submit');
        }}
        return false;
      }};
    }});

    // 3. Bind Header Back Buttons
    const backTargets = SPEC.back_sid;
    if (backTargets) {{
      document.querySelectorAll('button, a').forEach(el => {{
        const text = (el.innerText || '').toLowerCase();
        const html = el.innerHTML || '';
        const aria = (el.getAttribute('aria-label') || '').toLowerCase();
        
        if (aria.includes('geri') || text.includes('geri') || text.includes('dön') || 
            html.includes('arrow_back') || html.includes('chevron_left') || html.includes('arrow_back_ios')) {{
          el.onclick = function(e) {{
            e.preventDefault();
            e.stopPropagation();
            window.bitadilatNav(SPEC.back_sid, 'Back Button');
          }};
        }}
      }});
    }}

    // 4. Bind Primary Forward Actions based on specific screen rules
    if (CURRENT_SID === '0c06b06e422b40daacbc0b8e6e8fb7bf') {{
      // Hoş Geldiniz & Rol Seçimi
      let role = 'homeowner';
      const cHomeowner = document.getElementById('role-homeowner') || document.querySelector('[data-role="homeowner"]');
      const cPro = document.getElementById('role-professional') || document.querySelector('[data-role="pro"]');
      const btnCont = document.getElementById('btn-continue') || document.querySelector('button:has-text("devam et")');

      if (cHomeowner) {{
        cHomeowner.onclick = function() {{
          role = 'homeowner';
          if (btnCont) {{
            btnCont.style.backgroundColor = '#0F4C5C';
            btnCont.style.color = '#FFFFFF';
            btnCont.removeAttribute('disabled');
          }}
        }};
      }}

      if (cPro) {{
        cPro.onclick = function() {{
          role = 'pro';
          if (btnCont) {{
            btnCont.style.backgroundColor = '#0F4C5C';
            btnCont.style.color = '#FFFFFF';
            btnCont.removeAttribute('disabled');
          }}
        }};
      }}

      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('devam et') || t.includes('numarasıyla')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            if (role === 'pro') {{
              window.bitadilatNav(SPEC.role_pro, 'Rol: Usta');
            }} else {{
              window.bitadilatNav(SPEC.role_homeowner, 'Rol: Müşteri');
            }}
          }};
        }}
        if (t.includes('giriş yap')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.role_homeowner, 'Giriş Yap');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'fbbe0f405e1f4531a14dcdd6b1c5736a') {{
      // Telefon Doğrulama
      const inp = document.getElementById('phone-input') || document.querySelector('input[type="tel"]');
      if (inp && !inp.value) inp.value = '532 450 88 92';
      
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('devam') || t.includes('gönder') || t.includes('kodu')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Telefon Doğrulandı -> SMS');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '42c148a1fb25400ca549481fa6abe01f') {{
      // SMS Doğrulama
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('doğrula') || t.includes('onayla')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'SMS Doğrulandı -> Ana Sayfa');
          }};
        }}
        if (t.includes('değiştir')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.back_sid, 'Numarayı Değiştir');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'cc1f55661a1a4036a890b43d9f15596a') {{
      // Müşteri Ana Sayfası
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('talep') || t.includes('oluştur') || t.includes('başla')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Yeni Talep Başlat');
          }};
        }}
      }});

      // Category cards click
      document.querySelectorAll('.grid button, .grid > div, [data-category]').forEach(c => {{
        c.style.cursor = 'pointer';
        c.onclick = function() {{
          window.bitadilatNav(SPEC.next_sid, 'Kategori Seçildi -> Adım 1');
        }};
      }});

      // Bottom Tabs
      const tabs = document.querySelectorAll('nav a, footer a, [role="tablist"] a');
      if (tabs.length >= 2) {{
        tabs[1].onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_requests, 'Taleplerim'); }};
      }}
      if (tabs.length >= 3) {{
        tabs[2].onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_messages, 'Mesajlar'); }};
      }}
      if (tabs.length >= 4) {{
        tabs[3].onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_pro, 'Profil / Usta Modu'); }};
      }}
    }}

    else if (CURRENT_SID === '44c003fee81d4a188f187608554efdd5') {{
      // Adım 1
      const cta = document.getElementById('wizard-primary-cta');
      if (cta) {{
        cta.onclick = function(e) {{
          e.preventDefault();
          window.bitadilatNav(SPEC.next_sid, 'Adım 1 -> Adım 2');
        }};
      }}
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('2. adıma') || t.includes('adıma geç') || t.includes('devam et')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Adım 1 -> Adım 2');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'b3c3c2845017451fb1b85b89f04fd4b8') {{
      // Adım 2
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('3. adıma') || t.includes('adıma geç') || t.includes('devam et')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Adım 2 -> Adım 3');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '585d649f4ea046ffa70e4cb481ddd030') {{
      // Adım 3
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('4. adıma') || t.includes('adıma geç') || t.includes('devam et')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Adım 3 -> Adım 4');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'a0949c91cbe34557b16273c8e91d067a') {{
      // Adım 4 - Gözden Geçir & Yayınla
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('yayınla') || t.includes('onayla')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Talebi Yayınla -> Bekleniyor');
          }};
        }}
        if (t.includes('düzenle')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav('44c003fee81d4a188f187608554efdd5', 'Düzenle: Adım 1');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '94a730cef5374f2ab9632d9acf0d7e19') {{
      // Talep Yayınlandı
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklif') || t.includes('gör') || t.includes('taleplerime')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Teklifleri Gör (3)');
          }};
        }}
        if (t.includes('ana sayfa')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav('cc1f55661a1a4036a890b43d9f15596a', 'Ana Sayfaya Dön');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '994e3b4ffce942ce8778f7a6cfaa42c0') {{
      // Gelen Teklifler
      document.querySelectorAll('button, [data-offer-card]').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('karşılaştır')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.compare_sid, 'Teklifleri Karşılaştır');
          }};
        }}
        else if (t.includes('incele') || t.includes('detay') || b.hasAttribute('data-offer-card')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Mavi Hat Tesisat Teklif Detayı');
          }};
        }}
      }});
      // Also make cards clickable
      document.querySelectorAll('.rounded-2xl, .bg-surface').forEach(card => {{
        if ((card.innerText || '').includes('Mavi Hat Tesisat') || (card.innerText || '').includes('Ahmet')) {{
          card.style.cursor = 'pointer';
          card.onclick = function() {{
            window.bitadilatNav(SPEC.next_sid, 'Teklif Kartı -> Detay');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'ea7af2d7298b4b6cb24e4603935503f0') {{
      // Teklif Detayı
      document.querySelectorAll('button, a').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('kabul et') || t.includes('onayla')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Teklifi Kabul Et -> Onay Sayfası');
          }};
        }}
        if (t.includes('soru sor') || t.includes('mesaj')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.chat_sid, 'Ustaya Soru Sor -> Chat');
          }};
        }}
        if (t.includes('profil') || t.includes('hakkında')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.profile_sid, 'Usta Profili');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '1fc70722168942c4a1933cd9c641ad68') {{
      // Karşılaştır
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('incele') || t.includes('seç') || t.includes('detay')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Seçilen Teklif -> Detay');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '98cd20d6ab4e4f8fbc29bc462ce55cca') {{
      // Usta Profili
      document.querySelectorAll('button, a').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklife dön') || t.includes('teklif')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Teklife Dön');
          }};
        }}
        if (t.includes('soru sor')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.chat_sid, 'Ustaya Soru Sor');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '58f9993b5f444ff3a9f9361cb8d3b731') {{
      // Teklif Kabul Onayı
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('kabul et') || t.includes('randevu') || t.includes('onayla')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Kabul Onaylandı -> Randevu Seçimi');
          }};
        }}
        if (t.includes('vazgeç')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.back_sid, 'Vazgeç -> Teklif Detayı');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '7c6ec3a02d3347a997a3fc5b1a2c91d0') {{
      // Randevu Zamanı Seç
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('randevu') && (t.includes('gönder') || t.includes('onayla') || t.includes('talebi'))) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Randevu Talebi Gönderildi');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '3bd2afe80ced4d2498ec9f16c7099326') {{
      // Randevu İletildi
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('iş alanı') || t.includes('detayına git') || t.includes('talep detayına')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'İş Alanına Git');
          }};
        }}
        if (t.includes('ana sayfa')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav('cc1f55661a1a4036a890b43d9f15596a', 'Ana Sayfaya Dön');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'f3e7de808fdb49c18e3c5d430cb72528') {{
      // İş Alanı
      document.querySelectorAll('button, a, div.cursor-pointer').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('mesaj')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.chat_sid, 'Mesajlaşma Ekranı');
          }};
        }}
        if (t.includes('ilerlemesi') || t.includes('aşama')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.milestones_sid, 'İş Aşamaları Takibi');
          }};
        }}
        if (t.includes('değiştir') || t.includes('iptal')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.reschedule_sid, 'Randevu İptal / Değişiklik');
          }};
        }}
        if (t.includes('tamamla') || t.includes('teslim')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'İş Tamamlama ve Teslim Onayı');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'c9aa92f5a4e04897952d05f30c2aef10') {{
      // Mesajlaşma
      const sendBtn = document.querySelector('button:has(.material-symbols-outlined:contains("send"))') || document.querySelector('button.send');
      const msgInput = document.querySelector('input[type="text"]');
      if (sendBtn && msgInput) {{
        sendBtn.onclick = function(e) {{
          e.preventDefault();
          if (msgInput.value) msgInput.value = '';
        }};
      }}
    }}

    else if (CURRENT_SID === 'b89d998c02d34e67b8e8f34334f87f02') {{
      // İş Aşamaları
      document.querySelectorAll('button, a').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('mesaj')) {{
          b.onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Mesajlaş'); }};
        }}
        if (t.includes('sorun') || t.includes('destek') || t.includes('şikayet')) {{
          b.onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.dispute_sid, 'Şikayet Bildir'); }};
        }}
        if (t.includes('teslim') || t.includes('tamamla')) {{
          b.onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teslim Onayına Geç'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '6acc9307352f497ca6bd878d628c6a1a') {{
      // İptal / Değişiklik
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('iptal etmeyi onayla') || t.includes('randevuyu koru')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'İş Alanına Dön');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'd485263b3ae244a9b35500665b5c759b') {{
      // İş Tamamlama ve Teslim Onayı
      document.querySelectorAll('button, a').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('onayla') || t.includes('değerlendirme')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'İşi Onayla -> Puanlama');
          }};
        }}
        if (t.includes('sorun') || t.includes('destek') || t.includes('şikayet')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.dispute_sid, 'Uyuşmazlık Bildir');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'db8a1b368a7749cbb5fd6cf497f34de6') {{
      // Puanlama & Değerlendirme
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('gönder') || t.includes('kaydet') || t.includes('tamamla')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Değerlendirme Gönderildi -> Ana Sayfa');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '488f3698f93c454099ca2382585aeb66') {{
      // Şikayet Bildirimi
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('şikayet') && (t.includes('oluştur') || t.includes('ilet') || t.includes('gönder'))) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Şikayet Oluşturuldu -> Durum Takibi');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '3bb4b954e5224b0097b2bee12be9bcbf') {{
      // Şikayet İletildi
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('ana sayfa') || t.includes('taleplerime')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Ana Sayfaya Dön');
          }};
        }}
        if (t.includes('mesaj')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.chat_sid, 'Mesaj Kayıtları');
          }};
        }}
      }});
    }}

    // Flow 5: Usta (Pro) Screen Handlers
    else if (CURRENT_SID === '11b9cb02877746d580c5484512d0928f') {{
      // Usta Feed
      document.querySelectorAll('button, [data-job-card], .bg-surface').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklif') || t.includes('banyo lavabo') || t.includes('hazırla')) {{
          b.style.cursor = 'pointer';
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Usta Teklif Hazırlama');
          }};
        }}
      }});
      const tabs = document.querySelectorAll('nav a, footer a');
      if (tabs.length >= 2) tabs[1].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_active_jobs, 'İşlerim'); }};
      if (tabs.length >= 3) tabs[2].onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_availability, 'Müsaitlik'); }};
    }}

    else if (CURRENT_SID === 'b9086f1030784def8eb267fd9110addd') {{
      // Usta Teklif Hazırlama
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('teklifi gönder') || t.includes('gönder')) {{
          b.onclick = function(e) {{
            e.preventDefault();
            window.bitadilatNav(SPEC.next_sid, 'Teklif Gönderildi Onayı');
          }};
        }}
      }});
    }}

    else if (CURRENT_SID === '82f9d783b88b40ec8ca6260566c0f5cb') {{
      // Usta Teklif Gönderildi
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('akışına dön') || t.includes('taleplere dön')) {{
          b.onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Taleplere Dön'); }};
        }}
        if (t.includes('müsaitlik')) {{
          b.onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.tab_availability, 'Müsaitlik'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === 'fc6f0f8e9b724365a5a0f124617dbe7a') {{
      // Usta Profil & Müsaitlik
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('talepler') || t.includes('kaydet')) {{
          b.onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Talepler Akışı'); }};
        }}
      }});
    }}

    else if (CURRENT_SID === '8ba8c346d11c46f39163fd6ebf06dae1') {{
      // Usta İş Yürütme
      document.querySelectorAll('button').forEach(b => {{
        const t = (b.innerText || '').toLowerCase();
        if (t.includes('mesaj')) {{
          b.onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.chat_sid, 'Mesaj Yaz'); }};
        }}
        if (t.includes('bitirdim') || t.includes('teslim talebi')) {{
          b.onclick = function(e) {{ e.preventDefault(); window.bitadilatNav(SPEC.next_sid, 'Teslim Onayına Gönder'); }};
        }}
      }});
    }}

    // Flow 6: Admin & Web
    else if (CURRENT_SID === '612429fdea1b42a1bf9e628883f7e58f') {{
      document.querySelectorAll('a, button').forEach(el => {{
        const t = (el.innerText || '').toLowerCase();
        if (t.includes('şikayet') || t.includes('uyuşmazlık')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.disputes_sid, 'Şikayet Merkezi'); }};
        if (t.includes('hesap') || t.includes('kullanıcı')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.accounts_sid, 'Hesap Yönetimi'); }};
      }});
    }}

    else if (CURRENT_SID === 'cb00d67723e34ec990786a82d25c77ca') {{
      document.querySelectorAll('a, button').forEach(el => {{
        const t = (el.innerText || '').toLowerCase();
        if (t.includes('belge') || t.includes('profil') || t.includes('onay')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.documents_sid, 'Belge İnceleme'); }};
        if (t.includes('hesap') || t.includes('kullanıcı')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.accounts_sid, 'Hesap Yönetimi'); }};
      }});
    }}

    else if (CURRENT_SID === '5ce8968e2703443ca129c0e7c9e9d145') {{
      document.querySelectorAll('a, button').forEach(el => {{
        const t = (el.innerText || '').toLowerCase();
        if (t.includes('belge') || t.includes('profil')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.documents_sid, 'Belge İnceleme'); }};
        if (t.includes('şikayet') || t.includes('uyuşmazlık')) el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.disputes_sid, 'Şikayet Merkezi'); }};
      }});
    }}

    else if (CURRENT_SID === '164cd33666284338b929a8325dc5ea20') {{
      document.querySelectorAll('a, button').forEach(el => {{
        const t = (el.innerText || '').toLowerCase();
        if (t.includes('usta çağır') || t.includes('başla') || t.includes('talep')) {{
          el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.start_customer, 'Müşteri Başlat'); }};
        }}
        if (t.includes('usta ol') || t.includes('usta olarak')) {{
          el.onclick = (e) => {{ e.preventDefault(); window.bitadilatNav(SPEC.start_pro, 'Usta Başlat'); }};
        }}
      }});
    }}

  }});
}})();
</script>
'''

    # Insert injected JS before </body>
    if '</body>' in html:
        html = html.replace('</body>', injected_js + '\n</body>')
    else:
        html += injected_js

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(html)
    print(f'Processed [{sid[:8]}] - {spec["title"]}')

for sid, spec in screen_specs.items():
    clean_and_enhance_screen(sid, spec)

print('All 33 screens successfully updated with authoritative navigation handlers!')
