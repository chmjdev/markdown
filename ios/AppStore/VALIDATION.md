# iOS release validation - 2026-09-21

Version 1.0.0 build 2, bundle app.jola.markdown.ios, Xcode 26.6 (17F113), iOS 26.5 simulator runtime.

## Passing checks

- iPhone 17 Pro: source editing with Unicode, explicit save, Visual/Source switching, Done, reopen and exact text comparison (EditorTests-3.xcresult).
- iPhone 17 Pro Max: clean Visual/Source screenshot capture and native share-sheet Copy cell; source edit, native Undo/Redo, Save, mode switching, close/reopen exact text comparison (iPhone-Final.xcresult, 2 tests, 0 failures).
- iPad Pro 13-inch (M5): Visual/Source and share-sheet check; source Undo/Redo, Save, mode switching, Done and reopen exact comparison (iPad-Validation.xcresult capture test and iPad-Validation-2.xcresult source test).
- iPhone 17 Pro Max: actual visual typing, visual Undo/Redo, Save, Source verification, Done and reopen exact comparison (Visual-Workflow.xcresult, 1 test, 0 failures).
- Real screenshots visually inspected and retained in screenshots/iphone (1320 x 2868) and screenshots/ipad (2064 x 2752). No generated or resized screenshot content.
- Release archive for physical iOS arm64 succeeded with automatic signing. App Store Connect upload of build 2 succeeded at 10:16:51 SAST, 2026-09-21. Upload does not imply review submission or approval.
- JavaScript syntax, git diff whitespace checks, Mac saved-document evidence checks and public-guide checks passed after iOS addition. Mac native and web editor source was preserved.

## Issues resolved during validation

The keyboard obscured the first bottom toolbar, so editing controls moved above the editor. Mode switching was disabled until editor readiness. Initial visual scroll position was reset and heading line height corrected. Sharing now exports a current-text copy even if saving the original location fails. Test selectors were corrected for the system share sheet and the duplicate iPad Hide keyboard label. A simulator launch failure was recovered with a target-device restart and sequential device testing.

The Xcode GUI export hit an installed rsync incompatibility. Export/upload succeeded through xcodebuild with PATH=/usr/bin:/bin:/usr/sbin:/sbin, using the existing authorized Apple account.

## Limits

Runtime tests used iOS 26.5 simulators. Physical devices, iOS 17 runtime, VoiceOver, all Dynamic Type sizes, external keyboards, every Files provider, concurrent cloud edits and every orientation were not exhaustively validated. New/open uses the native document browser; these results primarily exercise the included Welcome document. Custom Markdown dialects and relative images are not promised to round-trip visually. Remote document images and links are blocked on iOS.

Private review contact details and signing secrets are not stored in this repository. See release-status.md for the last verified Apple submission stage.

## Build 3 pre-distribution audit

See APPLE-REVIEW-AUDIT.md for requirement applicability and official references. Review-iPad.xcresult passed all5 UI tests (Privacy/Support, screenshots/share, native creation/save, source Unicode/undo/redo/save/reopen, visual editing/save/reopen). iPhone document regressions passed in Review-iPhone-Final.xcresult; Review-Native-iPhone.xcresult passed the two navigation/native creation tests. Review-Physical.xcresult passed Privacy and Support opening on iPhone16Pro iOS27. Additional physical document tests awaited an unlocked device. Native iPad creation was also verified by exact saved bytes and reopening through Files; portrait and landscape inspected. DOMPurify3.4.15 replaces the editor’s embedded2.3.3 in the iOS bundle; npm audit0. Live site corrected via JCDS8ff3f49 and all8 tested publicroutes returned200; Mac ZIP SHA unchanged.

## Final build 3 distribution validation

Archive and export/upload succeeded on 21 September 2026; Apple processing Complete and build 3 Ready to Submit. Package identity, device families, OS minimum, signature, privacy manifest, bundled editor and licenses verified. Physical Privacy/Support navigation passed on iPhone 16 Pro / iOS 27; extra physical document tests were blocked by existing Files Face ID protection and stopped without bypass. Simulator document checks and all five iPad tests passed; physical editing is not claimed as verified. See release-status.md for actual review status.
