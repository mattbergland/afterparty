import Foundation

/// A single renderable section of a ``FollowUp``.
///
/// `body` is always populated with display-ready text. `bullets` is non-`nil`
/// only for list-style sections (currently ``FollowUpSectionKind/introIdeas``).
public struct FollowUpSection: Identifiable, Equatable, Sendable {
    public let kind: FollowUpSectionKind
    public let body: String
    public let bullets: [String]?

    public init(kind: FollowUpSectionKind, body: String, bullets: [String]? = nil) {
        self.kind = kind
        self.body = body
        self.bullets = bullets
    }

    public var id: String { kind.rawValue }
    public var title: String { kind.title }
    public var subtitle: String { kind.subtitle }
    public var systemImage: String { kind.systemImage }
}

/// The complete "magical output" Afterparty generates for one person.
///
/// Every property maps one-to-one to a required output section in the spec and
/// is rendered as its own card on the results screen.
public struct FollowUp: Codable, Equatable, Sendable {
    /// Best-effort name of the person, used for headings and the message greeting.
    public var personName: String

    // MARK: Required output sections

    /// Who they are (relationship summary).
    public var whoTheyAre: String
    /// Where you met (meeting context).
    public var whereYouMet: String
    /// What you talked about.
    public var whatYouTalkedAbout: String
    /// Why they matter.
    public var whyTheyMatter: String
    /// When to follow up (timing recommendation).
    public var whenToFollowUp: String
    /// Drafted follow-up message (ready to send).
    public var draftedMessage: String
    /// Possible intro ideas.
    public var introIdeas: [String]
    /// A reminder note so the relationship does not disappear.
    public var reminderNote: String

    public init(
        personName: String,
        whoTheyAre: String,
        whereYouMet: String,
        whatYouTalkedAbout: String,
        whyTheyMatter: String,
        whenToFollowUp: String,
        draftedMessage: String,
        introIdeas: [String],
        reminderNote: String
    ) {
        self.personName = personName
        self.whoTheyAre = whoTheyAre
        self.whereYouMet = whereYouMet
        self.whatYouTalkedAbout = whatYouTalkedAbout
        self.whyTheyMatter = whyTheyMatter
        self.whenToFollowUp = whenToFollowUp
        self.draftedMessage = draftedMessage
        self.introIdeas = introIdeas
        self.reminderNote = reminderNote
    }

    /// All sections in canonical render order. Guaranteed to contain exactly one
    /// entry for every ``FollowUpSectionKind``.
    public var sections: [FollowUpSection] {
        FollowUpSectionKind.allCases.map { kind in
            switch kind {
            case .whoTheyAre:
                return FollowUpSection(kind: kind, body: whoTheyAre)
            case .whereYouMet:
                return FollowUpSection(kind: kind, body: whereYouMet)
            case .whatYouTalkedAbout:
                return FollowUpSection(kind: kind, body: whatYouTalkedAbout)
            case .whyTheyMatter:
                return FollowUpSection(kind: kind, body: whyTheyMatter)
            case .whenToFollowUp:
                return FollowUpSection(kind: kind, body: whenToFollowUp)
            case .draftedMessage:
                return FollowUpSection(kind: kind, body: draftedMessage)
            case .introIdeas:
                return FollowUpSection(
                    kind: kind,
                    body: introIdeas.joined(separator: "\n"),
                    bullets: introIdeas
                )
            case .reminderNote:
                return FollowUpSection(kind: kind, body: reminderNote)
            }
        }
    }

    /// `true` only when every required section contains non-empty content.
    public var isComplete: Bool {
        let strings = [
            whoTheyAre, whereYouMet, whatYouTalkedAbout, whyTheyMatter,
            whenToFollowUp, draftedMessage, reminderNote
        ]
        let allStringsFilled = strings.allSatisfy {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let introsFilled = !introIdeas.isEmpty
            && introIdeas.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return allStringsFilled && introsFilled
    }
}
