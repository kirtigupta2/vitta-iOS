import SwiftUI
import UIKit

// MARK: - Colors (from the Figma file)

extension Color {
    /// Color(hex: 0x084BA4) or Color(hex: 0x084BA4, alpha: 0.25)
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

enum VColors {
    static let primary = Color(hex: 0x084BA4)
    static let primaryHover = Color(hex: 0x063A82)
    static let textPrimary = Color(hex: 0x0E1A2B)
    static let textSecondary = Color(hex: 0x3C4A5E)
    static let success = Color(hex: 0x1A7F4E)
    static let surfaceMuted = Color(hex: 0xF3F7FB)
    static let sheet = Color(hex: 0xF7FAFF)
    static let screenBg = Color(hex: 0xF8FAFD)
    static let border = Color(hex: 0xD3DFEC)
    static let blue100 = Color(hex: 0xCCD9FC)
    static let slate500 = Color(hex: 0x6B7280)
}

// MARK: - Fonts
// The Figma file uses Roboto. This uses the iOS system font (SF Pro), which
// looks nearly the same. To use Roboto: add the TTF files to the project, list
// them in Info.plist ("Fonts provided by application") and change this to
// Font.custom("Roboto-Regular", size: size) etc.

func vFont(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
    Font.system(size: size, weight: weight)
}

// MARK: - Shadows

extension View {
    func vCardShadow() -> some View {
        self
            .shadow(color: Color(hex: 0x000000, alpha: 0.06), radius: 1.5, x: 0, y: 1)
            .shadow(color: Color(hex: 0x084AA3, alpha: 0.12), radius: 8, x: 0, y: 4)
    }

    func vFloatingShadow() -> some View {
        self
            .shadow(color: Color(hex: 0x000000, alpha: 0.08), radius: 1.5, x: 0, y: 1)
            .shadow(color: Color(hex: 0x084AA3, alpha: 0.16), radius: 10, x: 0, y: 6)
    }

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        )
    }
}

// MARK: - Screen insets
// The Figma frames assume a 54 pt status bar, so the top inset is never below 54.

struct ScreenInsets {
    var top: CGFloat = 54
    var bottom: CGFloat = 0
}

private struct ScreenInsetsKey: EnvironmentKey {
    static let defaultValue = ScreenInsets()
}

extension EnvironmentValues {
    var insets: ScreenInsets {
        get { self[ScreenInsetsKey.self] }
        set { self[ScreenInsetsKey.self] = newValue }
    }
}

// MARK: - Radial gradient helper (Flutter-style "radius = fraction of box")

struct RadialBlob: View {
    let center: UnitPoint
    let radius: CGFloat
    let colors: [Color]
    var stops: [CGFloat]? = nil

    var body: some View {
        GeometryReader { g in
            let r = min(g.size.width, g.size.height) * radius
            RadialGradient(
                gradient: Gradient(stops: gradientStops()),
                center: center,
                startRadius: 0,
                endRadius: r
            )
        }
    }

    private func gradientStops() -> [Gradient.Stop] {
        let n = colors.count
        return colors.enumerated().map { index, color in
            let location: CGFloat
            if let stops = stops, index < stops.count {
                location = stops[index]
            } else {
                location = n > 1 ? CGFloat(index) / CGFloat(n - 1) : 0
            }
            return Gradient.Stop(color: color, location: location)
        }
    }
}
