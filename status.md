# markdown status

2026-09-21: native editor installed and tested on Apple Silicon. Both .md and .markdown defaults now resolve to /Applications/markdown.app, verified through Launch Services and actual default opening.

Public guide is live and verified over HTTPS; real screenshots, MIT source and download links work. JCDS deployment registry is committed and pushed (dab4f7f). Site is static nginx, JCDS port 3116, canonical https://markdown.pltfm.ai, dev → prod, no database or secrets. Mac app remains local Swift/AppKit + bundled TOAST UI.

Author: Charles Majola (@chmjdev), verified from public GitHub profile and git identity. Source uses MIT with dependency notices preserved.

Apple accepted notarization submission 92D8D50B-A80F-456F-845F-40BF99AB84AD. Exported universal app has hardened runtime, valid Developer ID signature and stapled ticket; Gatekeeper reports accepted / Notarized Developer ID. Final release ZIP is packaged. Intel code is cross-compiled but not runtime-tested.
