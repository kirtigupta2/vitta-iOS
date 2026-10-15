import SwiftUI

/// A01: Home. Long-press any card to ask Vitta (A02 -> A03 -> A04 -> A05).
struct HomeView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.insets) private var insets

    // Figma shows the balance hidden by default.
    @State private var hidden = true
    @State private var showDetails = false

    private var balance: String { hidden ? "$ ••••••" : "$ 12,450.00" }

    var body: some View {
        ZStack(alignment: .top) {
            VColors.sheet

            // Blue header background
            headerBackground
                .frame(height: insets.top + 241)
                .frame(maxHeight: .infinity, alignment: .top)

            // Translucent panel behind the quick actions
            RoundedCorner(radius: 16, corners: [.topLeft, .topRight])
                .fill(Color(hex: 0x073373, alpha: 0.25))
                .shadow(color: Color(hex: 0x051F4D, alpha: 0.25), radius: 8, x: 0, y: 4)
                .frame(height: 82)
                .padding(.horizontal, 16)
                .padding(.top, insets.top + 119)

            header
                .padding(.horizontal, 16)
                .padding(.top, insets.top + 3)

            // White content sheet
            sheet
                .padding(.top, insets.top + 195)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) { bottomNav }
        .overlay(alignment: .bottomTrailing) { miniCard }
        .sheet(isPresented: $showDetails) { balanceDetails }
    }

    // MARK: Header

    private var headerBackground: some View {
        ZStack {
            Color(hex: 0x2F6FB0)
            RadialBlob(center: UnitPoint(x: 1, y: 0), radius: 0.9,
                       colors: [Color(hex: 0xFFC9A6, alpha: 0.5), Color(hex: 0xFFC9A6, alpha: 0)])
            RadialBlob(center: UnitPoint(x: 0.925, y: 0.65), radius: 0.7,
                       colors: [Color(hex: 0x6497CE, alpha: 0.75), Color(hex: 0x6497CE, alpha: 0)])
            RadialBlob(center: UnitPoint(x: 0, y: 0), radius: 0.9,
                       colors: [Color(hex: 0x1F5AA0, alpha: 0.7), Color(hex: 0x1F5AA0, alpha: 0)])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Avatar, greeting, bell
            HStack(spacing: 6) {
                ZStack {
                    VColors.blue100
                    AssetImage(name: "avatar", fallbackSymbol: "person.fill",
                               fallbackColor: VColors.blue100,
                               fallbackIconColor: VColors.primary,
                               alignment: .top)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                Text("Hello Alex,")
                    .font(vFont(24, .bold))
                    .tracking(-0.6)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    app.showProto("Notifications")
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: 0x073373, alpha: 0.25))
                            .shadow(color: Color(hex: 0x051F4D, alpha: 0.25), radius: 4, x: 0, y: 4)
                        VIcon(asset: "bell", symbol: "bell", size: 16, color: .white)
                    }
                    .frame(width: 32, height: 32)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(height: 40)

            Spacer().frame(height: 16)

            // Total balance
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Total Balance")
                        .font(vFont(14))
                        .foregroundColor(.white)
                        .frame(height: 17.5, alignment: .leading)
                    Text(balance)
                        .font(vFont(16, .bold))
                        .foregroundColor(.white)
                        .frame(height: 18, alignment: .leading)
                }
                Spacer()
                Button {
                    hidden.toggle()
                } label: {
                    Image(systemName: hidden ? "eye.slash" : "eye")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Button {
                    showDetails = true
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(height: 36)

            Spacer().frame(height: 34)

            // Quick actions
            HStack(spacing: 0) {
                QuickAction(label: "Transfer", asset: "qa_transfer", symbol: "arrow.left.arrow.right")
                QuickDivider()
                QuickAction(label: "Statement", asset: "qa_statement", symbol: "doc.text")
                QuickDivider()
                QuickAction(label: "Rewards", asset: "qa_rewards", symbol: "gift")
                QuickDivider()
                QuickAction(label: "Wallet", asset: "qa_wallet", symbol: "wallet.pass")
            }
            .frame(height: 54)
        }
    }

    // MARK: Content sheet

    private var sheet: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hint row
                HStack(spacing: 6) {
                    VIcon(asset: "vitta", symbol: "sparkles", size: 14, color: VColors.primary)
                    Text("Long press any card to ask Vitta about it")
                        .font(vFont(11, .bold))
                        .foregroundColor(VColors.primary)
                }
                .frame(height: 23)
                .padding(.horizontal, 15)

                Spacer().frame(height: 24)
                sectionTitle("Recommended for you").padding(.horizontal, 15)
                Spacer().frame(height: 12)
                offerList

                Spacer().frame(height: 16)
                sectionTitle("Grow Your Portfolio").padding(.horizontal, 15)
                Spacer().frame(height: 12)
                portfolioCard.padding(.horizontal, 15)

                Spacer().frame(height: 16)
                HStack {
                    sectionTitle("Upcoming Payments")
                    Spacer()
                    Button {
                        app.showProto("Upcoming payments")
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(VColors.textPrimary)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 22.5)
                .padding(.horizontal, 15)

                Spacer().frame(height: 12)
                paymentsCard.padding(.horizontal, 15)
            }
            .padding(.top, 16)
            .padding(.bottom, 110 + insets.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VColors.sheet)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(vFont(16, .bold))
            .foregroundColor(VColors.textPrimary)
    }

    private var offerList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                AskVitta {
                    OfferCard(
                        title: "Save on Dining with Credit Card",
                        subtitle: "10% Uber Eats Cashback",
                        imageName: "offer_dining",
                        imageSize: 64, imageLeft: 245, imageTop: 9
                    )
                }
                AskVitta {
                    OfferCard(
                        title: "Create Concert Budget",
                        subtitle: "Attended 6 concerts last month alone",
                        imageName: "offer_concert",
                        subtitleWeight: .medium,
                        imageSize: 78, imageLeft: 239, imageTop: 3
                    )
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)   // room for the card shadows
        }
        .padding(.vertical, -14)
        .frame(height: 63)
    }

    private var portfolioCard: some View {
        AskVitta {
            VStack(alignment: .leading, spacing: 16) {
                Text("Potential investments areas for you")
                    .font(vFont(14, .medium))
                    .foregroundColor(VColors.textPrimary)
                HStack(spacing: 0) {
                    StockItem(symbol: "LCID", change: "+28.79%", asset: "logo_lcid",
                              bg: Color(hex: 0x111111), logoSize: 36)
                    StockItem(symbol: "CHRN", change: "+28.71%", asset: "logo_chrn",
                              bg: Color(hex: 0xEEF2F7), logoSize: 36)
                    StockItem(symbol: "SAH", change: "+7.96%", asset: "logo_sah",
                              bg: Color(hex: 0xE23B2E), logoSize: 32)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .vCardShadow()
        }
    }

    private var paymentsCard: some View {
        AskVitta {
            VStack(spacing: 0) {
                PaymentRow(name: "Comcast", due: "Due on 10 July, 2026", amount: "$120") {
                    app.showProto("Payment details")
                }
                Rectangle()
                    .fill(Color(hex: 0x6D8FFF, alpha: 0.15))
                    .frame(height: 0.5)
                    .padding(.vertical, 12)
                PaymentRow(name: "Netflix Subscription", due: "Due on 23 July, 2026", amount: "$40") {
                    app.showProto("Payment details")
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .vCardShadow()
        }
    }

    // MARK: Floating nav + minimized card

    private var bottomNav: some View {
        ZStack(alignment: .bottom) {
            // Soft fade so content does not run into the nav bar
            LinearGradient(
                stops: [
                    .init(color: Color(hex: 0xF4F8FC, alpha: 0), location: 0),
                    .init(color: Color(hex: 0xF4F8FC, alpha: 0.9), location: 0.5),
                    .init(color: Color(hex: 0xF4F8FC, alpha: 0.97), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 110 + insets.bottom)
            .allowsHitTesting(false)

            VittaBottomNav(selected: 0) { i in
                if i != 0 { app.showProto(VittaTab.all[i].label) }
            }
            .padding(.horizontal, 17.5)
            .padding(.bottom, 16 + insets.bottom)
        }
    }

    private var miniCard: some View {
        Group {
            if let status = app.mini {
                MiniVitta(
                    status: status,
                    onOpen: { app.openMini() },
                    onDismiss: { withAnimation { app.mini = nil } }
                )
                .transition(.scale(scale: 0.85, anchor: .bottomTrailing).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.26), value: app.mini)
        .padding(.trailing, 16)
        .padding(.bottom, insets.bottom + 100)
    }

    // MARK: Balance details sheet

    private var balanceDetails: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Balance details")
                .font(vFont(18, .bold))
                .foregroundColor(VColors.textPrimary)
                .padding(.bottom, 12)
            detailLine("Checking", "$ 8,240.50")
            detailLine("Savings", "$ 4,210.00")
            Divider().padding(.vertical, 8)
            detailLine("Total", "$ 12,450.50")
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.ignoresSafeArea())
        .presentationDetents([.height(260)])
    }

    private func detailLine(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name).font(vFont(14)).foregroundColor(VColors.textSecondary)
            Spacer()
            Text(hidden ? "••••••" : value)
                .font(vFont(14, .bold))
                .foregroundColor(VColors.textPrimary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Pieces

private struct QuickAction: View {
    @EnvironmentObject var app: AppState
    let label: String
    let asset: String
    let symbol: String

    var body: some View {
        Button {
            app.showProto(label)
        } label: {
            // 40 pt icon box that overlaps the label by 4 pt, as in Figma.
            VStack(spacing: -4) {
                VIcon(asset: asset, symbol: symbol, size: 40, color: .white)
                Text(label)
                    .font(vFont(12))
                    .foregroundColor(.white)
                    .frame(height: 18)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct QuickDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0), Color.white.opacity(0.3), Color.white.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 1, height: 40)
    }
}

private struct StockItem: View {
    let symbol: String
    let change: String
    let asset: String
    let bg: Color
    let logoSize: CGFloat

    var body: some View {
        HStack(spacing: 6) {
            AssetImage(name: asset, fallbackSymbol: "chart.line.uptrend.xyaxis",
                       fallbackColor: bg, fallbackIconColor: .white.opacity(0.8))
                .frame(width: logoSize, height: logoSize)
                .clipShape(RoundedRectangle(cornerRadius: 6.4, style: .continuous))
            VStack(alignment: .leading, spacing: 0) {
                Text(symbol)
                    .font(vFont(14, .medium))
                    .foregroundColor(VColors.textSecondary)
                    .lineLimit(1)
                Text(change)
                    .font(vFont(12, .medium))
                    .foregroundColor(VColors.success)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PaymentRow: View {
    let name: String
    let due: String
    let amount: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(vFont(14, .medium))
                        .foregroundColor(VColors.textPrimary)
                    Text(due)
                        .font(vFont(12))
                        .foregroundColor(VColors.textSecondary)
                }
                Spacer()
                Text(amount)
                    .font(vFont(14, .bold))
                    .foregroundColor(VColors.textPrimary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(VColors.textPrimary)
                    .padding(.leading, 6)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// The minimized Vitta agent: a 155 x 135 card at the bottom right of Home.
private struct MiniVitta: View {
    let status: MiniStatus
    let onOpen: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                stops: [
                    .init(color: Color(hex: 0xE9F0F9), location: 0),
                    .init(color: Color(hex: 0xFBFCFE), location: 0.5),
                    .init(color: Color(hex: 0xFCE9DC), location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            // Whole card opens Vitta
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(perform: onOpen)

            HStack(spacing: 0) {
                VIcon(asset: "vitta", symbol: "sparkles", size: 16, color: VColors.primary)
                Text("Vitta")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(VColors.primary)
                    .padding(.leading, 5)
                Spacer()
                Button(action: onOpen) {
                    VIcon(asset: "maximize", symbol: "arrow.up.left.and.arrow.down.right",
                          size: 24, color: VColors.textPrimary)
                }
                .buttonStyle(.plain)
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(VColors.textPrimary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            VStack(alignment: .leading, spacing: 12) {
                Text("Save on Dining with Credit Card")
                    .font(vFont(14, .medium))
                    .foregroundColor(VColors.textPrimary)
                    .lineLimit(2)
                    .frame(height: 35, alignment: .leading)
                Group {
                    if status == .ready {
                        Text("Tap to view details")
                            .font(vFont(12))
                            .foregroundColor(VColors.textSecondary)
                    } else {
                        HStack(spacing: 6) {
                            SmallSpinner(size: 10)
                            Text("Building...")
                                .font(vFont(12))
                                .foregroundColor(VColors.textSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(8.667)
            .frame(width: 129.667, height: 85.167, alignment: .topLeading)
            .background(Color.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.667)
            )
            .allowsHitTesting(false)
            .offset(x: 12, y: 37)
        }
        .frame(width: 155, height: 135)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .vFloatingShadow()
    }
}
