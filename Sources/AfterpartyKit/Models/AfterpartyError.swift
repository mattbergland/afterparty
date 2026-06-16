import Foundation

/// Errors surfaced by the Afterparty engine and providers.
public enum AfterpartyError: Error, Equatable, LocalizedError, Sendable {
    /// The note was empty, so there is nothing to work with.
    case emptyInput
    /// `ANTHROPIC_API_KEY` was not available when a real call was attempted.
    case missingAPIKey
    /// A transport-level failure (no connection, timeout, etc.).
    case network(String)
    /// The API responded with a non-2xx status code.
    case http(status: Int, message: String)
    /// The API response could not be parsed into a ``FollowUp``.
    case decoding(String)

    public var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "Add a quick note about who you met before creating a follow-up."
        case .missingAPIKey:
            return "Missing ANTHROPIC_API_KEY. Set it to use the live Claude provider."
        case .network(let detail):
            return "Network error: \(detail)"
        case .http(let status, let message):
            return "Claude API returned status \(status): \(message)"
        case .decoding(let detail):
            return "Could not read Claude's response: \(detail)"
        }
    }
}
