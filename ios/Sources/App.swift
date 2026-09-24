import UIKit
import WebKit
import UniformTypeIdentifiers
import SafariServices

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// iOS 27 terminates apps built with its SDK that have not adopted the scene lifecycle.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.tintColor = UIColor(red: 0.18, green: 0.30, blue: 0.23, alpha: 1)
        window.overrideUserInterfaceStyle = .light
        window.rootViewController = BrowserController(forOpening: [UTType(importedAs: "net.daringfireball.markdown")])
        window.makeKeyAndVisible()
        self.window = window
        if let url = connectionOptions.urlContexts.first?.url { reveal(url) }
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url { reveal(url) }
    }
    func reveal(_ url: URL) {
        guard let browser = window?.rootViewController as? BrowserController else { return }
        browser.revealDocument(at: url, importIfNeeded: true) { url, error in
            if let error { browser.showError(error) }
            else if let url { browser.openDocument(url) }
        }
    }
}

final class MarkdownFile: UIDocument {
    var text = ""
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data, let value = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "markdown", code: 1, userInfo: [NSLocalizedDescriptionKey: "This document is not UTF-8 text. Convert a copy to UTF-8 before opening it."])
        }
        text = value
    }
    override func contents(forType typeName: String) throws -> Any { Data(text.utf8) }
    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
        NotificationCenter.default.post(name: .markdownError, object: self, userInfo: ["error": error])
    }
}
extension Notification.Name { static let markdownError = Notification.Name("markdown.error") }
extension UIViewController {
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Couldn’t complete that", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

final class BrowserController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        browserUserInterfaceStyle = .light
        // Leading items stay visible inside folders; iOS drops trailing app items there, which hid About.
        let about = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(about))
        about.accessibilityLabel = "About markdown"
        additionalLeadingNavigationBarButtonItems = [UIBarButtonItem(title: "Welcome", style: .plain, target: self, action: #selector(welcome)), about]
    }
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler handler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        do {
            let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let url = folder.appendingPathComponent("Untitled.md")
            try Data().write(to: url, options: .atomic)
            handler(url, .move)
        } catch { handler(nil, .none); showError(error) }
    }
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        if let url = documentURLs.first { openDocument(url) }
    }
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) { openDocument(destinationURL) }
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Creating from Recents (or any place without a destination folder) fails with
        // DocumentManager error 1. Keep the new document in the app's own folder instead.
        let temp = FileManager.default.temporaryDirectory.resolvingSymlinksInPath().path
        if documentURL.resolvingSymlinksInPath().path.hasPrefix(temp) {
            do {
                let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                var destination = folder.appendingPathComponent("Untitled.md")
                var index = 2
                while FileManager.default.fileExists(atPath: destination.path) {
                    destination = folder.appendingPathComponent("Untitled \(index).md")
                    index += 1
                }
                // New documents start empty, and the browser may already have removed the temporary file.
                try Data().write(to: destination, options: .withoutOverwriting)
                openDocument(destination)
                return
            } catch { showError(error); return }
        }
        if let error { showError(error) }
    }
    @objc func welcome() {
        do {
            let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = folder.appendingPathComponent("Welcome.md")
            if !FileManager.default.fileExists(atPath: url.path) {
                let text = "# Make room for your words\n\nWelcome to **markdown**, a quiet place to read and write on iPhone and iPad.\n\n## A small plan\n\n- Capture an idea\n- Give it a heading\n- Make it your own\n\n> Your document is an ordinary Markdown file. Take it anywhere.\n\n## Write your way\n\nUse **Visual** for a formatted page, or **Source** for the text underneath. Changes save automatically. Tap **Done** to return to Files.\n\n- [x] Open a document\n- [ ] Write something worth keeping\n\nMade by Charles Majola. Free and open source under the MIT License.\n"
                try text.write(to: url, atomically: true, encoding: .utf8)
            }
            openDocument(url)
        } catch { showError(error) }
    }
    func openDocument(_ url: URL) {
        guard presentedViewController == nil else { return }
        let access = url.startAccessingSecurityScopedResource()
        let document = MarkdownFile(fileURL: url)
        document.open { success in
            guard success else {
                if access { url.stopAccessingSecurityScopedResource() }
                self.showError(NSError(domain: "markdown", code: 2, userInfo: [NSLocalizedDescriptionKey: "The document could not be opened. Check that it is downloaded, accessible and saved as UTF-8 text."]))
                return
            }
            let editor = EditorController(document: document, scopedAccess: access)
            let navigation = UINavigationController(rootViewController: editor)
            navigation.modalPresentationStyle = .fullScreen
            navigation.isToolbarHidden = true
            self.present(navigation, animated: true)
        }
    }
    @objc func about() {
        let controller = AboutController()
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }
}

