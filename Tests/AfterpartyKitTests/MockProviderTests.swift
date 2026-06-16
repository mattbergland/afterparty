import XCTest
@testable import AfterpartyKit

final class MockProviderTests: XCTestCase {

    func testProducesEveryRequiredSectionNonEmpty() async throws {
        let provider = MockProvider()
        let followUp = try await provider.generateFollowUp(for: Fixtures.sarahRequest)

        XCTAssertTrue(followUp.isComplete, "Every required section must be populated")
        for section in followUp.sections {
            XCTAssertFalse(
                section.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                "Section \(section.kind) should not be empty"
            )
        }
    }

    func testIsDeterministic() async throws {
        let provider = MockProvider()
        let first = try await provider.generateFollowUp(for: Fixtures.sarahRequest)
        let second = try await provider.generateFollowUp(for: Fixtures.sarahRequest)
        XCTAssertEqual(first, second, "MockProvider must be deterministic")
    }

    func testSarahExampleIsGroundedInTheNote() async throws {
        let provider = MockProvider()
        let followUp = try await provider.generateFollowUp(for: Fixtures.sarahRequest)

        XCTAssertEqual(followUp.personName, "Sarah")
        XCTAssertTrue(followUp.whoTheyAre.contains("Sarah"))
        XCTAssertTrue(followUp.whoTheyAre.contains("Datadog"))
        XCTAssertTrue(followUp.draftedMessage.contains("Sarah"))
        // Conversation topics from the note should surface somewhere.
        XCTAssertTrue(followUp.whatYouTalkedAbout.lowercased().contains("hackathon"))
    }

    func testSenderNameIsUsedInSignature() async throws {
        let provider = MockProvider()
        let followUp = try await provider.generateFollowUp(for: Fixtures.sarahRequest)
        XCTAssertTrue(followUp.draftedMessage.contains("Matt"))
    }

    func testToneChangesTheDraftedMessage() {
        let warm = MockProvider.followUp(for: FollowUpRequest(noteText: Fixtures.sarahNote, tone: .warm))
        let playful = MockProvider.followUp(for: FollowUpRequest(noteText: Fixtures.sarahNote, tone: .playful))
        XCTAssertNotEqual(warm.draftedMessage, playful.draftedMessage)
    }

    func testGenericNoteStillProducesAllSections() async throws {
        let provider = MockProvider()
        let request = FollowUpRequest(noteText: "Met Priya at a rooftop mixer. She founded a fintech startup. We discussed payments and hiring.")
        let followUp = try await provider.generateFollowUp(for: request)

        XCTAssertTrue(followUp.isComplete)
        XCTAssertEqual(followUp.personName, "Priya")
    }
}
