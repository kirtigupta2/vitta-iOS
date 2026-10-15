import SwiftUI

// Live previews for Xcode's canvas (Editor > Canvas, then press Resume).
// Each one shows a screen on its own, without running the whole app.

private struct PreviewHost<Content: View>: View {
    @StateObject private var app = AppState()
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .environment(\.insets, ScreenInsets(top: 59, bottom: 34))
            .environmentObject(app)
            .ignoresSafeArea()
    }
}

struct Previews_A01_Home: PreviewProvider {
    static var previews: some View {
        PreviewHost { HomeView() }
    }
}

struct Previews_A04_Building: PreviewProvider {
    static var previews: some View {
        PreviewHost { BuildView() }
    }
}

struct Previews_A05_CardIntro: PreviewProvider {
    static var previews: some View {
        PreviewHost { CardIntroView() }
    }
}

struct Previews_FullFlow: PreviewProvider {
    static var previews: some View {
        RootView()   // the real app: long-press a card to try A02 -> A05
    }
}
