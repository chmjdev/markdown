#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build/markdown.app/Contents/MacOS build/markdown.app/Contents/Resources/web
node_modules/.bin/esbuild web/editor.js --bundle --minify --outfile=build/markdown.app/Contents/Resources/web/editor.js --loader:.woff=file --loader:.ttf=file
cp web/index.html build/markdown.app/Contents/Resources/web/index.html
swift scripts/icon.swift build/AppIcon.iconset
iconutil -c icns build/AppIcon.iconset -o build/markdown.app/Contents/Resources/AppIcon.icns
cp THIRD-PARTY-NOTICES.txt LICENSE.txt build/markdown.app/Contents/Resources/
cp Info.plist build/markdown.app/Contents/Info.plist
for MARKDOWN_ARCH in arm64 x86_64; do
    swiftc Sources/main.swift -o "build/markdown-${MARKDOWN_ARCH}" -framework AppKit -framework WebKit -framework UniformTypeIdentifiers -target "${MARKDOWN_ARCH}-apple-macosx13.0"
done
lipo -create build/markdown-arm64 build/markdown-x86_64 -output build/markdown.app/Contents/MacOS/markdown
codesign --force --sign - build/markdown.app
codesign --verify --strict build/markdown.app
