import SwiftUI

struct ContentView: View {
    @State private var progress = UserProgressViewModel()
    @State private var journal = JournalViewModel()
    @State private var rituals = RitualVideoViewModel()
    @State private var selectedTab = 0
    @State private var showSplash: Bool = true
    @Environment(\.scenePhase) private var scenePhase

    private var auth = AuthManager.shared
    private var entitlement = EntitlementService.shared

    var body: some View {
        ZStack {
            Group {
                if !auth.isSignedIn && !progress.godMode {
                    // Signed out: marketing, the free assessment, and sign in.
                    HeroLandingView(progress: progress)
                } else if progress.godMode {
                    mainTabView(.fullProgram)
                } else {
                    // Signed in: gate on server entitlement, three states.
                    switch entitlement.state {
                    case .fullProgram:
                        if !progress.hasCommitted {
                            CommitmentOathView(progress: progress, onCommit: {})
                        } else {
                            mainTabView(.fullProgram)
                        }
                    case .dailyPracticeOnly:
                        // The Standard active, full program window closed.
                        mainTabView(.dailyPracticeOnly)
                    case .locked:
                        LockedProgramView(entitlement: entitlement)
                    }
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
                await auth.restore()
                await entitlement.refresh()
                syncWindow()
                if entitlement.hasProgramAccess {
                    await VideoService.shared.loadCatalog()
                }
            }
            Task {
                try? await Task.sleep(for: .seconds(3.2))
                withAnimation(.easeOut(duration: 0.6)) {
                    showSplash = false
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // The app refreshes when it returns to the foreground and unlocks
            // from the new entitlement, per the build spec.
            if phase == .active {
                Task {
                    await entitlement.refresh()
                    syncWindow()
                    if entitlement.hasProgramAccess && VideoService.shared.catalog.isEmpty {
                        await VideoService.shared.loadCatalog()
                    }
                }
            }
        }
    }

    /// Drive the dashboard countdown from the server window. access_end is the
    /// truth; the start is 90 days before it.
    private func syncWindow() {
        guard let end = entitlement.current.accessEnd else { return }
        let start = Calendar.current.date(byAdding: .day, value: -90, to: end)
        if progress.programStartDate == nil, let start {
            progress.programStartDate = start
        }
    }

    private func mainTabView(_ mode: AccessState) -> some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "square.grid.2x2.fill", value: 0) {
                DashboardView(progress: progress, journal: journal, rituals: rituals, accessState: mode)
            }

            Tab("Pillars", systemImage: "rectangle.stack.fill", value: 1) {
                PillarsListView(progress: progress, journal: journal, accessState: mode)
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
