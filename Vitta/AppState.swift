import SwiftUI

enum Screen {
    case home       // A01
    case building   // A04
    case intro      // A05
}

enum MiniStatus {
    case building
    case ready
}

/// Information about the card that was long-pressed (A02 / A03).
struct OverlayInfo {
    let rect: CGRect      // card frame in screen coordinates
    let press: CGPoint    // where the finger is
    let card: AnyView     // a copy of the card to lift above the scrim
}

final class AppState: ObservableObject {
    @Published var screen: Screen = .home
    @Published var mini: MiniStatus? = nil
    @Published var overlay: OverlayInfo? = nil
    @Published var toast: String? = nil

    private var toastToken = 0

    func showToast(_ message: String) {
        toastToken += 1
        let token = toastToken
        withAnimation(.easeOut(duration: 0.2)) { toast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self, self.toastToken == token else { return }
            withAnimation(.easeIn(duration: 0.2)) { self.toast = nil }
        }
    }

    func showProto(_ what: String) {
        showToast("\(what) isn't part of this prototype")
    }

    /// Minimize button: back to Home with the small floating card.
    func minimize(_ status: MiniStatus) {
        mini = status
        overlay = nil
        withAnimation(.easeInOut(duration: 0.3)) { screen = .home }
    }

    /// Back button: return to Home, keep any minimized session.
    func goHome() {
        overlay = nil
        withAnimation(.easeInOut(duration: 0.3)) { screen = .home }
    }

    /// Close button: back to Home and forget the session.
    func closeFlow() {
        mini = nil
        overlay = nil
        withAnimation(.easeInOut(duration: 0.3)) { screen = .home }
    }

    func openMini() {
        guard let status = mini else { return }
        mini = nil
        withAnimation(.easeInOut(duration: 0.3)) {
            screen = (status == .ready) ? .intro : .building
        }
    }
}
