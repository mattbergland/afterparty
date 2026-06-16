import SwiftUI
import AfterpartyKit

/// Afterparty's visual identity: a late-night, neon-on-ink palette that feels
/// like the glow after a great event.
enum Theme {
    // MARK: Brand colors

    static let ink = Color(red: 0.05, green: 0.04, blue: 0.12)        // near-black indigo
    static let inkElevated = Color(red: 0.10, green: 0.09, blue: 0.20) // card surface
    static let neon = Color(red: 1.0, green: 0.36, blue: 0.55)        // coral-pink accent
    static let electric = Color(red: 0.45, green: 0.40, blue: 1.0)    // electric violet
    static let mint = Color(red: 0.36, green: 0.93, blue: 0.76)       // success/mint
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.45)

    /// The signature background gradient used on every screen.
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.05, blue: 0.18),
                Color(red: 0.04, green: 0.03, blue: 0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// The accent gradient used for the primary button and highlights.
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [neon, electric],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Per-section accent so the result cards feel distinct but cohesive.
    static func accent(for kind: FollowUpSectionAccent) -> Color {
        switch kind {
        case .identity: return electric
        case .context: return Color(red: 0.40, green: 0.74, blue: 1.0)
        case .conversation: return mint
        case .value: return Color(red: 1.0, green: 0.78, blue: 0.36)
        case .timing: return Color(red: 1.0, green: 0.55, blue: 0.40)
        case .message: return neon
        case .intros: return Color(red: 0.66, green: 0.56, blue: 1.0)
        case .reminder: return Color(red: 0.55, green: 0.92, blue: 0.70)
        }
    }
}

/// Maps a section to its accent bucket.
enum FollowUpSectionAccent {
    case identity, context, conversation, value, timing, message, intros, reminder
}

extension FollowUpSectionKind {
    var accent: FollowUpSectionAccent {
        switch self {
        case .whoTheyAre: return .identity
        case .whereYouMet: return .context
        case .whatYouTalkedAbout: return .conversation
        case .whyTheyMatter: return .value
        case .whenToFollowUp: return .timing
        case .draftedMessage: return .message
        case .introIdeas: return .intros
        case .reminderNote: return .reminder
        }
    }

    var accentColor: Color { Theme.accent(for: accent) }
}
