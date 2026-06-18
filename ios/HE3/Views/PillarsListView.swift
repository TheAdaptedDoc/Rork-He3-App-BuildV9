import SwiftUI

struct PillarsListView: View {
    var progress: UserProgressViewModel
    var journal: JournalViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(PillarID.allCases) { pillar in
                        let unlocked = progress.isPillarUnlocked(pillar)
                        let isCurrent = pillar == progress.currentPillar

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
}
