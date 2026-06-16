import Foundation

/// The eight magical output sections Afterparty produces for every person.
///
/// The ordering of `allCases` is the canonical order in which the sections are
/// rendered on the results screen.
public enum FollowUpSectionKind: String, CaseIterable, Codable, Identifiable, Sendable {
    case whoTheyAre
    case whereYouMet
    case whatYouTalkedAbout
    case whyTheyMatter
    case whenToFollowUp
    case draftedMessage
    case introIdeas
    case reminderNote

    public var id: String { rawValue }

    /// The card title shown in the UI.
    public var title: String {
        switch self {
        case .whoTheyAre: return "Who they are"
        case .whereYouMet: return "Where you met"
        case .whatYouTalkedAbout: return "What you talked about"
        case .whyTheyMatter: return "Why they matter"
        case .whenToFollowUp: return "When to follow up"
        case .draftedMessage: return "Drafted follow-up"
        case .introIdeas: return "Possible intros"
        case .reminderNote: return "Reminder note"
        }
    }

    /// A short subtitle that clarifies the intent of the card.
    public var subtitle: String {
        switch self {
        case .whoTheyAre: return "Relationship summary"
        case .whereYouMet: return "Meeting context"
        case .whatYouTalkedAbout: return "Conversation recap"
        case .whyTheyMatter: return "Why this connection counts"
        case .whenToFollowUp: return "Timing recommendation"
        case .draftedMessage: return "Ready to send"
        case .introIdeas: return "People worth connecting"
        case .reminderNote: return "So they don't disappear"
        }
    }

    /// SF Symbol name used to decorate the card.
    public var systemImage: String {
        switch self {
        case .whoTheyAre: return "person.crop.circle"
        case .whereYouMet: return "mappin.and.ellipse"
        case .whatYouTalkedAbout: return "bubble.left.and.bubble.right"
        case .whyTheyMatter: return "star"
        case .whenToFollowUp: return "calendar.badge.clock"
        case .draftedMessage: return "paperplane"
        case .introIdeas: return "person.2"
        case .reminderNote: return "bell.badge"
        }
    }
}
