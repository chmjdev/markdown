# iOS App Store release status

## Current — verified 2026-09-24 about 23:10 SAST from App Store Connect

**Version 1.0.0 build 4 was resubmitted to App Review and is Waiting for Review. It is not approved or live.**

- Submission 2fc47b90-bbe9-461c-9741-acb0be1a7ea5 now shows 1.0.0 (4), Waiting for Review.
- The App Review reply (sent 23:09 SAST) contains the six answers from review-reply-2026-09-24.md, with markdown-app-review-recording.mp4 listed under Message Attachments. The video is a 1:57 physical iPhone 16 Pro / iOS 27 recording of build 4 and is not committed.
- The App Review Information Notes now hold the same answers, and the version was saved with build 4.
- Build 4 was archived with Xcode 27.0 / iOS 27 SDK, uploaded at 22:56 SAST and processed by Apple. See VALIDATION.md (Build 4).

The next step is Apple's decision. Approval and App Store availability must be verified separately.

## Rejection — verified 2026-09-24 from App Store Connect

**Version 1.0.0 build 3 is Rejected under Guideline 2.1 – Information Needed – New App Submission.** App Review's message is dated 2026-09-22 02:28. It reports no defect. Because the developer account has limited App Review history, Apple asks for a physical-device screen recording of the typical flow, starting at launch, and written answers covering purpose and audience, setup, external services, regional differences and regulated material. These go in an App Review reply and in the App Review Information Notes field.

Apple's message required no code change, but preparing the recording on iOS 27 found three defects (see VALIDATION.md, Build 4). They are fixed in build 4 (1.0.0 (4)), which is intended to replace build 3 when replying. The drafted reply is in review-reply-2026-09-24.md. Status after the reply must be re-verified in App Store Connect; this section does not claim that the reply was sent.

## Previous status — 21 September 2026

Verified 2026-09-21 at 12:15 SAST (Africa/Johannesburg).

**Version 1.0.0 build 3 submitted to Apple App Review; Waiting for Review. Not approved or live.**

- App: markdown — visual editor
- App Store Connect ID: 6814380491
- Bundle: app.jola.markdown.ios
- Version / build: 1.0.0 (3)
- Submission ID: 2fc47b90-bbe9-461c-9741-acb0be1a7ea5
- Evidence: App Store Connect displayed “1 Item Submitted” and “Draft Submissions (0)”. The submission details confirm “1.0.0 (3)”, “Waiting for Review” and 21 September 2026 at 12:15 PM.
- Review page: https://appstoreconnect.apple.com/apps/6814380491/distribution/reviewsubmissions/details/2fc47b90-bbe9-461c-9741-acb0be1a7ea5
- Previous build 2 submission a7556e93-aa1e-41e6-b520-e527a998c074 was canceled and replaced after the audit.
- Automatic release after approval is selected.
- Initial distribution: 148 countries/regions, excluding all 27 EU member countries; future-territory auto-enrollment disabled. No trader-status attestation was submitted.
- Free price; Productivity; English (U.K.); 4+ rating; published Data Not Collected privacy label.
- Two iPhone 6.9-inch and two iPad 13-inch screenshots uploaded and retained in screenshots/.
- Private user-confirmed review contact saved only in App Store Connect. No sign-in required for the app.
- Physical-iOS archive and upload succeeded. Source and visual save/reopen, undo/redo, mode switching and share-sheet UI checks passed as described in VALIDATION.md.

Next step is Apple's review decision. Resolve reviewer feedback if any. Approval and public availability must be verified separately before advertising an App Store download as live.

The macOS 1.0.0 release remains live, signed, notarized and stapled. Its public ZIP SHA-256 remains e509054f4c00f1be231140d765f52779e97bd84378692dce62b51b0a16d277c0. Support/privacy pages are deployed through JCDS and returned HTTP 200.
