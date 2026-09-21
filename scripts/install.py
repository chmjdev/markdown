from pathlib import Path
import plistlib
import shutil
bundle_id = 'app.jola.markdown'
target = Path('/Applications/markdown.app')
existing = []
for root in [Path('/Applications'), Path.home() / 'Applications']:
    for candidate in root.glob('*.app'):
        info_path = candidate / 'Contents/Info.plist'
        try:
            info = plistlib.loads(info_path.read_bytes())
        except Exception:
            continue
        if info.get('CFBundleIdentifier') == bundle_id:
            existing.append(candidate)
if target.exists() and target not in existing:
    raise SystemExit('Refusing to replace an unrelated /Applications/markdown.app')
for candidate in existing:
    shutil.rmtree(candidate)
shutil.copytree('build/markdown.app', target)
