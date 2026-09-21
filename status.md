# markdown status

2026-09-21: native editor installed and tested on Apple Silicon. Both .md and .markdown defaults now resolve to /Applications/markdown.app, verified through Launch Services and actual default opening.

Public guide is live and verified over HTTPS; real screenshots, MIT source and download links work. JCDS deployment registry is committed and pushed (dab4f7f). Site is static nginx, JCDS port 3116, canonical https://markdown.pltfm.ai, dev → prod, no database or secrets. Mac app remains local Swift/AppKit + bundled TOAST UI.

Author: Charles Majola (@chmjdev), verified from public GitHub profile and git identity. Source uses MIT with dependency notices preserved.

Apple accepted notarization submission 92D8D50B-A80F-456F-845F-40BF99AB84AD. Exported universal app has hardened runtime, valid Developer ID signature and stapled ticket; Gatekeeper reports accepted / Notarized Developer ID. Final release ZIP is live at https://markdown.pltfm.ai/downloads/markdown-1.0.0-universal.zip and its public SHA-256 matches the local package. Signed release installed and launch/save tested. Intel code is cross-compiled but not runtime-tested.


2026-09-21 10:23 SAST: native iPhone/iPad app version 1.0.0 (2) submitted to Apple App Review. App Store Connect confirms 1 Item Submitted and Waiting for Review; not approved or live yet. Public source, actual phone/tablet screenshots and validation evidence are in ios/. Initial availability is 148 territories outside the EU, free, Productivity, 4+, Data Not Collected. See ios/AppStore/release-status.md. Mac release and its checksum are preserved.
