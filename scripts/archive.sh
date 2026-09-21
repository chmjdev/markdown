#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash build.sh
xcodegen generate
xcodebuild -project markdown.xcodeproj -scheme markdown -configuration Release -destination 'generic/platform=macOS' -derivedDataPath build/DerivedData -archivePath build/markdown.xcarchive archive
codesign --verify --deep --strict build/markdown.xcarchive/Products/Applications/markdown.app
