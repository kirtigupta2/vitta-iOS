import SwiftUI

private func money(_ v: Int) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.groupingSeparator = ","
    return "$" + (f.string(from: NSNumber(value: v)) ?? "\(v)")
}

/// A05: savings count-up, offer card, Key benefits / How it works tabs.
/// Get Started scrolls with the content; only the search box is fixed.
struct CardIntroView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.insets) private var insets
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let finished = [
        "Analyzed spending behavior",
        "Explored credit card savings opportunities",
        "Evaluated eligibility signals",
        "Built personalized application journey",
        "Prepared recommendations and next steps"
    ]

    @State private var tab = 0
    @State private var logOpen = false
    @State private var amount = 0

    var body: some View {
        ZStack(alignment: .top) {
            VittaBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    AgentLogCard(
                        title: "Agent Actions (\(finished.count))",
                        expanded: $logOpen
                    ) {
                        ForEach(finished, id: \.self) { s in
                            LogRow(text: s, done: true)
                        }
                    }

                    Spacer().frame(height: 16)
                    hero
                    Spacer().frame(height: 24)
                    offerBanner
                    Spacer().frame(height: 24)
                    segmented
                    Spacer().frame(height: 16)

                    VStack(spacing: 0) {
                        if tab == 0 { benefits } else { howItWorks }
                    }
                    .id(tab)
                    .transition(.opacity)

                    Spacer().frame(height: 34)
                    getStarted
                }
                .padding(.horizontal, 16)
                .padding(.top, insets.top + 62)
                .padding(.bottom, insets.bottom + 126)
            }

            // Soft fade under the top bar
            LinearGradient(
                stops: [
                    .init(color: Color(hex: 0xEAF1F9, alpha: 0.96), location: 0),
                    .init(color: Color(hex: 0xEAF1F9, alpha: 0.92), location: 0.82),
                    .init(color: Color(hex: 0xEAF1F9, alpha: 0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: insets.top + 70)
            .allowsHitTesting(false)

            VittaTopBar(serifBrand: true, minimizeStatus: .ready)
                .padding(.horizontal, 16)
                .padding(.top, insets.top + 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) { VittaDock() }
        .task { await runCountUp() }
    }

    // MARK: Count-up

    private func runCountUp() async {
        if reduceMotion {
            amount = 1200
            return
        }
        do {
            try await Task.sleep(nanoseconds: 450_000_000)
            let steps = 60
            for i in 1...steps {
                let t = Double(i) / Double(steps)
                let eased = 1 - pow(1 - t, 3)          // ease-out cubic
                amount = Int((1200 * eased).rounded())
                try await Task.sleep(nanoseconds: 30_000_000)   // 60 x 30ms = 1.8 s
            }
            amount = 1200
        } catch {
            amount = 1200
        }
    }

    private var hero: some View {
        VStack(spacing: 0) {
            Text("Your potential yearly savings")
                .font(vFont(14, .medium))
                .foregroundColor(VColors.textSecondary)
                .padding(.top, 8)
            Text(amount >= 1200 ? "$1,200+" : money(amount))
                .font(vFont(56, .bold))
                .tracking(-1.12)
                .foregroundColor(VColors.success)
                .frame(height: 64)
                .accessibilityLabel("$1,200 plus")
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Banner (grows with its text, min 104)

    private var offerBanner: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Save on Dining with Credit Card")
                    .font(vFont(16, .bold))
                    .foregroundColor(VColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("You spend 10% for your spendings on dinning, it is your biggest spending category.")
                    .font(vFont(14))
                    .foregroundColor(VColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 11)
            .padding(.trailing, 100)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity, alignment: .leading)

            AssetImage(name: "offer_dining", fallbackSymbol: "tag",
                       contentMode: .fit, alignment: .bottomTrailing)
                .frame(width: 92, height: 92)
                .clipShape(Circle())
                .padding(4)
        }
        .frame(minHeight: 104)
        .background(offerGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .vCardShadow()
    }

    // MARK: Tabs

    private var segmented: some View {
        GeometryReader { g in
            let half = g.size.width / 2
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(VColors.surfaceMuted)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color(hex: 0x084AA3, alpha: 0.16), radius: 4, x: 0, y: 2)
                    .frame(width: half - 2, height: 36)
                    .offset(x: tab == 0 ? 2 : half, y: 0)

                HStack(spacing: 0) {
                    segLabel("Key benefits", 0)
                    segLabel("How it works", 1)
                }
            }
            .animation(.easeOut(duration: 0.25), value: tab)
        }
        .frame(height: 40)
    }

    private func segLabel(_ text: String, _ i: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { tab = i }
        } label: {
            Text(text)
                .font(vFont(14, tab == i ? .bold : .medium))
                .foregroundColor(tab == i ? VColors.textPrimary : VColors.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var benefits: some View {
        VStack(spacing: 0) {
            BenefitRow(symbol: "banknote", title: "10% Cashback", subtitle: "On dining purchases")
            BenefitRow(symbol: "gift", title: "15% Discount", subtitle: "At select partners")
            BenefitRow(symbol: "creditcard", title: "No Annual Fee",
                       subtitle: "No yearly charge", divider: false)
        }
    }

    // The Figma file does not design this tab; replace the copy as needed.
    private var howItWorks: some View {
        VStack(spacing: 0) {
            BenefitRow(symbol: "link", title: "Link your spending",
                       subtitle: "Vitta reviews your recent transactions")
            BenefitRow(symbol: "sparkles", title: "Get matched",
                       subtitle: "We find the card that fits how you spend")
            BenefitRow(symbol: "checkmark.seal", title: "Apply in minutes",
                       subtitle: "Your application journey is prepared for you", divider: false)
        }
    }

    private var getStarted: some View {
        Button {
            app.showProto("The next step after Get Started")
        } label: {
            Text("Get Started")
                .font(vFont(16, .bold))
                .tracking(-0.32)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(VColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 2.5, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}

private struct BenefitRow: View {
    let symbol: String
    let title: String
    let subtitle: String
    var divider: Bool = true

    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill(Color(hex: 0xE3EBFA))
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: symbol)
                        .font(.system(size: 18))
                        .foregroundColor(VColors.primary)
                )
                .offset(x: 1, y: 15)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(vFont(16, .bold))
                    .foregroundColor(VColors.textPrimary)
                Text(subtitle)
                    .font(vFont(13))
                    .foregroundColor(VColors.textSecondary)
            }
            .offset(x: 60, y: 14)

            if divider {
                Rectangle()
                    .fill(VColors.border)
                    .frame(height: 1)
                    .padding(.leading, 60)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72, alignment: .topLeading)
    }
}
