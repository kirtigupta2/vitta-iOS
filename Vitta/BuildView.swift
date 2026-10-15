import SwiftUI

/// A04: Vitta is "building" a recommendation. Steps run one after another,
/// then the app moves on to the card intro (A05).
struct BuildView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.insets) private var insets

    private let running = [
        "Analyzing spending behavior",
        "Exploring credit card savings opportunities",
        "Evaluating eligibility signals",
        "Building personalized application journey",
        "Preparing recommendations and next steps"
    ]
    private let finished = [
        "Analyzed spending behavior",
        "Explored credit card savings opportunities",
        "Evaluated eligibility signals",
        "Built personalized application journey",
        "Prepared recommendations and next steps"
    ]

    @State private var current = 0
    @State private var expanded = true

    var body: some View {
        ZStack(alignment: .top) {
            VittaBackground()

            VittaTopBar(minimizeStatus: .building)
                .padding(.horizontal, 16)
                .padding(.top, insets.top + 12)

            AgentLogCard(
                title: "Building your personalized card recommendation",
                boldTitle: true,
                showLoader: true,
                expanded: $expanded
            ) {
                ForEach(0..<min(current + 1, running.count), id: \.self) { i in
                    LogRow(text: i < current ? finished[i] : running[i], done: i < current)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, insets.top + 68)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) { VittaDock() }
        .task {
            do {
                for _ in 0..<running.count {
                    try await Task.sleep(nanoseconds: 1_100_000_000)
                    withAnimation(.easeInOut(duration: 0.25)) { current += 1 }
                }
                try await Task.sleep(nanoseconds: 900_000_000)
                withAnimation(.easeInOut(duration: 0.35)) { app.screen = .intro }
            } catch {
                // Cancelled (user left the screen).
            }
        }
    }
}
