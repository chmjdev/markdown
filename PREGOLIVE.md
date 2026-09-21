# Public guide release gate

Scope: static markdown user guide and real Mac preview download, not a hosted editor.

- [x] Explicit user authorization for public guide, binary download, public MIT source and Charles Majola attribution.
- [x] JCDS registry allocated port 3116; canonical production URL markdown.pltfm.ai, dev → prod only, UAT null in registry and absent in manifest.
- [x] No database, credentials, accounts, simulated services, or private documents in the guide.
- [x] Docker image copies only public assets and nginx configuration; app sources and local files are not served.
- [x] Production publishes only 127.0.0.1 on the manifest port, with Docker restart policy and health check.
- [x] Real static /healthz; missing files return 404 instead of SPA success.
- [x] Native app UI and Markdown round-trip checks recorded in tests/VALIDATION.md.
- [x] Universal arm64/x86_64 build, ZIP integrity/extraction and code-signature verification.
- [x] Distribution limitation disclosed next to download: ad-hoc signed, not notarized, Gatekeeper rejected. Intel slice built but not runtime-tested.
- [x] Desktop 1440px and mobile 375px guide checked in browser; no horizontal overflow, all eight navigation targets and download/license links present. Download metadata matches local archive.
- [ ] Source/asset inspection and public MIT repository push.
- [ ] JCDS standards clean and release marked before deploy.
- [ ] Public HTTPS page, health route, download/checksum verification, and pushed deployment registry.

Trusted public app signing remains a separate blocker: Xcode currently has no signed-in account; user action is needed to sign in to the paid developer team. An Apple Development certificate is not a Developer ID Application certificate. No security bypass is part of these instructions.
