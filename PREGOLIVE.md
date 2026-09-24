# Public guide release gate

Scope: static markdown user guide and real signed Mac download, not a hosted editor.

- [x] Explicit user authorization for public guide, binary download, public MIT source and Charles Majola attribution.
- [x] JCDS registry allocated port 3116; canonical production URL markdown.pltfm.ai, dev → prod only, UAT null in registry and absent in manifest.
- [x] No database, credentials, accounts, simulated services, or private documents in the guide.
- [x] Docker image copies only public assets and nginx configuration; app sources and local files are not served.
- [x] Production publishes only 127.0.0.1 on the manifest port, with Docker restart policy and health check.
- [x] Real static /healthz; missing files return 404 instead of SPA success.
- [x] Native app UI and Markdown round-trip checks recorded in tests/VALIDATION.md.
- [x] Universal arm64/x86_64 build, ZIP integrity/extraction and code-signature verification.
- [x] Developer ID signature, Apple notarization, stapled ticket and Gatekeeper acceptance verified. Intel slice built but not runtime-tested.
- [x] Desktop 1440px and mobile 375px guide checked in browser; no horizontal overflow, all eight navigation targets and download/license links present. Download metadata matches local archive.
- [x] Source/asset inspection and public MIT repository push; GitHub reports PUBLIC and MIT.
- [x] JCDS standards clean. Release covers the public guide and notarized app.
- [x] Public HTTPS page, health route, preview download/checksum verification, and pushed deployment registry.
- [x] Final notarized download retrieved over HTTPS after deployment; SHA-256 e509054f4c00f1be231140d765f52779e97bd84378692dce62b51b0a16d277c0 matches local release. ZIP integrity passed. Both screenshots HTTP 200; health route HTTP 200.

Developer ID certificate created through Xcode after user account sign-in. Hardened-runtime universal archive succeeded and was uploaded via Direct Distribution to Apple notary service, submission 92D8D50B-A80F-456F-845F-40BF99AB84AD. Apple accepted the submission. Exported app passed codesign, stapler, spctl and both-architecture validation.

## Mac 1.0.1 — 24 September 2026

- [x] Sanitizer replaced (DOMPurify 3.4.15, no 2.3.3) and checked against hostile HTML in the release bundle.
- [x] Developer ID signature, Apple notarization (B15623FD-86E9-4CB3-84EC-5A15CFB35D01), stapled ticket, Gatekeeper acceptance and both architecture slices verified.
- [x] Installed-app round trip, save and unchanged-bytes checks passed on Apple Silicon. Intel not runtime-tested.
- [x] Guide checks pass; download link, version text and SHA-256 updated to 1.0.1; 1.0.0 ZIP kept at its URL.
- [ ] Deployed through JCDS and the public ZIP's SHA-256 verified over HTTPS.
