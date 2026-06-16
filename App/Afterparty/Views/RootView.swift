import SwiftUI
import AfterpartyKit

/// Hosts the single-screen flow and swaps content based on the view model phase.
struct RootView: View {
    @EnvironmentObject private var viewModel: FollowUpViewModel

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            switch viewModel.phase {
            case .input:
                InputView()
                    .transition(.opacity)
            case .loading:
                LoadingView()
                    .transition(.opacity)
            case .result(let followUp):
                ResultsView(followUp: followUp)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .failed(let message):
                ErrorView(message: message)
                    .transition(.opacity)
            }
        }
        .tint(Theme.neon)
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(
                FollowUpViewModel(
                    engine: FollowUpEngine(provider: MockProvider()),
                    isLiveProvider: false,
                    initialNote: AppConfig.sampleNote
                )
            )
    }
}
#endif
