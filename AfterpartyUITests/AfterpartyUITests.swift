import XCTest

/// Drives the app end-to-end using the offline MockProvider (`-UITEST_MOCK 1`),
/// so the run is deterministic and needs no network and no API key. Captures a
/// screenshot of the input screen and of the fully-populated results screen.
final class AfterpartyUITests: XCTestCase {

    /// Section card accessibility identifiers that must all be visible on the
    /// results screen.
    private let cardIdentifiers = [
        "card_whoTheyAre",
        "card_whereYouMet",
        "card_whatYouTalkedAbout",
        "card_whyTheyMatter",
        "card_whenToFollowUp",
        "card_draftedMessage",
        "card_introIdeas",
        "card_reminderNote"
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCaptureFollowUpFlow() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-UITEST_MOCK", "1"]
        app.launchEnvironment["UITEST_MOCK"] = "1"
        app.launch()

        // MARK: Input screen
        let noteInput = app.textViews["noteInput"]
        XCTAssertTrue(noteInput.waitForExistence(timeout: 20), "Note input should appear")

        let createButton = app.buttons["createFollowUpButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10), "Create button should appear")

        attach(name: "afterparty-input", screenshot: XCUIScreen.main.screenshot())

        // MARK: Generate
        createButton.tap()

        // MARK: Results screen — every card must be present.
        let results = app.scrollViews["resultsScreen"]
        XCTAssertTrue(results.waitForExistence(timeout: 25), "Results screen should appear")

        for identifier in cardIdentifiers {
            let card = app.descendants(matching: .any)[identifier]
            XCTAssertTrue(
                card.waitForExistence(timeout: 10),
                "Result card \(identifier) should be visible"
            )
        }

        // Give SwiftUI a beat to settle the transition before capturing.
        sleep(1)
        attach(name: "afterparty-results", screenshot: XCUIScreen.main.screenshot())
    }

    private func attach(name: String, screenshot: XCUIScreenshot) {
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
