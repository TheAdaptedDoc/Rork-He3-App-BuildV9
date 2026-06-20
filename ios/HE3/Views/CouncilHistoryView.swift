import SwiftUI

/// A man's past Council sittings, newest first, dated. Tap one to read it back.
struct CouncilHistoryView: View {
    var progress: UserProgressViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var sittings: [CouncilSitting] = []
    @State private var loading = true
    @State private var selected: CouncilSitting?

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                if loading {
                    ProgressView().tint(HE3Theme.crimson)
                } else if sittings.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            Text("\(sittings.count) SITTING\(sittings.count == 1 ? "" : "S")")
                                .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                                .foregroundStyle(HE3Theme.ashLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ForEach(sittings) { sitting in
                                Button { selected = sitting } label: { card(sitting) }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Your Council")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(HE3Theme.ashLight)
                    }
                }
            }
            .sheet(item: $selected) { sitting in
                SittingDetail(sitting: sitting)
            }
        }
        .preferredColorScheme(.light)
        .task { await load() }
    }

    private func card(_ s: CouncilSitting) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle().fill(HE3Theme.crimson).frame(width: 3)
            VStack(alignment: .leading, spacing: 6) {
                Text(s.dateLabel)
                    .font(BrandFont.mono(10, weight: .medium)).tracking(1)
                    .foregroundStyle(HE3Theme.ashLight)
                Text(s.situation)
                    .font(BrandFont.body(16, weight: .regular))
                    .foregroundStyle(HE3Theme.textPrimary)
                    .lineLimit(2)
                Text("READ THE COUNCIL \u{2192}")
                    .font(BrandFont.mono(9, weight: .medium)).tracking(1.5)
                    .foregroundStyle(HE3Theme.crimson)
            }
            .padding(14)
            Spacer(minLength: 0)
        }
        .background(HE3Theme.surface)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            SeriesMarks(height: 18, width: 4, spacing: 5)
            Text("NO SITTINGS YET")
                .font(BrandFont.display(22)).foregroundStyle(HE3Theme.textPrimary)
            Text("When you bring a decision to The Council, every sitting is saved here so you can return to it.")
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
    }

    private func load() async {
        loading = true
        if progress.godMode {
            try? await Task.sleep(for: .milliseconds(500))
            sittings = Self.sampleSittings
            loading = false
            return
        }
        sittings = await ReflectionService.history()
        loading = false
    }

    static let sampleSittings: [CouncilSitting] = [
        CouncilSitting(
            id: UUID(), pillar: "Integration",
            situation: "I have an offer to leave my job and go all in on the business. It is the safe paycheck against the thing I actually want.",
            ego: CouncilView.sample.ego, selfVoice: CouncilView.sample.selfVoice,
            innate: CouncilView.sample.innate, synthesis: CouncilView.sample.synthesis,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 2))
        ),
        CouncilSitting(
            id: UUID(), pillar: "Awakening",
            situation: "My father reached out after two years. Part of me wants to answer, part of me wants to let it ring.",
            ego: "Answering is not weakness, it is you deciding the terms instead of him. Pick up, say your piece, and keep the door on your hinge, not his. Silence just hands him the power again.",
            selfVoice: "Be honest about what you actually want from the call before you make it. If it is an apology, say so. If it is closure, you can give yourself that without him.",
            innate: "Your chest tightened when you read his name. That is not fear, that is the old boy in you still hoping. He is allowed to hope. Let him.",
            synthesis: "Call him, but call him for you, not to fix him. Decide your one sentence before he answers, and you walk away clean no matter how he responds.",
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 6))
        )
    ]
}

private struct SittingDetail: View {
    let sitting: CouncilSitting
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(sitting.dateLabel.uppercased())
                        .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                        .foregroundStyle(HE3Theme.ashLight)
                    Text(sitting.situation)
                        .font(BrandFont.body(18, weight: .regular))
                        .foregroundStyle(HE3Theme.textPrimary)
                        .lineSpacing(4)
                    Rectangle().fill(HE3Theme.paperDark).frame(height: 1)

                    voiceCard(.ego, sitting.ego)
                    voiceCard(.selfVoice, sitting.selfVoice)
                    voiceCard(.innate, sitting.innate)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            SeriesMarks(height: 14, width: 3, spacing: 4)
                            Text("THE INTEGRATED READ")
                                .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                                .foregroundStyle(HE3Theme.textPrimary)
                        }
                        Text(sitting.synthesis)
                            .font(BrandFont.body(17, weight: .regular))
                            .foregroundStyle(HE3Theme.textPrimary)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .overlay(Rectangle().stroke(HE3Theme.obsidian, lineWidth: 1.5))
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .background(HE3Theme.background)
            .navigationTitle("Sitting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private func voiceCard(_ voice: Voice, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle().fill(HE3Theme.voiceColor(voice)).frame(width: 3)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    VoiceIcon(voice: voice, size: 18)
                    Text("THE \(voice.displayName.uppercased())")
                        .font(BrandFont.display(18)).foregroundStyle(HE3Theme.textPrimary)
                }
                Text(text)
                    .font(BrandFont.body(16, weight: .regular))
                    .foregroundStyle(HE3Theme.ash).lineSpacing(4)
            }
            .padding(16)
            Spacer(minLength: 0)
        }
        .background(HE3Theme.surface)
    }
}
