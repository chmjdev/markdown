from pathlib import Path
p = Path(__file__).parent
original = (p / 'roundtrip.md').read_bytes()
assert (p / 'roundtrip-untouched.md').read_bytes() == original
saved = (p / 'roundtrip-edited.md').read_text()
for token in ['# Round-trip test', '## Lists', '**bold**', '*italic*', '[link](https://example.com)', '`inline code`', '* First item', '    * Nested item', '1. One', '2. Two', '> A quoted paragraph.', '```swift\nlet greeting = "Hello"\nprint(greeting)\n```', '* [ ] Pending', '* [x] Complete', '| Markdown | Local |', 'café — 日本語 🎉', '**Rapid save captures every character.**']:
    assert token in saved, token
assert '~~' not in saved
assert (p / 'new-document.markdown').read_text() == 'New document saved successfully.'
assert (p / 'installed-test.md').read_text() == 'Installed app save verified.'
print('PASS: untouched bytes; common formatting; full rapid-save text; new file; discarded edit absent')
