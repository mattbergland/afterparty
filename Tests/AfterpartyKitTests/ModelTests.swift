import XCTest
@testable import AfterpartyKit

final class ModelTests: XCTestCase {

    func testFollowUpCodableRoundTrip() throws {
        let original = MockProvider.followUp(for: Fixtures.sarahRequest)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FollowUp.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testFollowUpRequestCodableRoundTrip() throws {
        let original = Fixtures.sarahRequest

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FollowUpRequest.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testPersonNoteCodableRoundTrip() throws {
        let original = PersonNote(text: Fixtures.sarahNote)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersonNote.self, from: data)

        XCTAssertEqual(original, decoded)
    }

    func testFollowUpToneCodableRoundTrip() throws {
        for tone in FollowUpTone.allCases {
            let data = try JSONEncoder().encode(tone)
            let decoded = try JSONDecoder().decode(FollowUpTone.self, from: data)
            XCTAssertEqual(tone, decoded)
        }
    }

    func testSectionsCoverEverySectionKindInOrder() {
        let followUp = MockProvider.followUp(for: Fixtures.sarahRequest)
        let sections = followUp.sections

        XCTAssertEqual(sections.count, FollowUpSectionKind.allCases.count)
        XCTAssertEqual(sections.map(\.kind), FollowUpSectionKind.allCases)
    }

    func testEverySectionHasTitleSubtitleAndImage() {
        for kind in FollowUpSectionKind.allCases {
            XCTAssertFalse(kind.title.isEmpty, "\(kind) missing title")
            XCTAssertFalse(kind.subtitle.isEmpty, "\(kind) missing subtitle")
            XCTAssertFalse(kind.systemImage.isEmpty, "\(kind) missing systemImage")
        }
    }

    func testIntroIdeasSectionExposesBullets() {
        let followUp = MockProvider.followUp(for: Fixtures.sarahRequest)
        let intro = followUp.sections.first { $0.kind == .introIdeas }
        XCTAssertNotNil(intro?.bullets)
        XCTAssertFalse(intro?.bullets?.isEmpty ?? true)
    }

    func testPersonNoteEmptyAndShortFlags() {
        XCTAssertTrue(PersonNote(text: "   ").isEmpty)
        XCTAssertFalse(PersonNote(text: "Hi").isEmpty)
        XCTAssertTrue(PersonNote(text: "Hi").isTooShort)
        XCTAssertFalse(PersonNote(text: Fixtures.sarahNote).isTooShort)
    }
}
