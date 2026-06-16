import XCTest
@testable import AfterpartyKit

final class PromptBuilderTests: XCTestCase {

    func testUserPromptContainsTheNote() {
        let prompt = PromptBuilder.userPrompt(for: Fixtures.sarahRequest)
        XCTAssertTrue(prompt.contains(Fixtures.sarahNote))
    }

    func testUserPromptMentionsEveryOutputKey() {
        let prompt = PromptBuilder.userPrompt(for: Fixtures.sarahRequest)
        for key in PromptBuilder.outputKeys {
            XCTAssertTrue(prompt.contains(key), "Prompt should mention output key \(key)")
        }
    }

    func testUserPromptMentionsEverySectionTitle() {
        let prompt = PromptBuilder.userPrompt(for: Fixtures.sarahRequest)
        for kind in FollowUpSectionKind.allCases {
            XCTAssertTrue(prompt.contains(kind.title), "Prompt should mention section \(kind.title)")
        }
    }

    func testOutputKeysMatchFollowUpCodingKeys() throws {
        // Encoding a FollowUp must yield exactly the keys the prompt asks for.
        let followUp = MockProvider.followUp(for: Fixtures.sarahRequest)
        let data = try JSONEncoder().encode(followUp)
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let encodedKeys = Set(object?.keys ?? [:].keys)
        XCTAssertEqual(encodedKeys, Set(PromptBuilder.outputKeys))
    }

    func testSenderNameAndToneAppearInPrompt() {
        let prompt = PromptBuilder.userPrompt(for: Fixtures.sarahRequest)
        XCTAssertTrue(prompt.contains("Matt"))
        XCTAssertTrue(prompt.contains(FollowUpTone.warm.promptDescription))
    }

    func testSystemPromptRequestsJSONOnly() {
        XCTAssertTrue(PromptBuilder.systemPrompt.lowercased().contains("json"))
    }
}
