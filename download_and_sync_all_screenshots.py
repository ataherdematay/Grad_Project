import os, json, urllib.request, subprocess

screenshots_dir = '/Users/ata/Documents/antigravity/BiTadilat/screenshots'
os.makedirs(screenshots_dir, exist_ok=True)

# Load screens_map.json
with open('/Users/ata/Documents/antigravity/BiTadilat/screens_map.json', 'r', encoding='utf-8') as f:
    screens_map = json.load(f)

# Collect all Stitch screenshot URLs from captured step outputs
stitch_urls = {}

# 1. from list_screens (step 910)
try:
    with open('/Users/ata/.gemini/antigravity/brain/da675b94-79e9-43ed-a31b-bdc008dd7598/.system_generated/steps/910/output.txt') as f:
        d = json.load(f)
    for s in d.get('screens', []):
        name = s.get('name', '')
        sid = name.split('/')[-1] if name else ''
        durl = s.get('screenshot', {}).get('downloadUrl')
        if sid and durl:
            stitch_urls[sid] = durl
except Exception as e:
    print('Step 910 error:', e)

# 2. from step 884 and 898 (newly generated screens)
for st in [884, 898]:
    try:
        with open(f'/Users/ata/.gemini/antigravity/brain/da675b94-79e9-43ed-a31b-bdc008dd7598/.system_generated/steps/{st}/output.txt') as f:
            d = json.load(f)
        for s in d['outputComponents'][0]['design'].get('screens', []):
            name = s.get('name', '')
            sid = name.split('/')[-1] if name else ''
            durl = s.get('screenshot', {}).get('downloadUrl')
            if sid and durl:
                stitch_urls[sid] = durl
    except Exception as e:
        print(f'Step {st} error:', e)

print(f'Total Stitch URLs gathered: {len(stitch_urls)}')

chrome_bin = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'

for s in screens_map:
    sid = s['id']
    step_num = s['step_num']
    # sanitize title for filename
    clean_title = s['title'].replace(' ', '_').replace('—', '-').replace('&', 've').replace('/', '-').replace(':', '')
    clean_title = ''.join(c for c in clean_title if c.isalnum() or c in '_-')
    out_name = f'{step_num:02d}_{clean_title}.png'
    out_path = os.path.join(screenshots_dir, out_name)
    sid_path = os.path.join(screenshots_dir, f'{sid}.png')

    if sid in stitch_urls:
        url = stitch_urls[sid]
        print(f'Downloading [{step_num:02d}] {s["title"]} from Stitch...')
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=15) as resp:
                data = resp.read()
            with open(out_path, 'wb') as f:
                f.write(data)
            with open(sid_path, 'wb') as f:
                f.write(data)
            print(f'  ✓ Saved {len(data)} bytes -> {out_name}')
            continue
        except Exception as e:
            print(f'  Download failed: {e}, falling back to Chrome render...')

    # Fallback to Chrome headless render
    print(f'Rendering [{step_num:02d}] {s["title"]} via Headless Chrome...')
    html_file = f'/Users/ata/Documents/antigravity/BiTadilat/preview/screens/{sid}.html'
    if not os.path.exists(html_file):
        print(f'  Error: {html_file} does not exist!')
        continue

    is_desktop = (s.get('device') == 'DESKTOP')
    w, h = (1200, 820) if is_desktop else (390, 844)
    cmd = [
        chrome_bin,
        '--headless',
        '--disable-gpu',
        '--no-sandbox',
        f'--window-size={w},{h}',
        f'--screenshot={out_path}',
        f'file://{html_file}'
    ]
    subprocess.run(cmd, check=True)
    # copy to sid_path
    with open(out_path, 'rb') as f_in, open(sid_path, 'wb') as f_out:
        f_out.write(f_in.read())
    print(f'  ✓ Rendered {out_name}')

print('\nAll 37 screenshots successfully gathered and saved in /screenshots/ !')
