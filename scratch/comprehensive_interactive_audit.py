import os, re, json, sys

workspace = '/Users/ata/Documents/antigravity/BiTadilat'
sys.path.insert(0, workspace)
screens_dir = os.path.join(workspace, 'preview/screens')

from build_authoritative_prototype import screens_spec

report = []

for s in screens_spec:
    sid = s['id']
    fpath = os.path.join(screens_dir, f'{sid}.html')
    if not os.path.exists(fpath):
        continue
    with open(fpath, 'r', encoding='utf-8') as f:
        html = f.read()

    screen_data = {
        'step_num': s['step_num'],
        'id': sid,
        'title': s['title'],
        'role': s['role'],
        'flow': s['flow'],
        'buttons': [],
        'inputs': [],
        'textareas': [],
        'links': [],
        'interactive_cards': [],
        'controller_handled': []
    }

    # Extract controller script
    controller_match = re.search(r'<!-- BiTadilat Authoritative Navigation Controller -->.*?<script>(.*?)</script>', html, re.DOTALL)
    controller_code = controller_match.group(1) if controller_match else ""

    # Buttons
    for m in re.finditer(r'<button\b([^>]*)>(.*?)</button>', html, re.DOTALL | re.IGNORECASE):
        attrs = m.group(1)
        body = m.group(2)
        # clean body
        clean_text = re.sub(r'<[^>]+>', ' ', body).strip()
        clean_text = ' '.join(clean_text.split())
        aria = re.search(r'aria-label="([^"]*)"', attrs)
        bid = re.search(r'id="([^"]*)"', attrs)
        screen_data['buttons'].append({
            'text': clean_text,
            'aria_label': aria.group(1) if aria else None,
            'id': bid.group(1) if bid else None,
            'attrs': attrs
        })

    # Inputs
    for m in re.finditer(r'<input\b([^>]*)>', html, re.IGNORECASE):
        attrs = m.group(1)
        itype = re.search(r'type="([^"]*)"', attrs)
        iid = re.search(r'id="([^"]*)"', attrs)
        iplace = re.search(r'placeholder="([^"]*)"', attrs)
        ival = re.search(r'value="([^"]*)"', attrs)
        screen_data['inputs'].append({
            'type': itype.group(1) if itype else 'text',
            'id': iid.group(1) if iid else None,
            'placeholder': iplace.group(1) if iplace else None,
            'value': ival.group(1) if ival else None
        })

    # Textareas
    for m in re.finditer(r'<textarea\b([^>]*)>(.*?)</textarea>', html, re.DOTALL | re.IGNORECASE):
        attrs = m.group(1)
        body = m.group(2)
        tid = re.search(r'id="([^"]*)"', attrs)
        tplace = re.search(r'placeholder="([^"]*)"', attrs)
        screen_data['textareas'].append({
            'id': tid.group(1) if tid else None,
            'placeholder': tplace.group(1) if tplace else None,
            'initial_text': body.strip()
        })

    # Links
    for m in re.finditer(r'<a\b([^>]*)>(.*?)</a>', html, re.DOTALL | re.IGNORECASE):
        attrs = m.group(1)
        body = m.group(2)
        href = re.search(r'href="([^"]*)"', attrs)
        clean_text = re.sub(r'<[^>]+>', ' ', body).strip()
        clean_text = ' '.join(clean_text.split())
        screen_data['links'].append({
            'text': clean_text,
            'href': href.group(1) if href else None
        })

    report.append(screen_data)

print(f'Catalogued interactive elements for all {len(report)} screens.')

# Save to json for deep inspection
with open(os.path.join(workspace, 'scratch/interactive_elements_catalog.json'), 'w', encoding='utf-8') as f:
    json.dump(report, f, ensure_ascii=False, indent=2)

print('Saved scratch/interactive_elements_catalog.json')
