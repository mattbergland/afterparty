import XCTest
@testable import AfterpartyKit

final class EngineTests: XCTestCase {

    func testEngineProducesCompleteFollowUpWithMockProvider() async throws {
        let engine = FollowUpEngine(provider: MockProvider())
        let followUp = try await engine.generateFollowUp(for: Fixtures.sarahRequest)
        XCTAssertTrue(followUp.isComplete)
        XCTAssertEqual(followUp.sections.count, FollowUpSectionKind.allCases.count)
    }

    func testEmptyInputThrows() async {
        let engine = FollowUpEngine(provider: MockProvider())
        let request = FollowUpRequest(noteText: "    ")
        do {
            _ = try await engine.generateFollowUp(for: request)
            XCTFail("Expected emptyInput error")
        } catch {
            XCTAssertEqual(error as? AfterpartyError, .emptyInput)
        }
    }

    func testVeryShortInputDoesNotCrashAndStillReturnsAllSections() async throws {
        let engine = FollowUpEngine(provider: MockProvider())
        let request = FollowUpRequest(noteText: "Hi")
        let followUp = try await engine.generateFollowUp(for: request)
        XCTAssertEqual(followUp.sections.count, FollowUpSectionKind.allCases.count)
        XCTAssertTrue(followUp.isComplete)
    }

    func testSingleEmojiInputIsHandled() async throws {
        let engine = FollowUpEngine(provider: MockProvider())
        let request = FollowUpRequest(noteText: "👋")
        let followUp = try await engine.generateFollowUp(for: request)
        XCTAssertTrue(followUp.isComplete)
    }
}
