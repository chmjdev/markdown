#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ "$#" -ne 1 ]; then printf '%s\n' 'Usage: bash scripts/release.sh /path/to/exported/markdown.app'; exit 2; fi
MARKDOWN_RELEASE_APP="$1"
codesign --verify --deep --strict "$MARKDOWN_RELEASE_APP"
xcrun stapler validate "$MARKDOWN_RELEASE_APP"
spctl --assess --type execute --verbose=2 "$MARKDOWN_RELEASE_APP"
lipo -verify_arch arm64 x86_64 "$MARKDOWN_RELEASE_APP/Contents/MacOS/markdown"
mkdir -p public/downloads
MARKDOWN_VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$MARKDOWN_RELEASE_APP/Contents/Info.plist")
MARKDOWN_ARCHIVE="public/downloads/markdown-${MARKDOWN_VERSION}-universal.zip"
ditto -c -k --sequesterRsrc --keepParent "$MARKDOWN_RELEASE_APP" "$MARKDOWN_ARCHIVE"
shasum -a 256 "$MARKDOWN_ARCHIVE" | sed 's@public/downloads/@@' > "${MARKDOWN_ARCHIVE}.sha256"
unzip -t "$MARKDOWN_ARCHIVE" >/dev/null
printf '%s\n' "$MARKDOWN_ARCHIVE"
