import Foundation

/// The structured request handed to an ``AIProvider``.
public struct FollowUpRequest: Codable, Equatable, Sendable {
    /// The note describing the person you met.
    public var note: PersonNote

    /// The desired voice for the drafted message.
    public var tone: FollowUpTone

    /// The name of the person sending the follow-up (used to sign the message).
    /// Optional — the engine produces a sensible draft even when it is absent.
    public var senderName: String?

    public init(note: PersonNote, tone: FollowUpTone = .warm, senderName: String? = nil) {
        self.note = note
        self.tone = tone
        self.senderName = senderName
    }

    /// Convenience initializer from a raw string of note text.
    public init(noteText: String, tone: FollowUpTone = .warm, senderName: String? = nil) {
        self.init(note: PersonNote(text: noteText), tone: tone, senderName: senderName)
    }
}
