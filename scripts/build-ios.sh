#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p ios/Resources/web
node scripts/build-ios-web.mjs
cp ios/Web/index.html ios/Resources/web/index.html
swift ios/icon.swift
xcodegen generate --spec ios/project.yml
