import os

screens_dir = 'preview/screens'

# 1. Update ea7af2d7298b4b6cb24e4603935503f0.html
fp1 = os.path.join(screens_dir, 'ea7af2d7298b4b6cb24e4603935503f0.html')
with open(fp1, 'r', encoding='utf-8') as f:
    c1 = f.read()

c1 = c1.replace('<span class="font-body-md-medium text-on-surface">₺1.500</span>', '<span class="font-body-md-medium text-on-surface">₺1.650</span>')
c1 = c1.replace('<span class="font-body-md-medium text-on-surface">₺950</span>', '<span class="font-body-md-medium text-on-surface">₺800</span>')

reject_btn_html = '''
<button class="w-full mt-2 h-10 bg-transparent hover:bg-surface-disabled text-alert-red font-label-md text-label-md rounded-lg flex items-center justify-center gap-1 transition-colors" id="rejectOfferBtn" type="button">
  <span class="material-symbols-outlined text-[16px]">close</span>
  <span>Teklifi Reddet</span>
</button>
'''

if 'id="rejectOfferBtn"' not in c1:
    idx = c1.find('id="acceptOfferBtn"')
    if idx != -1:
        close_btn_idx = c1.find('</button>', idx)
        if close_btn_idx != -1:
            c1 = c1[:close_btn_idx+9] + reject_btn_html + c1[close_btn_idx+9:]
            print('Added reject button to ea7af2d7')

with open(fp1, 'w', encoding='utf-8') as f:
    f.write(c1)

# 2. Update 58f9993b5f444ff3a9f9361cb8d3b731.html
fp2 = os.path.join(screens_dir, '58f9993b5f444ff3a9f9361cb8d3b731.html')
with open(fp2, 'r', encoding='utf-8') as f:
    c2 = f.read()

c2 = c2.replace('<span class="font-body-md-medium text-on-surface">₺1.500</span>', '<span class="font-body-md-medium text-on-surface">₺1.650</span>')
c2 = c2.replace('<span class="font-body-md-medium text-on-surface">₺950</span>', '<span class="font-body-md-medium text-on-surface">₺800</span>')

with open(fp2, 'w', encoding='utf-8') as f:
    f.write(c2)

print('Price breakdowns and reject button updated successfully!')

# 3. Add Switch Role and Logout to fc6f0f8e9b724365a5a0f124617dbe7a.html
fp3 = os.path.join(screens_dir, 'fc6f0f8e9b724365a5a0f124617dbe7a.html')
with open(fp3, 'r', encoding='utf-8') as f:
    c3 = f.read()

pro_extra_buttons = '''
<div class="mt-4 pt-3 border-t border-border-subtle flex flex-col gap-2.5">
  <button id="btn-switch-to-customer" class="w-full h-11 bg-surface hover:bg-canvas text-primary border border-border-subtle rounded-xl font-body-md-medium text-body-md flex items-center justify-center gap-2 active:scale-98 transition-all" type="button">
    <span class="material-symbols-outlined text-[18px] text-info-blue">switch_account</span>
    <span>Müşteri Moduna Geç</span>
  </button>
  <button id="btn-pro-logout" class="w-full h-10 bg-transparent hover:bg-surface-disabled text-alert-red font-label-md text-label-md rounded-xl flex items-center justify-center gap-1.5 transition-colors" type="button">
    <span class="material-symbols-outlined text-[18px]">logout</span>
    <span>Çıkış Yap</span>
  </button>
</div>
'''

if 'id="btn-switch-to-customer"' not in c3:
    idx = c3.find('<span>Ayarları ve Müsaitliği Güncelle</span>')
    if idx != -1:
        close_btn_idx = c3.find('</button>', idx)
        if close_btn_idx != -1:
            c3 = c3[:close_btn_idx+9] + pro_extra_buttons + c3[close_btn_idx+9:]
            print('Added switch to customer and logout to fc6f0f8e')

with open(fp3, 'w', encoding='utf-8') as f:
    f.write(c3)
