import SwiftUI

struct ContentView: View {
    @State private var progress = UserProgressViewModel()
    @State private var journal = JournalViewModel()
    @State private var rituals = RitualVideoViewModel()
    @State private var selectedTab = 0
    @State private var showSplash: Bool = true

    @State private var showPostPurchaseOath: Bool = false

    var body: some View {
        ZStack {
            Group {
                if progress.hasPurchased && !progress.hasCommitted {
                    CommitmentOathView(progress: progress, onCommit: {
                        withAnimation(.easeOut(duration: 0.4)) {
                            showPostPurchaseOath = false
                        }
                    })
                } else if progress.hasPurchased || progress.godMode {
                    mainTabView
                } else {
                    HeroLandingView(progress: progress)
                }
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            progress.load()
            journal.load()
            rituals.load()
            configureAppearance()
            Task {
                try? await Task.sleep(for: .seconds(3.2))
                withAnimation(.easeOut(duration: 0.6)) {
                    showSplash = false
                }
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "square.grid.2x2.fill", value: 0) {
                DashboardView(progress: progress, journal: journal, rituals: rituals)
            }

            Tab("Pillars", systemImage: "rectangle.stack.fill", value: 1) {
                PillarsListView(progress: progress, journal: journal)
            }

            Tab("Journal", systemImage: "book.fill", value: 2) {
                JournalView(journal: journal, progress: progress)
            }

            Tab("Rituals", systemImage: "video.fill", value: 3) {
                RitualsView(rituals: rituals)
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                SettingsView(progress: progress)
            }
        }
        .tint(HE3Theme.crimson)
    }

    private func configureAppearance() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(HE3Theme.background)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(HE3Theme.background)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(HE3Theme.obsidian)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(HE3Theme.obsidian), .font: UIFont(name: "BebasNeue-Regular", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold)]

        let tabItem = UITabBarItemAppearance()
        tabItem.normal.iconColor = UIColor(HE3Theme.ashLight)
        tabItem.normal.titleTextAttributes = [.foregroundColor: UIColor(HE3Theme.ashLight)]
        tabItem.selected.iconColor = UIColor(HE3Theme.crimson)
        tabItem.selected.titleTextAttributes = [.foregroundColor: UIColor(HE3Theme.crimson)]
        tabAppearance.stackedLayoutAppearance = tabItem
        tabAppearance.inlineLayoutAppearance = tabItem
        tabAppearance.compactInlineLayoutAppearance = tabItem
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
}
