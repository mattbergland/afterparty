import SwiftUI
import AfterpartyKit

/// The capture screen: a single note field, tone, optional signature, and the
/// primary "Create Follow-Up" action.
struct InputView: View {
    @EnvironmentObject private var viewModel: FollowUpViewModel
    @FocusState private var noteFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                noteCard

                if viewModel.noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    emptyStateHint
                }

                tonePicker

                signatureField

                createButton
            }
            .padding(20)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Afterparty")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.accentGradient)
                .accessibilityIdentifier("appTitle")

            Text("Remember everyone you meet.")
                .font(.title3.weight(.semibold))
                .foregroundColor(Theme.textPrimary)

            Text("Drop a quick note about someone you just met — Afterparty writes the perfect follow-up.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.top, 24)
    }

    // MARK: Note editor

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Who did you meet?", systemImage: "sparkles")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            ZStack(alignment: .topLeading) {
                if viewModel.noteText.isEmpty {
                    Text("Met Sarah at the AI dinner. She runs developer marketing at Datadog. We talked about customer hackathons and SF venues.")
                        .font(.body)
                        .foregroundColor(Theme.textTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 12)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $viewModel.noteText)
                    .focused($noteFocused)
                    .font(.body)
                    .foregroundColor(Theme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 150)
                    .accessibilityIdentifier("noteInput")
            }
            .padding(10)
            .background(Theme.inkElevated, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Theme.electric.opacity(noteFocused ? 0.8 : 0.25), lineWidth: 1)
            )
        }
    }

    private var emptyStateHint: some View {
        Button {
            viewModel.loadSample()
        } label: {
            Label("Try the example note", systemImage: "wand.and.stars")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Theme.mint)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Theme.mint.opacity(0.12), in: Capsule())
        }
        .accessibilityIdentifier("loadSampleButton")
    }

    // MARK: Tone

    private var tonePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tone of the message")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Theme.textSecondary)

            Picker("Tone", selection: $viewModel.tone) {
                ForEach(FollowUpTone.allCases) { tone in
                    Text(tone.displayName).tag(tone)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("tonePicker")
        }
    }

    // MARK: Signature

    private var signatureField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sign as (optional)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Theme.textSecondary)

            TextField("Your name", text: $viewModel.senderName)
                .textFieldStyle(.plain)
                .foregroundColor(Theme.textPrimary)
                .padding(14)
                .background(Theme.inkElevated, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Theme.electric.opacity(0.2), lineWidth: 1)
                )
                .accessibilityIdentifier("senderNameInput")
        }
    }

    // MARK: Primary action

    private var createButton: some View {
        Button {
            noteFocused = false
            Task { await viewModel.createFollowUp() }
        } label: {
            Text("Create Follow-Up")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.accentGradient, in: RoundedRectangle(cornerRadius: 16))
                .opacity(viewModel.canSubmit ? 1 : 0.4)
                .shadow(color: Theme.neon.opacity(viewModel.canSubmit ? 0.4 : 0), radius: 16, y: 8)
        }
        .disabled(!viewModel.canSubmit)
        .accessibilityIdentifier("createFollowUpButton")
        .padding(.top, 4)
    }
}
