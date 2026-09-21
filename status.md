# markdown status

2026-09-21: native editor installed and tested on Apple Silicon. Both .md and .markdown defaults now resolve to /Applications/markdown.app, verified through Launch Services and actual default opening.

Public guide and universal preview ZIP are implemented locally; production is not yet verified. Site is static nginx, JCDS port 3116, canonical https://markdown.pltfm.ai, dev → prod, no database or secrets. Mac app remains local Swift/AppKit + bundled TOAST UI.

Author: Charles Majola (@chmjdev), verified from public GitHub profile and git identity. Source uses MIT with dependency notices preserved.

Developer ID certificate is now installed, universal archive is signed with hardened runtime, and Apple notarization submission 92D8D50B-A80F-456F-845F-40BF99AB84AD is Processing. The current ZIP is an explicitly labeled ad-hoc preview; Intel code is cross-compiled but not runtime-tested.
