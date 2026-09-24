import XCTest

// Drives the typical user flow at a human pace for the App Review screen
// recording requested under Guideline 2.1 (Information Needed). Run it on a
// physical device while the screen is being captured.
final class ReviewWalkthrough: XCTestCase {
    func pause(_ seconds: TimeInterval = 1.5) { Thread.sleep(forTimeInterval: seconds) }

    func tapFirstHittable(_ app: XCUIApplication, _ labels: [String]) -> Bool {
        for label in labels {
            let button = app.buttons.matching(NSPredicate(format: "label == %@ OR identifier == %@", label, label)).allElementsBoundByIndex.first { $0.isHittable }
            if let button { button.tap(); return true }
        }
        return false
    }

    // SFSafariViewController runs out of process; its close control is "Close" on iOS 27, "Done" earlier.
    func closeSafari(_ app: XCUIApplication) {
        let close = app.buttons["Close"].firstMatch
        guard close.exists else { XCTAssertTrue(tapFirstHittable(app, ["Done"])); return }
        // An element tap does not reach the out-of-process control; tap its screen position.
        let f = close.frame
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: f.midX, dy: f.midY)).tap()
    }

    func waitEnabled(_ element: XCUIElement) {
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: element)
        waitForExpectations(timeout: 30)
    }

    // Setup, not for the recording: leaves the document browser in On My iPhone → markdown.
    func testPrepareBrowserFolder() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 60))
        let onDevice = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'On My'")).firstMatch
        for _ in 0..<4 where !onDevice.exists {
            if app.buttons["Back"].exists, app.buttons["Back"].isEnabled { app.buttons["Back"].tap() } else { app.buttons["Browse"].tap() }
            pause(1)
        }
        XCTAssertTrue(onDevice.waitForExistence(timeout: 10))
        onDevice.tap()
        let folder = app.cells.containing(.staticText, identifier: "markdown").firstMatch
        XCTAssertTrue(folder.waitForExistence(timeout: 10))
        folder.tap()
        pause(2)
        app.terminate()
    }

    func testReviewWalkthrough() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        // Start on the Home Screen so the recording shows the app being launched.
        XCUIDevice.shared.press(.home)
        pause(3)
        app.launch()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 60))
        pause(2)

        // The browser should already be in On My iPhone → markdown, so no personal
        // folders are shown. Fail rather than navigate through other folders on camera.
        // A fresh install's markdown folder is empty apart from Create Document.
        XCTAssertTrue(app.cells["Create Document"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.cells.count, 1, "Browser is not in the empty markdown folder")
        pause(3)

        // Open the bundled sample document in the visual editor.
        app.buttons["Welcome"].tap()
        let heading = app.webViews.staticTexts["A small plan"].firstMatch
        XCTAssertTrue(heading.waitForExistence(timeout: 60))
        waitEnabled(app.buttons["Source"])
        pause(3)

        // Type at the end of a list item on the formatted page.
        let item = app.webViews.staticTexts["Make it your own"].firstMatch
        XCTAssertTrue(item.exists)
        item.coordinate(withNormalizedOffset: CGVector(dx: 1.0, dy: 0.5)).withOffset(CGVector(dx: 4, dy: 0)).tap()
        pause()
        app.typeText(", drafted on iPhone")
        pause(2)
        app.toolbars.buttons["Hide keyboard"].tap()
        pause()

        // Undo and redo the edit.
        app.toolbars.buttons["Undo"].tap()
        pause()
        app.toolbars.buttons["Redo"].tap()
        pause()

        // Switch to the Markdown source and back.
        app.buttons["Source"].tap()
        let source = app.textViews["Markdown source"]
        XCTAssertTrue(source.waitForExistence(timeout: 10))
        XCTAssertTrue((source.value as? String)?.contains("Make it your own, drafted on iPhone") == true)
        pause(3)
        app.buttons["Visual"].tap()
        XCTAssertTrue(heading.waitForExistence(timeout: 60))
        pause(2)

        // Save explicitly.
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Saved ·'")).firstMatch.waitForExistence(timeout: 10))
        pause(2)

        // Return to the Files browser.
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 20))
        pause(2)

        // Create a new document and write in it.
        let create = app.cells["Create Document"]
        XCTAssertTrue(create.waitForExistence(timeout: 20))
        create.tap()
        let sourceButton = app.buttons["Source"]
        XCTAssertTrue(sourceButton.waitForExistence(timeout: 60))
        waitEnabled(sourceButton)
        pause(2)
        sourceButton.tap()
        XCTAssertTrue(source.waitForExistence(timeout: 10))
        source.tap()
        pause()
        source.typeText("# Shopping list\n\n- Bread\n- Coffee\n")
        pause(2)
        app.toolbars.buttons["Hide keyboard"].tap()
        app.buttons["Visual"].tap()
        XCTAssertTrue(app.webViews.staticTexts["Shopping list"].firstMatch.waitForExistence(timeout: 60))
        pause(3)
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 20))
        pause(3)

        // About, with the Privacy policy and Support pages.
        app.buttons["About markdown"].tap()
        XCTAssertTrue(app.buttons["Privacy policy"].waitForExistence(timeout: 10))
        pause(3)
        app.buttons["Privacy policy"].tap()
        XCTAssertTrue(app.webViews.staticTexts["Your words belong to you."].waitForExistence(timeout: 60))
        pause(4)
        closeSafari(app)
        XCTAssertTrue(app.buttons["Support"].waitForExistence(timeout: 10))
        pause(2)
        app.buttons["Support"].tap()
        XCTAssertTrue(app.webViews.staticTexts["A little help with markdown."].waitForExistence(timeout: 60))
        pause(4)
        closeSafari(app)
        pause(2)
        XCTAssertTrue(tapFirstHittable(app, ["Done"]))
        XCTAssertTrue(app.buttons["Welcome"].waitForExistence(timeout: 20))
        pause(3)
    }
}
