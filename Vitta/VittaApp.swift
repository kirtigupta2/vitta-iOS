import SwiftUI

@main
struct VittaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Holds the whole flow: Home (A01) with the ring/suggestions overlay (A02/A03),
/// then Building (A04) and Card intro (A05).
struct RootView: View {
    @StateObject private var app = AppState()

    var body: some View {
        // The reader keeps the safe area so we can read the real insets; the
        // content inside ignores it and draws edge to edge.
        GeometryReader { proxy in
            let insets = ScreenInsets(
                top: max(proxy.safeAreaInsets.top, 54),
                bottom: proxy.safeAreaInsets.bottom
            )
            ZStack {
                HomeView()

                // Building -> Card intro swaps instantly. A cross-fade lets the
                // Home screen show through for a split second.
                if app.screen == .building {
                    BuildView()
                        .transition(.asymmetric(insertion: .opacity, removal: .identity))
                }
                if app.screen == .intro {
                    CardIntroView()
                        .transition(.asymmetric(insertion: .identity, removal: .opacity))
                }
                if app.activateVitta {
                    ActivateVittaView()
                        .transition(.opacity)
                        .zIndex(2)
                }
                if let info = app.overlay, info.rect.width > 1, info.rect.height > 1 {
                    VittaOverlayView(info: info)
                        .transition(.opacity)
                        .zIndex(2)
                }
                if let message = app.toast {
                    VStack {
                        Spacer()
                        ToastView(message: message)
                            .padding(.bottom, insets.bottom + 90)
                    }
                    .transition(.opacity)
                    .allowsHitTesting(false)
                    .zIndex(3)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: app.overlay != nil)
            .animation(.easeInOut(duration: 0.3), value: app.activateVitta)
            .environment(\.insets, insets)
            .environmentObject(app)
            .ignoresSafeArea(.container)
        }
    }
}
