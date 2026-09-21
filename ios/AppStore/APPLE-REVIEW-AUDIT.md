# App Store release audit - 21 September 2026

Scope: markdown 1.0.0 for iPhone/iPad. Apple makes the final approval decision. This is a dated evidence checklist, not a guarantee or legal certification. Final archive/upload follows closure of identified defects and development checks.

## Applicable requirements and evidence

| Area | Applicability and evidence | Gate |
|---|---|---|
| Completeness and stability (2.1) | Native Files browser, UIDocument, native source editor, locally bundled visual editor. Prior iPhone/iPad persistence, modes, undo/redo and sharing passed. Post-change iPhone and iPad tests passed. | Passed: iPhone checks and iPad full5-test suite |
| Developer contact (1.5) | Public HTTPS Support URL now lists developer email verified independently on public GitHub profile; GitHub issues also enabled. No private review details published. | Website verified |
| Privacy link (5.1.1) | ASC policy URL verified; submitted build2 About URL was plain text. Replaced with always-visible native Privacy/Support buttons and detected inline links. Actual page navigation passed on both simulators and a physical iPhone16Pro (iOS27). | Passed on physical iPhone and iPhone/iPad simulators; manual return navigation verified on iPhone |
| Privacy disclosures (5.1) | No accounts, ads, tracking, app analytics, document uploads or app cloud backend. Nonpersistent WKWebView, usageStatistics=false, CSP disallows network connections/images. User-selected Files providers and sharing explained separately. Website/support processing and retention/deletion explained. | Source and website verified |
| Privacy manifests and SDKs | PrivacyInfo.xcprivacy declares no tracking/collection/accessed API categories. No direct calls to Apple's required-reason timestamp, boot-time, disk-space, active-keyboard or UserDefaults APIs found in app source. Native dependencies are Apple frameworks; TOAST UI/ProseMirror/DOMPurify are bundled JavaScript, not listed native SDKs. Final archive will be checked. | Archive check pending |
| Dependency security (1.6/2.5) | Found embedded DOMPurify2.3.3 despite npm override. iOS bundler now replaces embedded sanitizer with pinned3.4.15; build asserts new version and no old version. npm audit reports0 vulnerabilities. CSP remains restrictive. | Passed on iPhone and iPad |
| Minimum functionality (4.2) | Native file creation/open/edit/save and export; the product is a document editor, not a web-page wrapper. | Verified design |
| Public APIs and bundled code (2.5) | UIKit, WebKit, UniformTypeIdentifiers and SafariServices only; no downloaded executable application code, background modes or private APIs. | Source verified |
| Device compatibility (2.4) | iPhone and iPad targeted; iOS/iPadOS17 minimum; portrait and landscape. iOS-on-Mac and VisionPro distribution both off. | Passed: iPhone/iPad portrait; iPad landscape and native new-document reopening visually checked |
| Store metadata (2.3) | Safari ASC verified title, subtitle, bundle, Productivity, EnglishUK and 4+ rating. Existing real iPhone/iPad editing screenshots fit supported screenshot slots. No purchase or account claims; normalization/UTF8 limitations in description. | Verified; final selected build pending |
| Public pages/URLs (2.1/2.3) | Support and Privacy metadata URLs exactly match live HTTPS routes. Home/support/privacy/style/health/license/notices/MacZIP returned200; bytes match deployed8ff3f49. Mobile375px no horizontal overflow on all3pages, desktop1440 visual inspection. Contact mailto correct. | Passed |
| Price and territories | Free pricing configured; fresh ASC shows148available/27unavailable, all27EU countries explicitly checked. Publicdistribution. No unapproved trader attestation. | Passed: current configured price rows show zero |
| Review access | No account/demo credentials needed. Welcome provides a sample; private contact previously user-confirmed in ASC only. Review notes explain offline Files workflows. | Verified; update link notes pending |
| Ownership/licenses (5.2) | Charles Majola MIT copyright; official TOAST3.2.2MIT notice added, DOMPurify3.4.15Apache/MPL and dependency notices bundled. | Verified source; archive pending |
| Accessibility declarations | Native controls have labels; optional AppStore feature labels must not claim unverified VoiceOver/LargerText support. No assertion of exhaustive accessibility certification. | Passed: ASC Get Started state, no published support claims |
| Signing/export/packaging | Existing build2 uploaded/processed. Xcode26.6 iOS26.5SDK; build3 uses samebundle/team/minimumOS. Export uses Apple tools and systemPATH. | Final archive/upload pending |

## Not applicable to this product

No hosted social/user-generated content platform, in-app purchases/subscriptions, advertising, login/account creation, social authentication, tracking/ATT, health/financial/gambling/crypto/regulated content, Kids category, camera/microphone/location/contact permissions, push notifications, background services, AppClips, extensions, generative-AI service, or third-party AI transmission. Local user-selected documents are not an app-operated publishing service. No account-deletion flow is required because the app has no accounts; document deletion remains available through Files/Finder. EU trader declarations are not being inferred from outside-EU distribution.

## Limits

Full coverage of every third-party Files provider, cloud-edit conflicts, OS/device combination, accessibility feature and malformed/large document cannot be claimed. Record observed tests and outstanding risks explicitly. Apple may request changes. The signed Mac1.0.0 download is preserved byte-for-byte; its prior sanitizer is not changed by this iOS build and is a separate follow-up risk.

## Official references checked

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/): 1.5,1.6,2.1,2.3,2.4,2.5,4.2,5.1,5.2.
- [Platform version metadata](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information): required Support URL contact and accurate description/review information.
- [Privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files).
- [Required-reason API guidance](https://developer.apple.com/documentation/technotes/tn3183-adding-required-reason-api-entries-to-your-privacy-manifest).
- [Third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/).
- [Accessibility labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels): voluntary currently; support claims require common-task validation.
- [Submission requirements](https://developer.apple.com/app-store/submitting/).
- [Remove a submission from review](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/remove-a-submission-from-review): replacement restarts review.
- [Submit an app](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app): Add for Review alone is not submission.

## Pre-distribution gate

At 12:00 SAST all identified website/app source blockers were resolved and the applicable technical/metadata audit completed. Distribution archive checks remain a required post-build gate before upload. iPad Review-iPad.xcresult:5tests,0failures. iPhone Review-Native-iPhone.xcresult:2tests,0failures; source/visual/share checks passed in Review-iPhone-Final.xcresult. Earlier navigation test failures were harness dismissal issues; manual closing/back navigation succeeded and independent navigation tests passed. Physical Review-Physical.xcresult passed Privacy/Support navigation. Additional physical editing tests are waiting for the device to be unlocked; no claim is made that they passed. Native new file bytes matched on iPad, and the generated file was reopened from Files and displayed correctly in portrait and landscape.

Source review confirms invalid UTF8 is rejected before editing and failed persistence keeps the editor open, with Share able to export current text. Storage-full/provider conflict/forced termination fault injection was not performed. Offline capability is supported by bundled resources and a deny-by-default network CSP; device-wide airplane-mode testing was not performed. Support email was verified as the developer’s existing public address and the mailto link validated; no unsolicited test email was sent.
