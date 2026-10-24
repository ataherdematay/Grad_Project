import json
import os

updates = [
    ('b3c3c2845017451fb1b85b89f04fd4b8', '/Users/ata/.gemini/antigravity/brain/da675b94-79e9-43ed-a31b-bdc008dd7598/.system_generated/steps/2294/output.txt'),
    ('44c003fee81d4a188f187608554efdd5', '/Users/ata/.gemini/antigravity/brain/da675b94-79e9-43ed-a31b-bdc008dd7598/.system_generated/steps/2298/output.txt'),
    ('20de80b8dc984e86be873761409a2396', '/Users/ata/.gemini/antigravity/brain/da675b94-79e9-43ed-a31b-bdc008dd7598/.system_generated/steps/2302/output.txt'),
    ('8ba8c346d11c46f39163fd6ebf06dae1', '/Users/ata/.gemini/antigravity/brain/da675b94-79e9-43ed-a31b-bdc008dd7598/.system_generated/steps/2306/output.txt'),
    ('164cd33666284338b929a8325dc5ea20', '/Users/ata/.gemini/antigravity/brain/da675b94-79e9-43ed-a31b-bdc008dd7598/.system_generated/steps/2282/output.txt'),
]

for sid, txt_path in updates:
    with open(txt_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    html_content = data.get('html', '')
    dest_path = f'/Users/ata/Documents/antigravity/BiTadilat/preview/screens/{sid}.html'
    with open(dest_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f'Successfully updated preview/screens/{sid}.html with official Stitch HTML (length {len(html_content)})')

print('All 5 official Stitch screens applied!')
