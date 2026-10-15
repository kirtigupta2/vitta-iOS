import SwiftUI
import UIKit

// MARK: - Images and icons

/// Loads a PNG from Assets.xcassets by name. If you have not added it yet, a
/// tinted placeholder with an SF Symbol is shown so the app still runs.
struct AssetImage: View {
    let name: String
    var fallbackSymbol: String = "photo"
    var fallbackColor: Color = Color(hex: 0x084BA4, alpha: 0.1)
    var fallbackIconColor: Color = Color(hex: 0x084BA4, alpha: 0.4)
    var contentMode: ContentMode = .fill
    var alignment: Alignment = .center

    var body: some View {
        if UIImage(named: name) != nil {
            GeometryReader { g in
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: g.size.width, height: g.size.height, alignment: alignment)
                    .clipped()
            }
        } else {
            ZStack {
                fallbackColor
                Image(systemName: fallbackSymbol)
                    .font(.system(size: 20))
                    .foregroundColor(fallbackIconColor)
            }
        }
    }
}

/// An icon exported from Figma (SVG or PDF in Assets.xcassets). If it is not
/// added yet, the SF Symbol is used instead.
struct VIcon: View {
    let asset: String
    let symbol: String
    var size: CGFloat = 24
    var color: Color = .white

    var body: some View {
        if UIImage(named: asset) != nil {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: symbol)
                .font(.system(size: size * 0.8, weight: .regular))
                .foregroundColor(color)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Loader / spinner

/// The spinning loader icon from Figma (loader.png), with a system fallback.
struct VittaLoader: View {
    var size: CGFloat = 16
    @State private var spin = false

    var body: some View {
        Group {
            if UIImage(named: "loader") != nil {
                Image("loader")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(spin ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: spin)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(size / 20)
            }
        }
        .frame(width: size, height: size)
        .onAppear { spin = true }
    }
}

struct SmallSpinner: View {
    var size: CGFloat = 16

    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(VColors.primary)
            .scaleEffect(size / 20)
            .frame(width: size, height: size)
    }
}

// MARK: - Backgrounds

/// Soft blue / peach background used on the Vitta screens (A04, A05).
struct VittaBackground: View {
    var body: some View {
        ZStack {
            VColors.screenBg
            RadialBlob(
                center: UnitPoint(x: 0, y: 0.425),
                radius: 0.9,
                colors: [Color(hex: 0x3476AE, alpha: 0.25), Color(hex: 0x3476AE, alpha: 0)]
            )
            RadialBlob(
                center: UnitPoint(x: 1, y: 0.975),
                radius: 0.95,
                colors: [
                    Color(hex: 0xFC8742, alpha: 0.25),
                    Color(hex: 0xF5A475, alpha: 0.10),
                    Color(hex: 0xF5A475, alpha: 0)
                ],
                stops: [0, 0.5, 1]
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Offer card (A01 list)

let offerGradient = LinearGradient(
    stops: [
        .init(color: Color(hex: 0xE4EDF8), location: 0),
        .init(color: Color(hex: 0xFBFCFE), location: 0.45),
        .init(color: Color(hex: 0xFCE9DC), location: 1)
    ],
    startPoint: .leading,
    endPoint: .trailing
)

/// Small horizontal "Recommended for you" card, 317 x 63.
struct OfferCard: View {
    let title: String
    let subtitle: String
    let imageName: String
    var subtitleWeight: Font.Weight = .regular
    var imageSize: CGFloat = 64
    var imageLeft: CGFloat = 245
    var imageTop: CGFloat = 9

    var body: some View {
        ZStack(alignment: .topLeading) {
            offerGradient

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(vFont(14, .bold))
                    .foregroundColor(VColors.primaryHover)
                    .lineLimit(1)
                    .frame(height: 21, alignment: .leading)
                Text(subtitle)
                    .font(vFont(12, subtitleWeight))
                    .foregroundColor(VColors.textPrimary)
                    .lineLimit(1)
                    .frame(height: 18, alignment: .leading)
            }
            .frame(width: 227, alignment: .leading)
            .offset(x: 12, y: 12)

            AssetImage(name: imageName, fallbackSymbol: "tag")
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
                .offset(x: imageLeft, y: imageTop)
        }
        .frame(width: 317, height: 63)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .vCardShadow()
    }
}

// MARK: - Long press to ask Vitta (A01 -> A02 -> A03)

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

/// Wrap any card with this to get "long press to ask Vitta".
struct AskVitta<Content: View>: View {
    @EnvironmentObject var app: AppState
    @State private var frame: CGRect = .zero
    @State private var touch: CGPoint? = nil
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .background(
                GeometryReader { g in
                    Color.clear.preference(
                        key: FramePreferenceKey.self,
                        value: g.frame(in: .global)
                    )
                }
            )
            .onPreferenceChange(FramePreferenceKey.self) { frame = $0 }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { touch = $0.location }
            )
            .onLongPressGesture(minimumDuration: 0.5) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                let press = touch ?? CGPoint(x: frame.midX, y: frame.midY)
                app.overlay = OverlayInfo(
                    rect: frame,
                    press: press,
                    card: AnyView(content())
                )
            }
    }
}

// MARK: - Bottom navigation

struct VittaTab {
    let label: String
    let asset: String
    let selectedAsset: String?
    let symbol: String
    let selectedSymbol: String

