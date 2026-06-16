import SwiftUI
import AfterpartyKit

/// The "magical output" screen: one card per required section.
struct ResultsView: View {
    @EnvironmentObject private var viewModel: FollowUpViewModel
    let followUp: FollowUp

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                ForEach(followUp.sections) { section in
                    SectionCard(section: section)
                }

                startOverButton
            }
            .padding(20)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .accessibilityIdentifier("resultsScreen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Follow-up ready")
                .font(.caption.weight(.bold))
                .foregroundColor(Theme.mint)
                .textCase(.uppercase)
                .tracking(1.5)

            Text(followUp.personName)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.accentGradient)
                .accessibilityIdentifier("resultsPersonName")

            Text("Everything you need so you don't lose this connection.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)

            if !viewModel.isLiveProvider {
                Label("Offline demo mode", systemImage: "wifi.slash")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(Theme.textTertiary)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 28)
    }

    private var startOverButton: some View {
        Button {
            viewModel.startOver()
        } label: {
            Label("Capture someone else", systemImage: "plus.circle")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Theme.electric.opacity(0.25), in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Theme.electric.opacity(0.6), lineWidth: 1)
                )
        }
        .accessibilityIdentifier("startOverButton")
        .padding(.top, 6)
        .padding(.bottom, 24)
    }
}

#if DEBUG
struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(followUp: MockProvider.followUp(for: FollowUpRequest(noteText: AppConfig.sampleNote, tone: .warm, senderName: "Matt")))
            .environmentObject(
                FollowUpViewModel(engine: FollowUpEngine(provider: MockProvider()), isLiveProvider: false)
            )
            .background(Theme.backgroundGradient)
    }
}
#endif
