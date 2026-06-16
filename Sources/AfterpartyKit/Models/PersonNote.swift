import Foundation

/// The single MVP input: a quick, free-form note about a person you just met.
///
/// Future versions may accept a badge photo, business card, LinkedIn screenshot,
/// or LinkedIn QR code, but the MVP keeps the input to a typed/pasted note.
public struct PersonNote: Codable, Equatable, Sendable {
    /// The raw text the user typed or pasted.
    public var text: String

    public init(text: String) {
        self.text = text
    }

    /// The note with leading/trailing whitespace removed.
    public var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// `true` when there is no usable content at all.
    public var isEmpty: Bool {
        trimmed.isEmpty
    }

    /// `true` when the note is present but too short to be meaningful.
    ///
    /// The engine still produces a result for short notes; this flag simply lets
    /// the UI nudge the user toward adding more context.
    public var isTooShort: Bool {
        !isEmpty && trimmed.count < 12
    }
}