    static let all: [VittaTab] = [
        VittaTab(label: "Home", asset: "tab_home_outline", selectedAsset: "tab_home",
                 symbol: "house", selectedSymbol: "house.fill"),
        VittaTab(label: "Pay", asset: "tab_pay", selectedAsset: nil,
                 symbol: "arrow.left.arrow.right", selectedSymbol: "arrow.left.arrow.right"),
        VittaTab(label: "Investment", asset: "tab_investment", selectedAsset: nil,
                 symbol: "chart.line.uptrend.xyaxis", selectedSymbol: "chart.line.uptrend.xyaxis"),
        VittaTab(label: "Benefits", asset: "tab_benefits", selectedAsset: nil,
                 symbol: "gift", selectedSymbol: "gift.fill"),
        VittaTab(label: "Vitta", asset: "tab_vitta", selectedAsset: "tab_vitta_selected",
                 symbol: "sparkles", selectedSymbol: "sparkles")
    ]
}

struct VittaBottomNav: View {
    let selected: Int
    let onTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<VittaTab.all.count, id: \.self) { i in
                Button {
                    onTap(i)
                } label: {
                    TabButton(tab: VittaTab.all[i], isSelected: i == selected)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 5)
        .frame(height: 58)
        .background(Color.white.opacity(0.97))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color(hex: 0x6D8FFF, alpha: 0.15), lineWidth: 1)
        )
        .vFloatingShadow()
    }
}

private struct TabButton: View {
    let tab: VittaTab
    let isSelected: Bool

