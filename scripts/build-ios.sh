#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p ios/Resources/web
node_modules/.bin/esbuild ios/Web/editor.js --bundle --minify --outfile=ios/Resources/web/editor.js --loader:.woff=file --loader:.ttf=file
cp ios/Web/index.html ios/Resources/web/index.html
swift ios/icon.swift
xcodegen generate --spec ios/project.yml
