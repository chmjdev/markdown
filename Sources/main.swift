import AppKit
import WebKit
import UniformTypeIdentifiers

final class EditorWebView: WKWebView {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.contains(.command), NSApp.mainMenu?.performKeyEquivalent(with: event) == true { return true }
        return super.performKeyEquivalent(with: event)
    }
}

final class DocumentController: NSDocumentController {
    override func documentClass(forType typeName: String) -> AnyClass? { MarkdownDocument.self }
    override var defaultType: String? { "net.daringfireball.markdown" }
}

@objc(MarkdownDocument)
final class MarkdownDocument: NSDocument, WKScriptMessageHandler, WKNavigationDelegate {
    var markdownText = ""
    var webView: WKWebView?
    var editorReady = false
    var editorChanged = false
    override class var autosavesInPlace: Bool { false }
    override class var writableTypes: [String] { ["net.daringfireball.markdown"] }

    override func makeWindowControllers() {
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "ready")
        config.userContentController.add(self, name: "changed")
        config.userContentController.add(self, name: "openLink")
        let web = EditorWebView(frame: NSRect(x: 0, y: 0, width: 960, height: 720), configuration: config)
        web.navigationDelegate = self
        web.setValue(false, forKey: "drawsBackground")
        webView = web
        let window = NSWindow(contentRect: web.frame, styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.minSize = NSSize(width: 620, height: 420)
        window.contentView = web
        window.center()
        window.setFrameAutosaveName("markdown.document")
        window.appearance = NSAppearance(named: .aqua)
        addWindowController(NSWindowController(window: window))
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "web") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    func loadEditor() {
        guard editorReady, let data = try? JSONSerialization.data(withJSONObject: [markdownText]), let json = String(data: data, encoding: .utf8) else { return }
        webView?.evaluateJavaScript("window.markdown.load(\(json)[0])")
    }

    func accept(_ text: String) {
        guard text != markdownText else { return }
        markdownText = text
        editorChanged = true
        updateChangeCount(.changeDone)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "ready": editorReady = true; loadEditor()
        case "changed": if let text = message.body as? String { accept(text) }
        case "openLink":
            if let string = message.body as? String, let url = URL(string: string), ["https", "http", "mailto"].contains(url.scheme ?? "") { NSWorkspace.shared.open(url) }
        default: break
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(navigationAction.navigationType == .other && navigationAction.request.url?.isFileURL == true ? .allow : .cancel)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let value = String(data: data, encoding: .utf8) else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadInapplicableStringEncodingError, userInfo: [NSLocalizedDescriptionKey: "This file is not UTF-8 text. Convert it to UTF-8 before opening it in markdown."])
        }
        markdownText = value
        editorChanged = false
        loadEditor()
    }

    override func data(ofType typeName: String) throws -> Data { Data(markdownText.utf8) }

    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        guard editorReady, let web = webView else {
            super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
            return
        }
        web.callAsyncJavaScript("await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))); return window.markdown.snapshot();", arguments: [:], in: nil, in: .page) { result in
            switch result {
            case .failure(let error): completionHandler(error)
            case .success(let value):
                if let snapshot = value as? [String: Any], snapshot["edited"] as? Bool == true, let text = snapshot["text"] as? String { self.accept(text) }
                self.finishSave(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
            }
        }
    }

    private func finishSave(to url: URL, ofType typeName: String, for operation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        super.save(to: url, ofType: typeName, for: operation, completionHandler: completionHandler)
    }

    @objc func editorUndo(_ sender: Any?) { webView?.evaluateJavaScript("window.markdown.command('undo')") }
    @objc func editorRedo(_ sender: Any?) { webView?.evaluateJavaScript("window.markdown.command('redo')") }
    @objc func format(_ sender: NSMenuItem) {
        guard let command = sender.representedObject as? String else { return }
        webView?.evaluateJavaScript("window.markdown.command('\(command)')")
    }

    override func close() {
        webView?.configuration.userContentController.removeAllScriptMessageHandlers()
        super.close()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: DocumentController!
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if self.controller.documents.isEmpty { self.controller.newDocument(nil) }
        }
    }
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for filename in filenames {
            controller.openDocument(withContentsOf: URL(fileURLWithPath: filename), display: true) { _, _, error in
                if let error = error { NSApp.presentError(error) }
            }
        }
        sender.reply(toOpenOrPrint: .success)
    }
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool { false }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { controller.newDocument(nil) }
        return true
    }
    @objc func showHelp(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "markdown by Charles Majola"
        alert.informativeText = "Use the toolbar for headings, lists, links, quotes and code. Switch to Markdown below to edit source.\n\n⌘N New · ⌘O Open · ⌘S Save\n⇧⌘S Save As · ⌘B Bold · ⌘I Italic\n⌘Z Undo · ⇧⌘Z Redo\n\nTo make markdown your default: select a .md file in Finder, choose Get Info → Open with → markdown → Change All. Repeat for .markdown files.\n\nFree and open source • MIT License • github.com/chmjdev/markdown.\n\nFiles stay on your Mac. Common Markdown formatting is preserved; visual editing may normalize spacing and delimiters."
        alert.runModal()
    }
}

