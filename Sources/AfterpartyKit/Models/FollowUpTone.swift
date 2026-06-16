import Foundation

/// The voice used for the drafted follow-up message.
public enum FollowUpTone: String, Codable, CaseIterable, Identifiable, Sendable {
    case warm
    case professional
    case playful

    public var id: String { rawValue }

    /// Human-friendly label for pickers in the UI.
    public var displayName: String {
        switch self {
        case .warm: return "Warm"
        case .professional: return "Professional"
        case .playful: return "Playful"
        }
    }

    /// Guidance handed to the AI model when drafting the message.
    public var promptDescription: String {
        switch self {
        case .warm:
            return "warm, friendly, and personal while staying concise"
        case .professional:
            return "polished, professional, and to the point"
        case .playful:
            return "light, playful, and energetic without being unprofessional"
        }
    }
}
