import XCTest
@testable import AfterpartyKit

final class InputParserTests: XCTestCase {

    func testParsesSarahExample() {
        let parsed = InputParser.parse(PersonNote(text: Fixtures.sarahNote))
        XCTAssertEqual(parsed.name, "Sarah")
        XCTAssertEqual(parsed.company, "Datadog")
        XCTAssertEqual(parsed.role, "developer marketing")
        XCTAssertTrue(parsed.topics.contains("customer hackathons"))
        XCTAssertTrue(parsed.topics.contains("SF venues"))
    }

    func testCompanyPrefersLastAtClause() {
        // The first "at" introduces a venue, the second a company.
        let parsed = InputParser.parse(PersonNote(text: "Met Jordan at the rooftop party. He leads sales at Stripe."))
        XCTAssertEqual(parsed.name, "Jordan")
        XCTAssertEqual(parsed.company, "Stripe")
        XCTAssertEqual(parsed.role, "sales")
    }

    func testHandlesEmptyNoteWithoutCrashing() {
        let parsed = InputParser.parse(PersonNote(text: "   "))
        XCTAssertNil(parsed.name)
        XCTAssertNil(parsed.company)
        XCTAssertNil(parsed.role)
        XCTAssertTrue(parsed.topics.isEmpty)
    }

    func testHandlesNoteWithNoStructure() {
        let parsed = InputParser.parse(PersonNote(text: "nice person, good vibes"))
        // No crash, graceful nils.
        XCTAssertNil(parsed.name)
        XCTAssertNil(parsed.company)
    }
}
