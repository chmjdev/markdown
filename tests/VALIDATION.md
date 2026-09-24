# Validation — 2026-09-21

Verified on this Apple Silicon Mac using Xcode 26.6 / Swift 6.3.3 and native accessibility-driven UI interaction.

- Native build succeeds; JavaScript syntax and Info.plist validation pass.
- Ad-hoc signature passes `codesign --verify --strict` for the installed app.
- `/Applications/markdown.app` launches and loads its bundled web editor from the installed resource path.
- Open by explicit application/file launch and native ⌘O both display the fixture visually.
- Headings, bold, italic, links, nested bullets, numbered lists, quotes, inline code, fenced Swift code, task checkboxes, tables, and Unicode survive a visual edit and Save As.
- ⌘S saves; ⇧⌘S presents Save As. Rapid type-then-save includes the complete final text. A WebKit shortcut conflict and save synchronization issue found during testing were fixed and retested.
- ⌘N creates a new document; first Save prompts for a location and extension. A `.markdown` file was created successfully.
- ⌘Z restores prior text; ⇧⌘Z restores the edit.
- Closing a modified document and quitting with modified documents show Save / Don’t Save / Cancel. Cancel retains the document. Don’t Save leaves disk content unchanged.
- Opening then saving an untouched file under a new name preserves its bytes exactly (`cmp` passed).
- Switching to source view in the installed app preserves original list markers/spacing, and closing after only switching modes does not prompt for unsaved changes.
- A new file saved by the installed app contains exactly `Installed app save verified.`.
- NSWorkspace Launch Services queries report `/Applications/markdown.app` as an eligible application for both `.md` and `.markdown`. The current default remains `/Applications/Xcode.app`; no default-association mutation was performed.
- App size: approximately 1.3 MB on this Mac.

`python3 tests/check_saved.py` validates the retained outputs from the UI session, including common formatting and unchanged-file bytes. It is an evidence check, not an automated driver for the app UI.

Not verified: distribution/notarization on other Macs, Intel compatibility, accessibility with VoiceOver, advanced/custom Markdown dialects, or relative-image rendering. These are outside this local initial build.

## Signed release validation — 2026-09-21

Apple notarization accepted submission `92D8D50B-A80F-456F-845F-40BF99AB84AD`. Xcode exported a Developer ID signed universal app with hardened runtime and stapled ticket. Both the installed app and ZIP-extracted app passed `codesign --verify --deep --strict`, `xcrun stapler validate`, and `spctl --assess --type execute` (accepted, Notarized Developer ID). Both arm64 and x86_64 slices are present.

The signed app launched from /Applications, created a new document, and saved the exact text in `signed-release.md` using Command-S. Fresh Launch Services checks resolved both .md and .markdown defaults to /Applications/markdown.app. Intel and macOS 13 runtime tests remain unperformed.

## Mac 1.0.1 release validation — 24 September 2026

Purpose: replace the DOMPurify 2.3.3 that TOAST UI 3.2.2 embeds with the pinned DOMPurify 3.4.15, as the iOS build has done since 21 September. `build.sh` now bundles through `scripts/build-web.mjs`, which is shared with iOS and fails the build if 2.3.3 remains or 3.4.15 is missing.

Built with Xcode 27.0 (27A266a), macOS 27 SDK, minimum macOS 13.0. Version 1.0.1 (2).

- Archive: Developer ID Application (7H64C3G53A), hardened runtime, arm64 + x86_64; the bundled editor contains DOMPurify 3.4.15 and no 2.3.3.
- Apple notarization accepted submission B15623FD-86E9-4CB3-84EC-5A15CFB35D01. The exported app passed `codesign --verify --deep --strict`, `xcrun stapler validate` and `spctl` (accepted, Notarized Developer ID), and has both architecture slices. `scripts/release.sh` now reads `lipo -archs`, because Xcode 27's `lipo -verify_arch` rejects multiple architectures.
- Sanitizer, checked in the release bundle's editor: a document with `<script>`, `onerror`, `onmouseover`, a `javascript:` link and an SVG `onbegin` rendered with no script elements, no event-handler attributes, an emptied link and no SVG animation; the page title was not changed and the safe text rendered.
- Installed to /Applications with the project installer (1.0.0 removed first). In the installed app: the hostile document rendered safely and closed without changes; the round-trip fixture rendered headings, emphasis, links, nested lists, quote, Swift code block, tasks, table and Unicode; after a visual edit, File → Save wrote a file containing every token that `tests/check_saved.py` checks plus the edit; opening and closing an unedited copy left its bytes identical.
- Release ZIP: markdown-1.0.1-universal.zip, SHA-256 246e85b4c28d1a3003d172e6c4c9ee1baed1950eb85ca30c92b9399e099f4e7b, `unzip -t` passed.

Not verified: Intel runtime, macOS 13–26 runtime with this build, VoiceOver.
