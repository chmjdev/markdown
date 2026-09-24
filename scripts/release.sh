#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ "$#" -ne 1 ]; then printf '%s\n' 'Usage: bash scripts/release.sh /path/to/exported/markdown.app'; exit 2; fi
MARKDOWN_RELEASE_APP="$1"
codesign --verify --deep --strict "$MARKDOWN_RELEASE_APP"
xcrun stapler validate "$MARKDOWN_RELEASE_APP"
spctl --assess --type execute --verbose=2 "$MARKDOWN_RELEASE_APP"
# Xcode 27's lipo rejects -verify_arch with multiple architectures; check the list instead.
MARKDOWN_ARCHS=" $(lipo -archs "$MARKDOWN_RELEASE_APP/Contents/MacOS/markdown") "
case "$MARKDOWN_ARCHS" in *" arm64 "*) ;; *) printf '%s\n' 'Missing arm64 slice'; exit 1;; esac
case "$MARKDOWN_ARCHS" in *" x86_64 "*) ;; *) printf '%s\n' 'Missing x86_64 slice'; exit 1;; esac
mkdir -p public/downloads
MARKDOWN_VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$MARKDOWN_RELEASE_APP/Contents/Info.plist")
MARKDOWN_ARCHIVE="public/downloads/markdown-${MARKDOWN_VERSION}-universal.zip"
ditto -c -k --sequesterRsrc --keepParent "$MARKDOWN_RELEASE_APP" "$MARKDOWN_ARCHIVE"
shasum -a 256 "$MARKDOWN_ARCHIVE" | sed 's@public/downloads/@@' > "${MARKDOWN_ARCHIVE}.sha256"
unzip -t "$MARKDOWN_ARCHIVE" >/dev/null
python3 scripts/update_download.py "$MARKDOWN_ARCHIVE"
printf '%s\n' "$MARKDOWN_ARCHIVE"
