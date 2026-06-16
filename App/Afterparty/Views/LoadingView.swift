import SwiftUI

/// Shown while the engine is generating a follow-up.
struct LoadingView: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(Theme.accentGradient)
                    .frame(width: 90, height: 90)
                    .scaleEffect(pulse ? 1.08 : 0.92)
                    .opacity(pulse ? 1 : 0.7)
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: Theme.neon.opacity(0.5), radius: 24)

            Text("Reading the room…")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            Text("Writing your follow-up and intro ideas.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
        .padding()
        .accessibilityIdentifier("loadingView")
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