final class WeakHandler: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?
    init(_ target: WKScriptMessageHandler) { self.target = target }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { target?.userContentController(userContentController, didReceive: message) }
}

final class EditorController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, UITextViewDelegate {
    let document: MarkdownFile
    let scopedAccess: Bool
    var web: WKWebView!
    let source = UITextView()
    let mode = UISegmentedControl(items: ["Visual", "Source"])
    let status = UILabel()
    let editingToolbar = UIToolbar()
    var ready = false
    var sourceMode = false
    var revision = 0
    var savedRevision = 0
    var saving = false
    var pendingSave: DispatchWorkItem?
    var closing = false
    var observers: [NSObjectProtocol] = []
    init(document: MarkdownFile, scopedAccess: Bool) {
        self.document = document
        self.scopedAccess = scopedAccess
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.98, green: 0.976, blue: 0.965, alpha: 1)
        overrideUserInterfaceStyle = .light
        title = document.fileURL.deletingPathExtension().lastPathComponent
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(share)), UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveNow))]
        navigationItem.rightBarButtonItems?.first?.accessibilityLabel = "Share document"
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.userContentController.add(WeakHandler(self), name: "ready")
        config.userContentController.add(WeakHandler(self), name: "changed")
        web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.isOpaque = false
        web.backgroundColor = view.backgroundColor
        web.scrollView.isScrollEnabled = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        source.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
        source.backgroundColor = view.backgroundColor
        source.textColor = .label
        source.textContainerInset = UIEdgeInsets(top: 24, left: 18, bottom: 32, right: 18)
        source.autocorrectionType = .no
        source.autocapitalizationType = .none
        source.smartQuotesType = .no
        source.smartDashesType = .no
        source.delegate = self
        source.accessibilityLabel = "Markdown source"
        source.isHidden = true
        mode.selectedSegmentIndex = 0
        mode.isEnabled = false
        mode.addTarget(self, action: #selector(switchMode), for: .valueChanged)
        status.font = .preferredFont(forTextStyle: .caption1)
        status.textColor = .secondaryLabel
        status.text = "Saved · \(wordCount) words"
        status.accessibilityIdentifier = "saveStatus"
        let header = UIStackView(arrangedSubviews: [mode, status])
        header.axis = .vertical
        header.spacing = 8
        header.alignment = .fill
        status.textAlignment = .center
        for child in [header, editingToolbar, web!, source] { child.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(child) }
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.widthAnchor.constraint(equalToConstant: 230),
            editingToolbar.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 6),
            editingToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            editingToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            editingToolbar.heightAnchor.constraint(equalToConstant: 44),
            web.topAnchor.constraint(equalTo: editingToolbar.bottomAnchor, constant: 4),
            web.leadingAnchor.constraint(equalTo: view.leadingAnchor), web.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            web.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            source.topAnchor.constraint(equalTo: web.topAnchor), source.leadingAnchor.constraint(equalTo: web.leadingAnchor), source.trailingAnchor.constraint(equalTo: web.trailingAnchor), source.bottomAnchor.constraint(equalTo: web.bottomAnchor)
        ])
        let undo = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward"), style: .plain, target: self, action: #selector(undoEdit))
        undo.accessibilityLabel = "Undo"
        let redo = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.forward"), style: .plain, target: self, action: #selector(redoEdit))
        redo.accessibilityLabel = "Redo"
        let format = UIBarButtonItem(title: "Format", image: UIImage(systemName: "textformat"), primaryAction: nil, menu: formattingMenu())
        let keyboard = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .plain, target: self, action: #selector(hideKeyboard))
        keyboard.accessibilityLabel = "Hide keyboard"
        editingToolbar.items = [undo, redo, .flexibleSpace(), format, .flexibleSpace(), keyboard]
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "web") { web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent()) }
        observers.append(NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in self?.saveNow() })
        observers.append(NotificationCenter.default.addObserver(forName: .markdownError, object: document, queue: .main) { [weak self] note in
            self?.status.text = "Save failed — tap Save to retry"
            if let error = note.userInfo?["error"] as? Error, self?.presentedViewController == nil { self?.showError(error) }
        })
        observers.append(NotificationCenter.default.addObserver(forName: UIDocument.stateChangedNotification, object: document, queue: .main) { [weak self] _ in
            guard let self else { return }
            if self.document.documentState.contains(.inConflict) { self.status.text = "File conflict — keep a copy with Share" }
        })
    }
    var wordCount: Int { document.text.split(whereSeparator: { $0.isWhitespace }).count }
    func formattingMenu() -> UIMenu {
        let entries = [("Bold", "bold"), ("Italic", "italic"), ("Strikethrough", "strike"), ("Bullet list", "bulletList"), ("Numbered list", "orderedList"), ("Task list", "taskList"), ("Quote", "blockQuote"), ("Inline code", "code"), ("Code block", "codeBlock"), ("Divider", "hr")]
        let headings = UIMenu(title: "Heading", children: (1...3).map { level in UIAction(title: "Heading \(level)") { [weak self] _ in self?.web.evaluateJavaScript("window.markdown.heading(\(level))") } })
        return UIMenu(children: [headings] + entries.map { title, command in UIAction(title: title) { [weak self] _ in self?.command(command) } })
    }
    func command(_ name: String) { web.evaluateJavaScript("window.markdown.command('\(name)')") }
    func loadVisual() { web.callAsyncJavaScript("window.markdown.load(text)", arguments: ["text": document.text], in: nil, in: .page) { [weak self] result in if case .failure(let error) = result { self?.showError(error) } } }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "ready" { ready = true; loadVisual(); mode.isEnabled = true }
        else if message.name == "changed", !sourceMode, let text = message.body as? String { accept(text) }
    }
    func accept(_ text: String) {
        guard text != document.text else { return }
        document.text = text
        document.updateChangeCount(.done)
        revision += 1
        status.text = "Saving… · \(wordCount) words"
        pendingSave?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.persist() }
        pendingSave = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
    }
    func textViewDidChange(_ textView: UITextView) { accept(textView.text) }
    func snapshot(_ completion: @escaping (Bool) -> Void) {
        guard !sourceMode else { accept(source.text); completion(true); return }
        guard ready else { completion(false); return }
        web.callAsyncJavaScript("await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))); return window.markdown.snapshot();", arguments: [:], in: nil, in: .page) { [weak self] result in
            guard let self else { completion(false); return }
            switch result {
            case .failure(let error): self.showError(error); completion(false)
            case .success(let value):
                if let item = value as? [String: Any], item["edited"] as? Bool == true, let text = item["text"] as? String { self.accept(text) }
                completion(true)
            }
        }
    }
    func persist(completion: ((Bool) -> Void)? = nil) {
        pendingSave?.cancel()
        if saving {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in self?.persist(completion: completion) }
            return
        }
        if savedRevision == revision { completion?(true); return }
        guard !document.documentState.contains(.inConflict) else { completion?(false); return }
        saving = true
        let version = revision
        document.save(to: document.fileURL, for: .forOverwriting) { success in
            self.saving = false
            if success {
                self.savedRevision = version
                if self.revision != version { self.persist(completion: completion); return }
                self.status.text = "Saved · \(self.wordCount) words"
            } else { self.status.text = "Save failed — tap Save to retry" }
            completion?(success)
        }
    }
    @objc func saveNow() { snapshot { [weak self] success in if success { self?.persist() } } }
    @objc func switchMode() {
        let requested = mode.selectedSegmentIndex == 1
        mode.isEnabled = false
        snapshot { success in
            defer { self.mode.isEnabled = true }
            guard success else { self.mode.selectedSegmentIndex = self.sourceMode ? 1 : 0; return }
            self.view.endEditing(true)
            if requested { self.source.text = self.document.text; self.source.undoManager?.removeAllActions() }
            else { self.loadVisual() }
            self.sourceMode = requested
            self.source.isHidden = !requested
            self.web.isHidden = requested
            self.editingToolbar.items?[3].isEnabled = !requested
        }
    }
    @objc func undoEdit() { if sourceMode { source.undoManager?.undo() } else { command("undo") } }
    @objc func redoEdit() { if sourceMode { source.undoManager?.redo() } else { command("redo") } }
    @objc func hideKeyboard() { view.endEditing(true); web.evaluateJavaScript("window.markdown.blur()") }
    @objc func done() {
        guard !closing else { return }
        closing = true
        view.isUserInteractionEnabled = false
        snapshot { success in
            guard success else { self.closing = false; self.view.isUserInteractionEnabled = true; return }
            self.persist { success in
                guard success else { self.closing = false; self.view.isUserInteractionEnabled = true; self.showError(NSError(domain: "markdown", code: 3, userInfo: [NSLocalizedDescriptionKey: "Your changes could not be saved. The editor is still open; check storage access and tap Save to retry."])); return }
                self.document.close { closed in
                    if closed { self.dismiss(animated: true) }
                    else { self.closing = false; self.view.isUserInteractionEnabled = true }
                }
            }
        }
    }
    @objc func share() {
        snapshot { success in
            guard success else { return }
            self.persist { _ in
                let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
                let copy = folder.appendingPathComponent(self.document.fileURL.lastPathComponent)
                do {
                    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                    try Data(self.document.text.utf8).write(to: copy, options: .atomic)
                } catch { self.showError(error); return }
                let sheet = UIActivityViewController(activityItems: [copy], applicationActivities: nil)
                sheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItems?.first
                self.present(sheet, animated: true)
            }
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(action.navigationType == .other && action.request.url?.isFileURL == true ? .allow : .cancel)
    }
    deinit {
        pendingSave?.cancel()
        observers.forEach(NotificationCenter.default.removeObserver)
        web?.configuration.userContentController.removeAllScriptMessageHandlers()
        if scopedAccess { document.fileURL.stopAccessingSecurityScopedResource() }
    }
}

