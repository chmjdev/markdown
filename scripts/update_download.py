from pathlib import Path
import hashlib, re
root = Path(__file__).resolve().parent.parent
archive = root / 'public/downloads/markdown-1.0.0-universal-preview.zip'
digest = hashlib.sha256(archive.read_bytes()).hexdigest()
page = root / 'public/index.html'
text = page.read_text()
text, count = re.subn(r'(<code id="download-sha256">)[a-f0-9]+(</code>)', lambda m: m[1] + digest + m[2], text)
assert count == 1
text = re.sub(r'· [0-9.]+ MB ZIP', f'· {archive.stat().st_size / 1024 / 1024:.2f} MB ZIP', text)
page.write_text(text)
for name in ['LICENSE.txt', 'THIRD-PARTY-NOTICES.txt']:
    (root / 'public/downloads' / name).write_bytes((root / name).read_bytes())
print('Download metadata updated:', digest)
