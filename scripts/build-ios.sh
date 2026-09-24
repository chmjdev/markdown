#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p ios/Resources/web
node scripts/build-web.mjs ios/Web/editor.js ios/Resources/web/editor.js
cp ios/Web/index.html ios/Resources/web/index.html
swift ios/icon.swift
xcodegen generate --spec ios/project.yml
