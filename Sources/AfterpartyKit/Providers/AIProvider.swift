import Foundation

/// Abstraction over anything that can turn a ``FollowUpRequest`` into a
/// structured ``FollowUp``.
///
/// Two implementations ship with the kit:
/// - ``MockProvider`` — deterministic, offline, no API key. Used by tests and
///   SwiftUI previews.
/// - ``ClaudeProvider`` — real calls to the Anthropic Messages API.
public protocol AIProvider: Sendable {
    func generateFollowUp(for request: FollowUpRequest) async throws -> FollowUp
}
