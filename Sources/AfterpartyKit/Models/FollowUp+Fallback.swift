import Foundation

public extension FollowUp {
    /// Builds a usable ``FollowUp`` when the model returned prose instead of
    /// valid JSON. The raw text becomes the drafted message so the user still
    /// gets something to send, and the remaining cards explain the situation
    /// rather than showing blanks.
    static func fallback(rawText: String, name: String?) -> FollowUp {
        let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let personName = name ?? "this person"
        return FollowUp(
            personName: personName,
            whoTheyAre: "Someone you just met — details are in your note.",
            whereYouMet: "See your note for where you crossed paths.",
            whatYouTalkedAbout: "Captured in your original note.",
            whyTheyMatter: "Worth a thoughtful follow-up while it's fresh.",
            whenToFollowUp: "Within the next 48 hours.",
            draftedMessage: trimmed.isEmpty ? "Hi \(personName), great meeting you — let's stay in touch!" : trimmed,
            introIdeas: ["Think about who in your network would benefit from meeting \(personName)."],
            reminderNote: "Follow up with \(personName) soon."
        )
    }
}