final class AboutController: UIViewController, SFSafariViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About markdown"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(close))
        let text = UITextView()
        text.isEditable = false
        text.dataDetectorTypes = [.link]
        text.font = .preferredFont(forTextStyle: .body)
        text.adjustsFontForContentSizeCategory = true
        text.textContainerInset = UIEdgeInsets(top: 24, left: 20, bottom: 30, right: 20)
        let license = Bundle.main.url(forResource: "LICENSE", withExtension: "txt").flatMap { try? String(contentsOf: $0) } ?? ""
        let notices = Bundle.main.url(forResource: "THIRD-PARTY-NOTICES", withExtension: "txt").flatMap { try? String(contentsOf: $0) } ?? ""
        text.text = "markdown\nBy Charles Majola\nFree and open source · MIT License\n\nWrite visually. Keep your Markdown.\n\nUse the + button in Files to create a document. Open .md or .markdown files from On My iPhone, iCloud Drive or another Files provider. Changes save automatically; Save and Done also save immediately. Share sends a copy through the iOS share sheet.\n\nYour privacy\nNo account, ads, analytics or tracking. Documents are handled on your device and saved to the Files location you choose. Your Files provider may sync them. Remote images and links do not load in the editor.\n\nGood to know\nVisual editing can normalize Markdown. Custom syntax, raw HTML and YAML may change in visual mode; use Source for exact text. Only UTF-8 files are supported.\n\nSupport: https://markdown.pltfm.ai/support.html\nPrivacy: https://markdown.pltfm.ai/privacy.html\n\n\(license)\n\n\(notices)"
        let privacy = UIButton(type: .system)
        privacy.setTitle("Privacy policy", for: .normal)
        privacy.addAction(UIAction { [weak self] _ in self?.openPage("https://markdown.pltfm.ai/privacy.html") }, for: .touchUpInside)
        let support = UIButton(type: .system)
        support.setTitle("Support", for: .normal)
        support.addAction(UIAction { [weak self] _ in self?.openPage("https://markdown.pltfm.ai/support.html") }, for: .touchUpInside)
        let links = UIStackView(arrangedSubviews: [privacy, support])
        links.axis = .horizontal
        links.distribution = .fillEqually
        links.translatesAutoresizingMaskIntoConstraints = false
        text.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(links)
        view.addSubview(text)
        NSLayoutConstraint.activate([
            links.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            links.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            links.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            links.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            text.topAnchor.constraint(equalTo: links.bottomAnchor),
            text.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            text.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            text.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    private func openPage(_ address: String) {
        guard let url = URL(string: address) else { return }
        let browser = SFSafariViewController(url: url)
        browser.delegate = self
        present(browser, animated: true)
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) { controller.dismiss(animated: true) }
    @objc func close() { dismiss(animated: true) }
}
