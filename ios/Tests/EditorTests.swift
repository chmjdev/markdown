import XCTest
final class EditorTests: XCTestCase {
    func testAboutPrivacyAndSupportNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["About markdown"].waitForExistence(timeout: 60))
        app.buttons["About markdown"].tap()
        XCTAssertTrue(app.buttons["Privacy policy"].waitForExistence(timeout: 10))
        app.buttons["Privacy policy"].tap()
        XCTAssertTrue(app.webViews.staticTexts["Your words belong to you."].waitForExistence(timeout: 60))
        let privacy = XCTAttachment(screenshot: app.screenshot())
        privacy.name = "Privacy page opened from About"
        privacy.lifetime = .keepAlways
        add(privacy)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["About markdown"].waitForExistence(timeout: 60))
        app.buttons["About markdown"].tap()
        XCTAssertTrue(app.buttons["Support"].waitForExistence(timeout: 10))
        app.buttons["Support"].tap()
        XCTAssertTrue(app.webViews.staticTexts["A little help with markdown."].waitForExistence(timeout: 60))
        XCTAssertTrue(app.webViews.links["chmjdev@gmail.com"].exists)
        let support = XCTAttachment(screenshot: app.screenshot())
        support.name = "Support page opened from About"
        support.lifetime = .keepAlways
        add(support)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 10))
    }
    func testNativeCreationAndSave() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Create Document"].waitForExistence(timeout: 60))
        app.buttons["Create Document"].tap()
        let sourceButton = app.buttons["Source"]
        XCTAssertTrue(sourceButton.waitForExistence(timeout: 60))
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: sourceButton)
        waitForExpectations(timeout: 30)
        sourceButton.tap()
        let source = app.textViews["Markdown source"]
        XCTAssertTrue(source.waitForExistence(timeout: 10))
        XCTAssertEqual(source.value as? String, "")
        source.tap()
        source.typeText("# Native Files check\n\nCreated, saved and reopened — café.")
        app.toolbars.buttons["Hide keyboard"].tap()
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Saved ·'")).firstMatch.waitForExistence(timeout: 10))
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 10))
        let browser = XCTAttachment(string: app.debugDescription)
        browser.name = "Created document browser"
        browser.lifetime = .keepAlways
        add(browser)
    }
    func testCaptureStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 60))
        app.buttons["Welcome"].tap()
        XCTAssertTrue(app.webViews.staticTexts["A small plan"].firstMatch.waitForExistence(timeout: 60))
        let hierarchy = XCTAttachment(string: app.debugDescription)
        hierarchy.name = "Visual hierarchy"
        hierarchy.lifetime = .keepAlways
        add(hierarchy)
        let visual = XCTAttachment(screenshot: app.screenshot())
        visual.name = "Store-Visual"
        visual.lifetime = .keepAlways
        add(visual)
        app.buttons["Source"].tap()
        XCTAssertTrue(app.textViews["Markdown source"].waitForExistence(timeout: 10))
        let source = XCTAttachment(screenshot: app.screenshot())
        source.name = "Store-Source"
        source.lifetime = .keepAlways
        add(source)
        app.buttons["Share document"].tap()
        XCTAssertTrue(app.cells["Copy"].waitForExistence(timeout: 20))
    }
    func testSourceSaveReopenAndModes() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 60))
        app.buttons["Welcome"].tap()
        XCTAssertTrue(app.buttons["Source"].waitForExistence(timeout: 60))
        XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 60))
        XCTAssertTrue(app.webViews.staticTexts["A small plan"].firstMatch.waitForExistence(timeout: 60))
        let visual = XCTAttachment(screenshot: app.screenshot())
        visual.name = "Visual editor"
        visual.lifetime = .keepAlways
        add(visual)
        XCTAssertTrue(app.webViews.staticTexts["A small plan"].firstMatch.waitForExistence(timeout: 60))
        app.buttons["Source"].tap()
        let source = app.textViews["Markdown source"]
        XCTAssertTrue(source.waitForExistence(timeout: 10))
        let original = try XCTUnwrap(source.value as? String)
        XCTAssertTrue(original.contains("# Make room for your words"))
        source.tap()
        source.typeText("\n\nSaved on iOS — café ✓")
        if app.buttons["close"].exists { app.buttons["close"].tap() }
        app.toolbars.buttons["Hide keyboard"].tap()
        let edited = source.value as? String
        app.toolbars.buttons["Undo"].tap()
        XCTAssertEqual(source.value as? String, original)
        app.toolbars.buttons["Redo"].tap()
        XCTAssertEqual(source.value as? String, edited)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Saved ·'")).firstMatch.waitForExistence(timeout: 10))
        let text = try XCTUnwrap(source.value as? String)
        XCTAssertTrue(text.contains("Saved on iOS"))
        app.buttons["Visual"].tap()
        XCTAssertTrue(app.webViews.staticTexts["A small plan"].firstMatch.waitForExistence(timeout: 60))
        app.buttons["Source"].tap()
        XCTAssertTrue(source.waitForExistence(timeout: 10))
        XCTAssertEqual(source.value as? String, text)
        let sourceShot = XCTAttachment(screenshot: app.screenshot())
        sourceShot.name = "Source editor"
        sourceShot.lifetime = .keepAlways
        add(sourceShot)
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 10))
        app.buttons["Welcome"].tap()
        XCTAssertTrue(app.buttons["Source"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.webViews.staticTexts["A small plan"].firstMatch.waitForExistence(timeout: 60))
        app.buttons["Source"].tap()
        XCTAssertTrue(source.waitForExistence(timeout: 10))
        XCTAssertEqual(source.value as? String, text)
        app.buttons["Done"].tap()
    }
    func testVisualEditingSaveAndReopen() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 60))
        let browser = XCTAttachment(string: app.debugDescription)
        browser.name = "Files browser hierarchy"
        browser.lifetime = .keepAlways
        add(browser)
        app.buttons["Welcome"].tap()
        let heading = app.webViews.staticTexts["A small plan"].firstMatch
        XCTAssertTrue(heading.waitForExistence(timeout: 60))
        heading.tap()
        app.typeText("Visual edit verified ")
        app.toolbars.buttons["Hide keyboard"].tap()
        app.toolbars.buttons["Undo"].tap()
        app.toolbars.buttons["Redo"].tap()
        app.buttons["Save"].tap()
        app.buttons["Source"].tap()
        let source = app.textViews["Markdown source"]
        XCTAssertTrue(source.waitForExistence(timeout: 10))
        XCTAssertTrue((source.value as? String)?.contains("Visual edit verified") == true)
        let expected = source.value as? String
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 20))
        app.buttons["Welcome"].tap()
        XCTAssertTrue(app.buttons["Source"].waitForExistence(timeout: 20))
        let enabled = NSPredicate(format: "enabled == true")
        expectation(for: enabled, evaluatedWith: app.buttons["Source"])
        waitForExpectations(timeout: 30)
        app.buttons["Source"].tap()
        XCTAssertTrue(source.waitForExistence(timeout: 10))
        XCTAssertEqual(source.value as? String, expected)
        app.buttons["Done"].tap()
    }

}
