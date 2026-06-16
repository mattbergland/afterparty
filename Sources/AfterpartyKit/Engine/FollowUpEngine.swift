import Foundation

/// The top-level entry point used by the app.
///
/// It validates input, then delegates generation to an injected ``AIProvider``.
/// Swap providers to move between offline (``MockProvider``) and live
/// (``ClaudeProvider``) behaviour without touching the UI.
public struct FollowUpEngine: Sendable {
    public let provider: AIProvider

    public init(provider: AIProvider) {
        self.provider = provider
    }

    /// Generates a complete ``FollowUp`` for the given request.
    ///
    /// - Throws: ``AfterpartyError/emptyInput`` when the note has no content,
    ///   or any error surfaced by the underlying provider.
    public func generateFollowUp(for request: FollowUpRequest) async throws -> FollowUp {
        guard !request.note.isEmpty else {
            throw AfterpartyError.emptyInput
        }
        return try await provider.generateFollowUp(for: request)
    }
}
