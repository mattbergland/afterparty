import SwiftUI

/// Shown when generation fails (e.g. a network error from the live provider).
struct ErrorView: View {
    @EnvironmentObject private var viewModel: FollowUpViewModel
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.bubble")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(Theme.neon)

            Text("Couldn't write that follow-up")
                .font(.title3.weight(.bold))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.startOver()
            } label: {
                Text("Try again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Theme.accentGradient, in: Capsule())
            }
            .accessibilityIdentifier("tryAgainButton")
        }
        .padding(32)
        .accessibilityIdentifier("errorView")
    }
}
