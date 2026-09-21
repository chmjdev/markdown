#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash build.sh
mkdir -p public/downloads
MARKDOWN_VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Info.plist)
MARKDOWN_ARCHIVE="public/downloads/markdown-${MARKDOWN_VERSION}-universal-preview.zip"
ditto -c -k --sequesterRsrc --keepParent build/markdown.app "$MARKDOWN_ARCHIVE"
shasum -a 256 "$MARKDOWN_ARCHIVE" | sed 's@public/downloads/@@' > "${MARKDOWN_ARCHIVE}.sha256"
unzip -t "$MARKDOWN_ARCHIVE" >/dev/null
lipo -archs build/markdown.app/Contents/MacOS/markdown
codesign --verify --strict build/markdown.app
python3 scripts/update_download.py
printf '%s\n' "$MARKDOWN_ARCHIVE"
