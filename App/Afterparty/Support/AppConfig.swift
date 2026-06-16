import Foundation
import AfterpartyKit

/// Resolves runtime configuration and the active AI provider.
enum AppConfig {
    /// `true` when the app is launched by the XCUITest target with
    /// `-UITEST_MOCK 1`. In that mode the app uses the offline ``MockProvider``
    /// and prefills the canonical example so the UI test reliably reaches a
    /// fully-populated results screen with no network and no API key.
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITEST_MOCK")
            || ProcessInfo.processInfo.environment["UITEST_MOCK"] == "1"
    }

    /// The Anthropic API key, read from the environment or the app's Info.plist.
    /// Never hardcoded.
    static var anthropicAPIKey: String? {
        if let env = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"],
           !env.isEmpty {
            return env
        }
        if let plist = Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_API_KEY") as? String,
           !plist.isEmpty,
           !plist.hasPrefix("$(") {
            return plist
        }
        return nil
    }

    /// The note pre-loaded into the editor on first launch (and during UI tests).
    static let sampleNote = "Met Sarah at the AI dinner. She runs developer marketing at Datadog. We talked about customer hackathons and SF venues."

    /// Builds the provider for this launch.
    ///
    /// - During UI tests: always ``MockProvider``.
    /// - Otherwise: ``ClaudeProvider`` when an API key is available, else
    ///   ``MockProvider`` so the app is always demoable offline.
    static func makeProvider() -> (provider: AIProvider, isLive: Bool) {
        if isUITesting {
            return (MockProvider(), false)
        }
        if let key = anthropicAPIKey, let claude = try? ClaudeProvider(apiKey: key) {
            return (claude, true)
        }
        return (MockProvider(), false)
    }
}
