# markdown

Created by **Charles Majola** ([chmjdev](https://github.com/chmjdev)). Free and open source under the [MIT License](LICENSE.txt). Use, copy, modify, and distribute it with the license and author copyright notice retained.

A local Markdown document editor for macOS, iPhone and iPad. The Mac application uses native Swift/AppKit document windows around a bundled TOAST UI Editor. No server, account, or network connection is required for text editing. Linked remote images can load from their original URLs.

## Use

Open `/Applications/markdown.app`, or choose it from Finder → Open With. The default editing surface is WYSIWYG; use the toolbar for headings, bold/italic, links, lists, quotes, tables, checkboxes, and code. The Markdown tab exposes source text.

- ⌘N: new document
- ⌘O: open a file
- ⌘S: save
- ⇧⌘S: Save As
- ⌘W: close; unsaved changes prompt to save, discard, or cancel
- ⌘Z / ⇧⌘Z: undo / redo
- ⌘B / ⌘I: bold / italic

To set the default yourself: select a `.md` file in Finder, press ⌘I, expand **Open with**, choose **markdown**, then **Change All…**. Repeat for `.markdown` if desired. Installation registers both extensions but does not change existing default associations.

## Build and install

Builds a universal arm64/x86_64 app targeting macOS 13+. Requires a Mac, Xcode command-line tools, and Node.js/npm for building. The built app has no Node.js runtime dependency.

```sh
npm ci
npm run lint
bash build.sh
bash install.sh
open /Applications/markdown.app
```

Quit markdown before rebuilding or reinstalling. Build output is always `build/markdown.app`. The installer removes only existing apps with this project's bundle identifier before copying the new bundle to `/Applications`. It refuses to overwrite an unrelated app at the destination. Local builds are ad-hoc signed. The public 1.0.1 release is Developer ID signed, Apple-notarized, and stapled. Apple Silicon has been run-tested; Intel has only been cross-compiled. Releasing your own signed build requires your Apple Developer account and signing identity.

## Document behavior

Documents are UTF-8 Markdown files. Native New, Open, Save, Save As, Revert, multiwindow editing, and unsaved-change prompts are provided by NSDocument. Save is explicit. No cloud storage or telemetry is enabled.

Opening and saving without edits retains the original bytes. Visual edits normalize Markdown delimiters and spacing (for example, `-` list markers can become `*`). Common formatting retains its meaning. Raw HTML, custom Markdown extensions, YAML front matter, and relative images are not guaranteed to round-trip visually; use the Markdown source tab for those documents and review the saved result. There is no PDF export or app-wide text search in this initial version.

## Validation

See `tests/VALIDATION.md` for actual Mac UI checks. The fixture `tests/roundtrip.md` covers headings, bold/italic, links, nested lists, quotes, inline/fenced code, tasks, tables and Unicode. `python3 tests/check_saved.py` checks the output of the recorded UI round-trip.

Third-party license notices are bundled with the app in `Contents/Resources/THIRD-PARTY-NOTICES.txt` and retained at the project root.

## Public guide and distribution

The guide is served at https://markdown.pltfm.ai through JCDS. Its deployment is static nginx content from `public/`, with `/healthz` backed by a real static file. The macOS application is not run on the server. The project declares dev → prod only, with no database, authentication, telemetry, or secrets required for the guide.

- Local guide: `npm run guide:dev` (port read from `jcds.config`).
- Guide checks: `npm run guide:check`.
- Local preview: `bash scripts/package.sh` builds an ad-hoc universal ZIP.
- Signed release: `bash scripts/archive.sh`, then notarize with Direct Distribution: Xcode Organizer, or `xcodebuild -exportArchive` with `method` `developer-id` and `destination` `upload` followed by `xcodebuild -exportNotarizedApp`. Run `bash scripts/release.sh /path/to/markdown.app` to verify signature, ticket, Gatekeeper and architectures before packaging.
- App download: https://markdown.pltfm.ai/downloads/markdown-1.0.1-universal.zip (1.0.0 remains at its original URL)
- Deploy: `jcds remote deploy <configured-host> <project-path> prod --latest` after the PREGOLIVE gate. Do not run production launch commands by hand.

The public binary is signed with Developer ID, notarized by Apple, and includes a stapled ticket. The source is public at https://github.com/chmjdev/markdown under MIT. Dependencies retain their notices in `THIRD-PARTY-NOTICES.txt`.

## iPhone and iPad

The native iOS app targets iOS/iPadOS 17 or later. It uses the system Files document browser, UIDocument saving, a bundled visual editor, and a native source editor. Documents save automatically; Save and Done also save. Share exports a copy of current text, including when the original location cannot be saved.

The iOS editor works offline, blocks remote document images and links, and has no accounts, ads, analytics or tracking. Cloud synchronization is handled only by the Files provider the user chooses. Visual editing can normalize Markdown; Source preserves exact UTF-8 text.

Build with Xcode, Node.js and XcodeGen:

```sh
npm ci
bash scripts/build-ios.sh
open ios/markdown-iOS.xcodeproj
```

Use the `markdown-iOS` scheme. Select your own Apple development team for signing. The project is generated from `ios/project.yml`; generated Xcode files and build output are ignored. UI checks live in `ios/Tests/EditorTests.swift`. Submission metadata and release evidence live in `ios/AppStore/`. App Store availability depends on Apple review; an uploaded build is not a released app.

Both the Mac and iOS web builds go through `scripts/build-web.mjs`, which replaces TOAST UI 3.2.2's embedded DOMPurify 2.3.3 with the pinned DOMPurify 3.4.15 dependency. It fails if the expected upstream boundary or final sanitizer version changes. Review that integration when upgrading the editor. Mac 1.0.0 shipped the embedded 2.3.3; Mac 1.0.1 is the first Mac release with 3.4.15. Privacy and Support are available as native buttons in About.
