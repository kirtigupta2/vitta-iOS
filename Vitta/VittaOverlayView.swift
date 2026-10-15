import SwiftUI

/// A02: glowing ring where you pressed.
/// A03: screen dims, the card lifts above it, suggestion chips appear.
/// Tapping a chip "types" it into the search box, then Vitta starts building.
/// You can also type your own question and send it.
struct VittaOverlayView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.insets) private var insets

    let info: OverlayInfo

    @State private var showSuggestions = false
    @State private var ringIn = false
    @State private var text = ""
    @State private var busy = false

    private let suggestions = [
        "Best fit for me",
        "Why am I seeing this?",
        "How can I apply for this?"
    ]
    private let orbSize: CGFloat = 113

    var body: some View {
        ZStack {
            // Scrim: clear while the ring shows, dim for suggestions.
            Color(hex: 0x0E1A2B, alpha: showSuggestions ? 0.6 : 0.001)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !busy { app.overlay = nil }
                }

            // The pressed card, lifted above the scrim.
            info.card
                .frame(width: info.rect.width, height: info.rect.height)
                .position(x: info.rect.midX, y: info.rect.midY)
                .allowsHitTesting(false)

            // Glowing ring under the finger.
            VittaOrb(size: orbSize)
                .scaleEffect(ringIn ? 1 : 0.6)
                .opacity(showSuggestions ? 0 : 1)
                .position(x: info.press.x, y: info.press.y)
                .allowsHitTesting(false)

            // Chips + search box + nav (with Vitta selected)
            VStack(spacing: 0) {
                Spacer()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { s in
                            chip(s)
                        }
                    }
                    .padding(.leading, 17.5)
                    .padding(.trailing, 16)
                    .padding(.vertical, 4)
                }
                .frame(height: 52)

                Spacer().frame(height: 8)

                SearchDock(
                    text: $text,
                    onSend: { go() },
                    onMic: { app.showProto("Dictation") }
                )
                .padding(.horizontal, 17.5)

                Spacer().frame(height: 12)

                VittaBottomNav(selected: 4) { i in
                    if i == 0 {
                        app.overlay = nil
                    } else if i != 4 {
                        app.showProto(VittaTab.all[i].label)
                    }
                }
                .padding(.horizontal, 17.5)
                .padding(.bottom, 16 + insets.bottom)
            }
            .opacity(showSuggestions ? 1 : 0)
            .offset(y: showSuggestions ? 0 : 12)
            .allowsHitTesting(showSuggestions)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { ringIn = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation(.easeOut(duration: 0.3)) { showSuggestions = true }
            }
        }
    }

    private func chip(_ label: String) -> some View {
        Button {
            typeAndGo(label)
        } label: {
            Text(label)
                .font(vFont(12))
                .foregroundColor(VColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xFDF0E9), Color(hex: 0xDEE9F2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.16), radius: 1, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(busy)
    }

    /// Types the chip text into the search box letter by letter, then goes on.
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

    /// A04: start building the recommendation.
    private func go() {
        app.overlay = nil
        withAnimation(.easeInOut(duration: 0.35)) { app.screen = .building }
    }
}

/// Rotating ring (ring.png), with a drawn fallback.
struct VittaOrb: View {
    var size: CGFloat = 113
    @State private var spin = false

    var body: some View {
        ZStack {
            if UIImage(named: "ring") != nil {
                Image("ring")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 1.45, height: size * 1.45)
                    .rotationEffect(.degrees(spin ? 360 : 0))
                    .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: spin)
            } else {
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            colors: [
                                Color(hex: 0xFC8742), Color(hex: 0x3476AE),
                                Color(hex: 0x084BA4), Color(hex: 0xFC8742)
                            ],
                            center: .center
                        ),
                        lineWidth: 8
                    )
                    .blur(radius: 2)
                    .frame(width: size * 0.8, height: size * 0.8)
                    .rotationEffect(.degrees(spin ? 360 : 0))
                    .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: spin)
            }
        }
        .frame(width: size, height: size)
        .onAppear { spin = true }
    }
}