func item(_ title: String, _ selector: Selector?, _ key: String = "", _ target: AnyObject? = nil, shift: Bool = false) -> NSMenuItem {
    let result = NSMenuItem(title: title, action: selector, keyEquivalent: key)
    result.target = target
    result.keyEquivalentModifierMask = shift ? [.command, .shift] : [.command]
    return result
}
func menu(_ title: String, in root: NSMenu) -> NSMenu {
    let holder = NSMenuItem(title: title, action: nil, keyEquivalent: "")
    let submenu = NSMenu(title: title)
    holder.submenu = submenu
    root.addItem(holder)
    return submenu
}

let app = NSApplication.shared
let controller = DocumentController()
let delegate = AppDelegate()
delegate.controller = controller
app.delegate = delegate
let root = NSMenu()
let appMenu = menu("markdown", in: root)
appMenu.addItem(item("About markdown", #selector(NSApplication.orderFrontStandardAboutPanel(_:))))
appMenu.addItem(.separator())
appMenu.addItem(item("Hide markdown", #selector(NSApplication.hide(_:)), "h"))
appMenu.addItem(item("Quit markdown", #selector(NSApplication.terminate(_:)), "q"))
let file = menu("File", in: root)
file.addItem(item("New", #selector(NSDocumentController.newDocument(_:)), "n", controller))
file.addItem(item("Open…", #selector(NSDocumentController.openDocument(_:)), "o", controller))
file.addItem(.separator())
file.addItem(item("Close", #selector(NSWindow.performClose(_:)), "w"))
file.addItem(item("Save", #selector(NSDocument.save(_:)), "s"))
file.addItem(item("Save As…", #selector(NSDocument.saveAs(_:)), "s", nil, shift: true))
file.addItem(item("Revert to Saved…", #selector(NSDocument.revertToSaved(_:))))
let edit = menu("Edit", in: root)
edit.addItem(item("Undo", #selector(MarkdownDocument.editorUndo(_:)), "z"))
edit.addItem(item("Redo", #selector(MarkdownDocument.editorRedo(_:)), "z", nil, shift: true))
edit.addItem(.separator())
edit.addItem(item("Cut", #selector(NSText.cut(_:)), "x"))
edit.addItem(item("Copy", #selector(NSText.copy(_:)), "c"))
edit.addItem(item("Paste", #selector(NSText.paste(_:)), "v"))
edit.addItem(item("Select All", #selector(NSText.selectAll(_:)), "a"))
let formatMenu = menu("Format", in: root)
for (title, command, key) in [("Bold", "bold", "b"), ("Italic", "italic", "i"), ("Strikethrough", "strike", ""), ("Bullet List", "bulletList", ""), ("Numbered List", "orderedList", ""), ("Quote", "blockQuote", ""), ("Inline Code", "code", "")] {
    let entry = item(title, #selector(MarkdownDocument.format(_:)), key)
    entry.representedObject = command
    formatMenu.addItem(entry)
}
let windowMenu = menu("Window", in: root)
windowMenu.addItem(item("Minimize", #selector(NSWindow.performMiniaturize(_:)), "m"))
windowMenu.addItem(item("Zoom", #selector(NSWindow.performZoom(_:))))
app.windowsMenu = windowMenu
let help = menu("Help", in: root)
help.addItem(item("markdown Help", #selector(AppDelegate.showHelp(_:)), "", delegate))
app.helpMenu = help
app.mainMenu = root
let shortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
    if NSApp.keyWindow?.windowController?.document is MarkdownDocument,
       event.modifierFlags.contains(.command),
       ["s", "n", "o", "w", "q", "z", "b", "i"].contains(event.charactersIgnoringModifiers?.lowercased() ?? ""),
       NSApp.mainMenu?.performKeyEquivalent(with: event) == true { return nil }
    return event
}
app.run()
