import SwiftUI

struct PillarsListView: View {
    var progress: UserProgressViewModel
    var journal: JournalViewModel
    var accessState: AccessState = .fullProgram

    private var programOpen: Bool { accessState == .fullProgram }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 2) {
                    if !programOpen {
                        renewalBanner
                            .padding(.bottom, 14)
                    }
                    ForEach(PillarID.allCases) { pillar in
                        let unlocked = programOpen && progress.isPillarUnlocked(pillar)
                        let isCurrent = programOpen && pillar == progress.currentPillar

                        NavigationLink(value: pillar) {
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(isCurrent ? HE3Theme.pillarAccent(pillar) : HE3Theme.steel.opacity(0.3))
                                    .frame(width: 3)

                                HStack(spacing: 14) {
                                    Image(systemName: unlocked ? pillar.icon : "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(unlocked ? HE3Theme.pillarAccent(pillar) : HE3Theme.bone.opacity(0.3))
                                        .frame(width: 28, height: 28)
                                        .background(unlocked ? HE3Theme.pillarAccent(pillar).opacity(0.12) : HE3Theme.steel.opacity(0.3))
                                        .clipShape(.rect(cornerRadius: 0))

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Text("WEEK \(pillar.week)")
                                                .font(BrandFont.mono(9, weight: .medium))
                                                .tracking(1.5)
                                                .foregroundStyle(isCurrent ? HE3Theme.gold : HE3Theme.bone.opacity(0.5))

                                            if isCurrent {
                                                Text("CURRENT")
                                                    .font(BrandFont.mono(8, weight: .medium))
                                                    .tracking(1)
                                                    .foregroundStyle(HE3Theme.background)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(HE3Theme.gold)
                                                    .clipShape(.rect(cornerRadius: 0))
                                            }
                                        }

                                        Text(pillar.title.uppercased())
                                            .font(BrandFont.display(18))
                                            .foregroundStyle(unlocked ? HE3Theme.textPrimary : HE3Theme.bone.opacity(0.4))

                                        Text(pillar.purpose)
                                            .font(BrandFont.body(13, weight: .light))
                                            .foregroundStyle(HE3Theme.ash)
                                            .lineLimit(2)
                                    }

                                    Spacer()

                                    if unlocked {
                                        Image(systemName: "chevron.right")
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(HE3Theme.ashLight.opacity(0.5))
                                    }
                                }
                                .padding(16)
                            }
                            .background(HE3Theme.iron)
                            .clipShape(.rect(cornerRadius: 0))
                            .opacity(unlocked ? 1 : 0.6)
                        }
                        .disabled(!unlocked)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .background(HE3Theme.background)
            .navigationTitle("Pillars")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationDestination(for: PillarID.self) { pillar in
                PillarDetailView(pillar: pillar, progress: progress, journal: journal)
            }
        }
    }

    private var renewalBanner: some View {
        Button {
            CheckoutLauncher.openCheckout(uid: AuthManager.shared.userId)
        } label: {
            HStack(spacing: 0) {
                Rectangle().fill(HE3Theme.crimson).frame(width: 3)
                VStack(alignment: .leading, spacing: 6) {
                    Text("THE FULL PROGRAM IS LOCKED")
                        .font(BrandFont.mono(10, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(HE3Theme.crimson)
                    Text("Your 90 day window has closed. Daily practice stays open. Unlock the program to walk the pillars again.")
                        .font(BrandFont.body(13, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                    Text("UNLOCK THE PROGRAM \u{2192}")
                        .font(BrandFont.mono(11, weight: .medium))
                        .tracking(1.5)
                        .foregroundStyle(HE3Theme.textPrimary)
                        .padding(.top, 2)
                }
                .padding(16)
                Spacer()
            }
            .background(HE3Theme.surface)
        }
    }
}
