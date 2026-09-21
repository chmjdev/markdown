#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
bash build.sh
python3 scripts/install.py
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/markdown.app
printf '%s\n' 'Installed /Applications/markdown.app'
