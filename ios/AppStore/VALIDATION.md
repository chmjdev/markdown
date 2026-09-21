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
