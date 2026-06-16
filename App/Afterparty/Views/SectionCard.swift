import SwiftUI
import AfterpartyKit

/// Renders one ``FollowUpSection`` as a card. List-style sections (intros) show
/// bullets; the drafted message shows a copy button.
struct SectionCard: View {
    let section: FollowUpSection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if let bullets = section.bullets {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(bullets.enumerated()), id: \.offset) { _, item in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "arrow.turn.down.right")
                                .font(.caption)
                                .foregroundColor(section.kind.accentColor)
                                .padding(.top, 3)
                            Text(item)
                                .font(.body)
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                }
            } else {
                Text(section.body)
                    .font(.body)
                    .foregroundColor(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if section.kind == .draftedMessage {
                copyButton
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Theme.inkElevated, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(section.kind.accentColor.opacity(0.35), lineWidth: 1)
        )
        .accessibilityIdentifier("card_\(section.kind.rawValue)")
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(section.kind.accentColor.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: section.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(section.kind.accentColor)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(section.title)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Text(section.subtitle)
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
            }
            Spacer()
        }
    }

    private var copyButton: some View {
        Button {
            #if canImport(UIKit)
            UIPasteboard.general.string = section.body
            #endif
        } label: {
            Label("Copy message", systemImage: "doc.on.doc")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(section.kind.accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(section.kind.accentColor.opacity(0.12), in: Capsule())
        }
        .accessibilityIdentifier("copyMessageButton")
        .padding(.top, 2)
    }
}
