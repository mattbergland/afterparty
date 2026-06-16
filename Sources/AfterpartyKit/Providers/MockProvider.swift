import Foundation

/// A fully deterministic, offline provider.
///
/// It never touches the network and needs no API key, which makes it ideal for
/// unit tests and SwiftUI previews. The canned content is modelled on the
/// Sarah / Datadog example from the spec, and lightly personalised using
/// ``InputParser`` so different notes produce different — but still realistic —
/// output.
public struct MockProvider: AIProvider {
    public init() {}

    public func generateFollowUp(for request: FollowUpRequest) async throws -> FollowUp {
        Self.followUp(for: request)
    }

    /// Synchronous builder so previews and tests can call it without `await`.
    public static func followUp(for request: FollowUpRequest) -> FollowUp {
        let parsed = InputParser.parse(request.note)

        let name = parsed.name ?? "Sarah"
        let company = parsed.company ?? "Datadog"
        let role = parsed.role ?? "developer marketing"
        let venue = meetingContext(from: request.note) ?? "the AI dinner"
        let topics = parsed.topics.isEmpty
            ? ["customer hackathons", "SF venues"]
            : parsed.topics
        let topicSentence = naturalList(topics)

        let whoTheyAre = "\(name) leads \(role) at \(company). A sharp, well-connected operator who is easy to keep talking to and clearly plugged into the right rooms."

        let whereYouMet = "You met at \(venue). It was a relaxed, high-signal setting — the kind of room where a quick note now pays off later."

        let whatYouTalkedAbout = "You talked about \(topicSentence). \(name) had concrete opinions and shared a few specifics worth remembering."

        let whyTheyMatter = "\(name) sits right where your world overlaps with \(company)'s — useful for partnerships, events, and warm intros. The kind of person worth keeping close, not just adding to a list."

        let whenToFollowUp = "Reach out within 48 hours, while the conversation is still fresh for both of you. Sooner is better than perfect."

        let draftedMessage = draftMessage(
            name: name,
            company: company,
            topics: topics,
            venue: venue,
            tone: request.tone,
            senderName: request.senderName
        )

        let introIdeas = [
            "Connect \(name) with someone running developer hackathons so they can compare playbooks.",
            "Offer to introduce \(name) to a favourite SF venue contact for their next event.",
            "Loop \(name) in with a peer in \(company)'s ecosystem who is solving a similar problem."
        ]

        let reminderNote = "Met \(name) (\(role) @ \(company)) at \(venue). Follow up about \(topicSentence). Warm, worth nurturing."

        return FollowUp(
            personName: name,
            whoTheyAre: whoTheyAre,
            whereYouMet: whereYouMet,
            whatYouTalkedAbout: whatYouTalkedAbout,
            whyTheyMatter: whyTheyMatter,
            whenToFollowUp: whenToFollowUp,
            draftedMessage: draftedMessage,
            introIdeas: introIdeas,
            reminderNote: reminderNote
        )
    }

    // MARK: - Composition helpers

    private static func draftMessage(
        name: String,
        company: String,
        topics: [String],
        venue: String,
        tone: FollowUpTone,
        senderName: String?
    ) -> String {
        let opener: String
        switch tone {
        case .warm:
            opener = "Hi \(name), it was so good meeting you at \(venue)."
        case .professional:
            opener = "Hi \(name), great to connect at \(venue)."
        case .playful:
            opener = "Hey \(name)! \(venue) was a blast — so glad we got to chat."
        }

        let topicLine = "I keep thinking about our conversation on \(naturalList(topics)) — you clearly know this space well."
        let ask = "Would love to keep the thread going. Are you free for a quick coffee or call in the next couple of weeks?"
        let signature = senderName.map { "\n\nTalk soon,\n\($0)" } ?? "\n\nTalk soon!"

        return "\(opener) \(topicLine) \(ask)\(signature)"
    }

    /// Pulls a meeting context such as "the AI dinner" out of the note when the
    /// parser found a name (the clause sits between the name and the next period).
    private static func meetingContext(from note: PersonNote) -> String? {
        let raw = note.trimmed
        guard let atRange = raw.range(of: " at ", options: .caseInsensitive) else { return nil }
        let after = raw[atRange.upperBound...]
        var end = after.endIndex
        if let dot = after.range(of: ".") { end = dot.lowerBound }
        let context = after[..<end].trimmingCharacters(in: .whitespacesAndNewlines)
        // Skip when the first "at" introduces a company (single capitalised word).
        let words = context.split(separator: " ")
        if words.count <= 1 { return nil }
        guard !context.isEmpty, context.count < 60 else { return nil }
        return context
    }

    /// Turns ["a", "b", "c"] into "a, b, and c".
    private static func naturalList(_ items: [String]) -> String {
        switch items.count {
        case 0: return ""
        case 1: return items[0]
        case 2: return "\(items[0]) and \(items[1])"
        default:
            let head = items.dropLast().joined(separator: ", ")
            return "\(head), and \(items.last!)"
        }
    }
}
