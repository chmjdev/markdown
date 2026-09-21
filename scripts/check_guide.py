from pathlib import Path
from html.parser import HTMLParser
import json
root = Path(__file__).resolve().parent.parent
class GuideParser(HTMLParser):
    ids = set()
    anchors = []
    assets = []
    viewport = False
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            assert attrs['id'] not in self.ids, 'Duplicate id'
            self.ids.add(attrs['id'])
        if tag == 'a' and attrs.get('href', '').startswith('#'):
            self.anchors.append(attrs['href'][1:])
        if tag == 'link' and attrs.get('href', '').startswith('/'):
            self.assets.append(attrs['href'])
        if tag == 'meta' and attrs.get('name') == 'viewport':
            self.viewport = True
parser = GuideParser()
page = (root / 'public/index.html').read_text()
parser.feed(page)
assert parser.viewport
assert set(parser.anchors).issubset(parser.ids)
for asset in parser.assets:
    assert (root / 'public' / asset.lstrip('/')).is_file(), asset
assert (root / 'public/healthz').read_text() == 'markdown guide ok\n'
config = json.loads((root / 'jcds.config').read_text())
assert config['supported_stages'] == ['dev', 'prod']
assert config['domains']['uat'] == ''
for stage in config['supported_stages']:
    assert 1024 < config['ports'][stage] < 65536
assert '/Users/' not in page
assert 'https://markdown.pltfm.ai/' in page
print('PASS: guide assets, navigation targets, viewport, health content, stage and port configuration')
