import Foundation

/// Builds the system and user prompts sent to a language model.
///
/// The builder guarantees that the user's note and every required output
/// section are referenced, and that the model is asked to return strict JSON
/// matching ``FollowUp``'s coding keys.
public enum PromptBuilder {
    /// The JSON keys the model must return — identical to ``FollowUp``'s
    /// `CodingKeys`, so the response decodes directly.
    public static let outputKeys: [String] = [
        "personName",
        "whoTheyAre",
        "whereYouMet",
        "whatYouTalkedAbout",
        "whyTheyMatter",
        "whenToFollowUp",
        "draftedMessage",
        "introIdeas",
        "reminderNote"
    ]

    public static let systemPrompt: String = """
    You are Afterparty, an assistant that helps people remember everyone they meet \
    and write the perfect follow-up. You are warm, concise, specific, and never \
    generic. You always ground your output in the details the user provides and \
    avoid inventing facts that contradict the note. You respond with a single JSON \
    object and nothing else — no markdown, no commentary, no code fences.
    """

    /// A description of each required section, included so the model knows
    /// exactly what to fill in.
    public static var sectionGuide: String {
        FollowUpSectionKind.allCases.map { kind in
            "- \(kind.title): \(sectionInstruction(for: kind))"
        }.joined(separator: "\n")
    }

    private static func sectionInstruction(for kind: FollowUpSectionKind) -> String {
        switch kind {
        case .whoTheyAre:
            return "one or two sentences summarising who the person is and your relationship."
        case .whereYouMet:
            return "the event or context where you met them."
        case .whatYouTalkedAbout:
            return "a short recap of the conversation topics."
        case .whyTheyMatter:
            return "why this connection is valuable to the user."
        case .whenToFollowUp:
            return "a concrete timing recommendation (e.g. 'within 48 hours')."
        case .draftedMessage:
            return "a ready-to-send follow-up message addressed to the person."
        case .introIdeas:
            return "a JSON array of 2-4 specific intro ideas (people or resources to connect them with)."
        case .reminderNote:
            return "a one-line memory hook so the relationship does not disappear."
        }
    }

    /// Builds the user-facing prompt for a given request.
    public static func userPrompt(for request: FollowUpRequest) -> String {
        let parsed = InputParser.parse(request.note)
        let signature = request.senderName.map { "Sign the drafted message from \"\($0)\"." }
            ?? "If you do not know the sender's name, end the drafted message without a typed signature."

        var hints: [String] = []
        if let name = parsed.name { hints.append("Likely name: \(name)") }
        if let company = parsed.company { hints.append("Likely company: \(company)") }
        if let role = parsed.role { hints.append("Likely role: \(role)") }
        let hintBlock = hints.isEmpty ? "" : "\nExtracted hints (verify against the note):\n" + hints.joined(separator: "\n")

        return """
        Create a follow-up plan for the person described in this note.

        NOTE:
        \"\"\"
        \(request.note.trimmed)
        \"\"\"
        \(hintBlock)

        The drafted message should be \(request.tone.promptDescription). \(signature)

        Return ONE JSON object with exactly these keys:
        \(outputKeys.map { "\"\($0)\"" }.joined(separator: ", ")).

        Field requirements:
        \(sectionGuide)

        "introIdeas" must be a JSON array of strings. All other fields are plain \
        strings. Do not wrap the JSON in code fences.
        """
    }
}
