import Foundation
import SwiftUI
import AfterpartyKit

/// Drives the single-screen capture → result flow. All real work is delegated
/// to ``FollowUpEngine`` in AfterpartyKit; this view model only holds UI state.
@MainActor
final class FollowUpViewModel: ObservableObject {

    enum Phase: Equatable {
        case input
        case loading
        case result(FollowUp)
        case failed(String)
    }

    // MARK: Inputs
    @Published var noteText: String
    @Published var tone: FollowUpTone = .warm
    @Published var senderName: String = ""

    // MARK: Output
    @Published private(set) var phase: Phase = .input

    let isLiveProvider: Bool
    private let engine: FollowUpEngine

    init(engine: FollowUpEngine, isLiveProvider: Bool, initialNote: String = "") {
        self.engine = engine
        self.isLiveProvider = isLiveProvider
        self.noteText = initialNote
    }

    /// Convenience factory wiring the engine from ``AppConfig``.
    static func live() -> FollowUpViewModel {
        let resolved = AppConfig.makeProvider()
        let initial = AppConfig.isUITesting ? AppConfig.sampleNote : ""
        return FollowUpViewModel(
            engine: FollowUpEngine(provider: resolved.provider),
            isLiveProvider: resolved.isLive,
            initialNote: initial
        )
    }

    var canSubmit: Bool {
        !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isLoading: Bool {
        if case .loading = phase { return true }
        return false
    }

    func createFollowUp() async {
        let request = FollowUpRequest(
            noteText: noteText,
            tone: tone,
            senderName: senderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : senderName.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        phase = .loading
        do {
            let followUp = try await engine.generateFollowUp(for: request)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                phase = .result(followUp)
            }
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            withAnimation { phase = .failed(message) }
        }
    }

    func startOver() {
        withAnimation { phase = .input }
    }

    func loadSample() {
        noteText = AppConfig.sampleNote
    }
}
