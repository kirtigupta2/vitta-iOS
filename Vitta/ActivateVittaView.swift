import SwiftUI

/// "Activate Vitta": tap the Vitta tab on Home. Home dims, suggestion chips and
/// the Ask Vitta panel (with the search box) slide up above the nav bar.
/// Tap a chip (it is typed into the box) or type your own question and send.
struct ActivateVittaView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.insets) private var insets

    @State private var text = ""
    @State private var busy = false

    private let suggestions = [
        "Analyze my spendings",
        "Saving insights this month",
        "How can I apply for this?"
    ]

    var body: some View {
        ZStack {
            // Dimmed Home behind (72% like the Figma frame)
            Color(hex: 0x0E1A2B, alpha: 0.72)
                .contentShape(Rectangle())
                .onTapGesture { if !busy { close() } }

            VStack(spacing: 0) {
                Spacer()

                // Suggestion chips (44 high)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { s in chip(s) }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 44)

                Spacer().frame(height: 12)

                // Ask Vitta panel
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        VIcon(asset: "vitta", symbol: "sparkles", size: 18, color: VColors.primary)
                        Text("Ask Vitta")
                            .font(vFont(14, .bold))
                            .foregroundColor(VColors.primary)
                        Spacer()
                        Button(action: close) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(VColors.textPrimary)
                                .frame(width: 44, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(busy)
                    }
                    .frame(height: 32)

                    SearchDock(
                        text: $text,
                        onSend: { go() },
                        onMic: { app.showProto("Dictation") }
                    )
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 124)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xFDF0E9), Color(hex: 0xDEE9F2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .vCardShadow()
                .padding(.horizontal, 16)

                Spacer().frame(height: 16)

                // Bottom nav with Vitta selected
                VittaBottomNav(selected: 4) { i in
                    if i == 0 {
                        close()
                    } else if i != 4 {
                        app.showProto(VittaTab.all[i].label)
                    }
                }
                .padding(.horizontal, 17.5)
                .padding(.bottom, 16 + insets.bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func chip(_ label: String) -> some View {
        Button {
            typeAndGo(label)
        } label: {
            Text(label)
                .font(vFont(12))
                .foregroundColor(VColors.textPrimary)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xFDF0E9), Color(hex: 0xDEE9F2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Color.black.opacity(0.16), radius: 1, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(busy)
    }

    private func close() {
        withAnimation(.easeOut(duration: 0.25)) { app.activateVitta = false }
    }

    /// Types the chip text into the search box, then starts building.
    private func typeAndGo(_ label: String) {
        guard !busy else { return }
        busy = true
        text = ""
        Task { @MainActor in
            for ch in label {
                text.append(ch)
                try? await Task.sleep(nanoseconds: 45_000_000)
            }
            try? await Task.sleep(nanoseconds: 450_000_000)
            go()
        }
    }

    /// A04: Vitta builds the recommendation.
    private func go() {
        app.activateVitta = false
        withAnimation(.easeInOut(duration: 0.35)) { app.screen = .building }
    }
}
