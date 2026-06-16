import XCTest
@testable import AfterpartyKit

/// These tests exercise ``ClaudeProvider``'s pure parsing helpers only — they
/// never touch the network and never require an API key.
final class ClaudeProviderTests: XCTestCase {

    func testInitThrowsWhenAPIKeyMissing() {
        XCTAssertThrowsError(try ClaudeProvider(apiKey: "")) { error in
            XCTAssertEqual(error as? AfterpartyError, .missingAPIKey)
        }
    }

    func testInitSucceedsWithExplicitKey() throws {
        let provider = try ClaudeProvider(apiKey: "test-key")
        XCTAssertEqual(provider.apiKey, "test-key")
        XCTAssertEqual(provider.model, ClaudeProvider.defaultModel)
    }

    func testExtractTextFromMessagesResponse() throws {
        let json = """
        {"id":"msg_1","type":"message","role":"assistant",
         "content":[{"type":"text","text":"Hello "},{"type":"text","text":"world"}],
         "model":"claude-sonnet-4-5"}
        """
        let text = try ClaudeProvider.extractText(from: Data(json.utf8))
        XCTAssertEqual(text, "Hello world")
    }

    func testExtractTextThrowsOnEmptyContent() {
        let json = #"{"content":[]}"#
        XCTAssertThrowsError(try ClaudeProvider.extractText(from: Data(json.utf8)))
    }

    func testExtractJSONObjectFromCodeFence() {
        let text = """
        Sure! Here you go:
        ```json
        {"personName":"Sarah","note":"x"}
        ```
        Hope that helps.
        """
        let extracted = ClaudeProvider.extractJSONObject(from: text)
        XCTAssertEqual(extracted, #"{"personName":"Sarah","note":"x"}"#)
    }

    func testExtractJSONObjectIgnoresBracesInsideStrings() {
        let text = #"prefix {"msg":"a } b { c"} suffix"#
        let extracted = ClaudeProvider.extractJSONObject(from: text)
        XCTAssertEqual(extracted, #"{"msg":"a } b { c"}"#)
    }

    func testParseFollowUpFromValidJSON() throws {
        let followUp = MockProvider.followUp(for: Fixtures.sarahRequest)
        let data = try JSONEncoder().encode(followUp)
        let jsonString = "Here is your follow-up:\n" + String(data: data, encoding: .utf8)!

        let parsed = try ClaudeProvider.parseFollowUp(from: jsonString, fallbackName: "Sarah")
        XCTAssertEqual(parsed, followUp)
    }

    func testParseFollowUpFallsBackOnNonJSON() throws {
        let prose = "Hi Sarah, it was lovely meeting you at the dinner. Let's stay in touch!"
        let parsed = try ClaudeProvider.parseFollowUp(from: prose, fallbackName: "Sarah")
        // Fallback must still be a complete, renderable FollowUp.
        XCTAssertTrue(parsed.isComplete)
        XCTAssertEqual(parsed.personName, "Sarah")
        XCTAssertEqual(parsed.draftedMessage, prose)
    }
}
