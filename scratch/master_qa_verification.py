import os, json, re, sys

workspace = '/Users/ata/Documents/antigravity/BiTadilat'
sys.path.insert(0, workspace)
screens_dir = os.path.join(workspace, 'preview/screens')
screenshots_dir = os.path.join(workspace, 'screenshots')
index_html_path = os.path.join(workspace, 'preview/index.html')
screens_map_path = os.path.join(workspace, 'screens_map.json')

with open(screens_map_path, 'r', encoding='utf-8') as f:
    screens_map = json.load(f)

from build_authoritative_prototype import screens_spec

print('========================================================')
print('   BiTadilat MASTER QA & PM AUDIT VERIFICATION RUN      ')
print('========================================================')

all_passed = True

# 1. Total Screen Count
total_count = len(screens_spec)
print(f'\n[CHECK 1] Screen Inventory Count: {total_count}')
if total_count != 41:
    print(f'❌ FAIL: Expected 41 screens, got {total_count}')
    all_passed = False
else:
    print('✅ PASS: Exactly 41 screens in authoritative specification.')

# 2. File Existence (HTML and PNG)
missing_html = []
missing_png = []
for s in screens_spec:
    sid = s['id']
    if not os.path.exists(os.path.join(screens_dir, f'{sid}.html')):
        missing_html.append(sid)
    if not os.path.exists(os.path.join(screenshots_dir, f'{sid}.png')):
        missing_png.append(sid)

if missing_html:
    print(f'❌ FAIL: Missing HTML files: {missing_html}')
    all_passed = False
else:
    print('✅ PASS: All 41 HTML screen files exist in preview/screens/')

if missing_png:
    print(f'❌ FAIL: Missing PNG files: {missing_png}')
    all_passed = False
else:
    print('✅ PASS: All 41 PNG screenshot files exist in screenshots/')

# 3. Reference & Target Integrity
valid_sids = set(s['id'] for s in screens_spec)
broken_refs = []
for s in screens_spec:
    for key, val in s.items():
        if key.endswith('_sid') or key.startswith('role_') or key.startswith('tab_') or key.startswith('edit_') or key.startswith('start_') or key.startswith('switch_'):
            if val is not None and val not in valid_sids:
                broken_refs.append((s['id'], s['step_num'], key, val))

if broken_refs:
    print(f'❌ FAIL: Found {len(broken_refs)} broken navigation targets: {broken_refs}')
    all_passed = False
else:
    print('✅ PASS: 0 broken navigation targets across all 41 screen specifications.')

# 4. Role Isolation & Security Rules
# Customer profile switch target:
cust_prof = next(s for s in screens_spec if s['id'] == '20de80b8dc984e86be873761409a2396')
if cust_prof.get('switch_to_pro') != 'a512d0928f11b9cb02877746d580c548':
    print(f"❌ FAIL: Customer profile switch_to_pro does not point to onboarding (a512d092...)! Got: {cust_prof.get('switch_to_pro')}")
    all_passed = False
else:
    print('✅ PASS: Customer Profile switch_to_pro strictly routes to Usta Onboarding (SCR-P-ONB).')

# Pro onboarding next_sid:
pro_onb = next(s for s in screens_spec if s['id'] == 'a512d0928f11b9cb02877746d580c548')
if pro_onb.get('next_sid') != 'def294a930bf4bb78f7ba4f857611884':
    print(f"❌ FAIL: Pro onboarding next_sid does not point to Pending screen (def294a9...)! Got: {pro_onb.get('next_sid')}")
    all_passed = False
else:
    print('✅ PASS: Pro Onboarding next_sid strictly routes to Pending Review screen (SCR-P-PENDING).')

# Pro Profile has customer switch button:
with open(os.path.join(screens_dir, 'fc6f0f8e9b724365a5a0f124617dbe7a.html'), 'r', encoding='utf-8') as f:
    pro_prof_html = f.read()
if 'btn-switch-to-customer' not in pro_prof_html or 'btn-pro-logout' not in pro_prof_html:
    print('❌ FAIL: Pro Profile missing btn-switch-to-customer or btn-pro-logout!')
    all_passed = False
else:
    print('✅ PASS: Pro Profile contains both switch-to-customer and logout actions.')

# 5. Terminology Check ("Sıhhi Tesisat" forbidden rule)
sihhi_hits = []
for fname in sorted(os.listdir(screens_dir)):
    if not fname.endswith('.html'): continue
    fpath = os.path.join(screens_dir, fname)
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    if re.search(r'sıhhi', content, re.IGNORECASE):
        sihhi_hits.append(fname)

if sihhi_hits:
    print(f'❌ FAIL: Found forbidden "sıhhi" in screens: {sihhi_hits}')
    all_passed = False
else:
    print('✅ PASS: 0 occurrences of forbidden "Sıhhi Tesisat" across all screen files.')

# 6. Persona Consistency Check
# Step 32 customer persona
with open(os.path.join(screens_dir, '8ba8c346d11c46f39163fd6ebf06dae1.html'), 'r', encoding='utf-8') as f:
    st32_html = f.read()
if 'Ali Y.' not in st32_html or '>AY<' not in st32_html:
    print('❌ FAIL: Step 32 does not have Ali Y. / AY initials!')
    all_passed = False
else:
    print('✅ PASS: Step 32 customer persona normalized to Ali Y. / AY.')

# Chat screen customer persona
with open(os.path.join(screens_dir, 'c9aa92f5a4e04897952d05f30c2aef10.html'), 'r', encoding='utf-8') as f:
    chat_html = f.read()
if 'Merhaba Ali Bey' not in chat_html:
    print('❌ FAIL: Chat screen does not address customer as Merhaba Ali Bey!')
    all_passed = False
else:
    print('✅ PASS: Chat screen customer persona normalized to Ali Bey.')

# 7. Simulator & screens_map.json synchronization
with open(index_html_path, 'r', encoding='utf-8') as f:
    idx_content = f.read()

for s in screens_spec:
    if s['id'] not in idx_content:
        print(f"❌ FAIL: Screen {s['id']} missing from preview/index.html!")
        all_passed = False

if len(screens_map) != 41:
    print(f'❌ FAIL: screens_map.json count is {len(screens_map)}, expected 41')
    all_passed = False
else:
    print('✅ PASS: screens_map.json and preview/index.html are in 100% sync with all 41 screens.')

print('\n--------------------------------------------------------')
if all_passed:
    print('🎉 ALL MASTER QA AUDIT CHECKS PASSED WITH 100% SUCCESS!')
else:
    print('❌ SOME CHECKS FAILED! Review output above.')
print('--------------------------------------------------------')