    var body: some View {
        let color = isSelected ? VColors.primary : VColors.textSecondary
        let asset = isSelected ? (tab.selectedAsset ?? tab.asset) : tab.asset
        ZStack {
            if isSelected {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [VColors.primary.opacity(0.2), VColors.primary.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 32
                        )
                    )
                    .frame(width: 64, height: 40)
            }
            VStack(spacing: 0) {
                VIcon(
                    asset: asset,
                    symbol: isSelected ? tab.selectedSymbol : tab.symbol,
                    size: 24,
                    color: color
                )
                Text(tab.label)
                    .font(vFont(11, .bold))
                    .foregroundColor(color)
                    .lineLimit(1)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Search dock ("How can I help you?")

/// Empty -> mic, text -> send, whitespace only -> disabled send.
struct SearchDock: View {
    @Binding var text: String
    var onSend: () -> Void
    var onMic: () -> Void = {}
    @FocusState private var focused: Bool

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(VColors.textSecondary)
                .padding(.leading, 12)

            TextField(
                "",
                text: $text,
                prompt: Text("How can I help you?")
                    .foregroundColor(VColors.slate500.opacity(0.7))
            )
            .font(vFont(16, .medium))
            .foregroundColor(VColors.textPrimary)
            .submitLabel(.send)
            .focused($focused)
            .onSubmit { if canSend { onSend() } }

            if text.isEmpty {
                Button(action: onMic) {
                    Image(systemName: "mic")
                        .font(.system(size: 20))
                        .foregroundColor(VColors.textSecondary)
                        .frame(width: 44, height: 44)
                }
            } else {
                Button {
                    if canSend { onSend() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(canSend ? VColors.primary : Color(hex: 0xB8C2CF))
                        .frame(width: 44, height: 44)
                }
                .disabled(!canSend)
            }
        }
        .padding(.trailing, 2)
        .frame(height: 48)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .vFloatingShadow()
    }
}

/// Bottom search area with the soft fade behind it (A04, A05).
struct VittaDock: View {
    @EnvironmentObject var app: AppState
    @Environment(\.insets) private var insets
    @State private var text = ""

    var body: some View {
        SearchDock(
            text: $text,
            onSend: {
                text = ""
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
                app.showToast("Message sent (demo)")
            },
            onMic: { app.showProto("Dictation") }
        )
        .padding(.horizontal, 17.5)
        .padding(.top, 38)
        .padding(.bottom, insets.bottom + 16)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(hex: 0xF4F8FC, alpha: 0), location: 0),
                    .init(color: Color(hex: 0xF4F8FC, alpha: 0.9), location: 0.5),
                    .init(color: Color(hex: 0xF4F8FC, alpha: 0.97), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Top bar (A04, A05)

struct VittaTopBar: View {
    @EnvironmentObject var app: AppState
    var serifBrand: Bool = false
    var minimizeStatus: MiniStatus = .ready

    var body: some View {
        HStack(spacing: 0) {
            barButton(width: 40) {
                app.goHome()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(VColors.textPrimary)
            }

            VIcon(asset: "vitta", symbol: "sparkles", size: 18, color: VColors.primary)
            Text("Vitta")
                .font(serifBrand ? .system(size: 20, design: .serif) : vFont(20))
                .tracking(-0.18)
                .foregroundColor(VColors.primary)
                .padding(.leading, 6)

            Spacer(minLength: 0)

            barButton(width: 46) {
                app.showProto("Search")
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(VColors.textPrimary)
            }
            barButton(width: 46) {
                app.minimize(minimizeStatus)
            } label: {
                VIcon(asset: "minimize", symbol: "arrow.down.right.and.arrow.up.left",
                      size: 15, color: VColors.textPrimary)
            }
            barButton(width: 46) {
                app.closeFlow()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(VColors.textPrimary)
            }
        }
        .frame(height: 44)
    }

    private func barButton<L: View>(
        width: CGFloat,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> L
    ) -> some View {
        Button(action: action) {
            label().frame(width: width, height: 44).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Agent log (A04, A05)

struct AgentLogCard<Rows: View>: View {
    let title: String
    var boldTitle: Bool = false
    var showLoader: Bool = false
    @Binding var expanded: Bool
    private let rows: () -> Rows

    init(
        title: String,
        boldTitle: Bool = false,
        showLoader: Bool = false,
        expanded: Binding<Bool>,
        @ViewBuilder rows: @escaping () -> Rows
    ) {
        self.title = title
        self.boldTitle = boldTitle
        self.showLoader = showLoader
        self._expanded = expanded
        self.rows = rows
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    if showLoader { VittaLoader(size: 16) }
                    Text(title)
                        .font(vFont(14, boldTitle ? .bold : .regular))
                        .foregroundColor(VColors.textPrimary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(VColors.textPrimary)
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(VColors.border)
                        .frame(height: 0.7)
                    VStack(alignment: .leading, spacing: 12) {
                        rows()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
                .transition(.opacity)
            }
        }
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 0)
    }
}

/// One line of the agent log: spinner while running, green check when done.
struct LogRow: View {
    let text: String
    let done: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            ZStack {
                if done {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(VColors.success)
                } else {
                    SmallSpinner(size: 16)
                }
            }
            .frame(width: 16, height: 16)
            .padding(.top, 2)
            .padding(.leading, 1)

            Text(text)
                .font(vFont(14))
                .foregroundColor(VColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Toast

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(vFont(14))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: 0x0E1A2B, alpha: 0.92))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 24)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
