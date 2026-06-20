import SwiftUI

/// The shared voice profile read. Used by the post assessment results screen and
/// by Reading Your Voice Profile, so both render the exact same archetype, metrics,
/// bands, and longform copy. No CTA here, the parent decides what follows.
struct ProfileReadout: View {
    let scores: AssessmentScores
    @State private var barsAnimated = false
    @State private var openSection: String?

    private var profile: AssessmentProfile { scores.profile }
    private var copy: ArchetypeCopy { profile.copy }

    var body: some View {
        VStack(spacing: 24) {
            profileCard
            metricsRow
            voiceBreakdown
            detailAccordion
            bridgeCard
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) { barsAnimated = true }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 0) {
            Rectangle().fill(profile.accent).frame(width: 4)
            VStack(alignment: .leading, spacing: 12) {
                Text("YOUR PRIMARY PATTERN")
                    .font(BrandFont.mono(10, weight: .medium)).tracking(2).foregroundStyle(profile.accent)
                Text(profile.title.uppercased())
                    .font(BrandFont.display(30)).foregroundStyle(HE3Theme.textPrimary)
                Text(copy.blurb)
                    .font(BrandFont.body(15, weight: .light)).foregroundStyle(HE3Theme.ash).lineSpacing(4)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.surface)
        .padding(.horizontal, 24)
    }

    private var metricsRow: some View {
        HStack(spacing: 12) {
            metricCard(value: "\(scores.integrationIndex)", suffix: "/ 35",
                       label: "INTEGRATION INDEX", sub: scores.integrationBand, accent: HE3Theme.crimson)
            metricCard(value: "\(scores.voiceSpread)", suffix: "",
                       label: "VOICE SPREAD", sub: "lower is more aligned", accent: HE3Theme.obsidian)
        }
        .padding(.horizontal, 24)
    }

    private func metricCard(value: String, suffix: String, label: String, sub: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value).font(BrandFont.display(40)).foregroundStyle(accent)
                Text(suffix).font(BrandFont.mono(11)).foregroundStyle(HE3Theme.ashLight)
            }
            Text(label).font(BrandFont.mono(9, weight: .medium)).tracking(1.5).foregroundStyle(HE3Theme.ashLight)
            Text(sub).font(BrandFont.body(12, weight: .light)).foregroundStyle(HE3Theme.ash)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(HE3Theme.surface)
    }

    private var voiceBreakdown: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("VOICE SCORES")
                    .font(BrandFont.mono(10, weight: .medium)).tracking(2).foregroundStyle(HE3Theme.ashLight)
                Spacer()
                Text("DOMINANT \(scores.dominantVoice.displayName.uppercased())  ·  FLOOR \(scores.suppressedVoice.displayName.uppercased())")
                    .font(BrandFont.mono(8, weight: .medium)).tracking(1).foregroundStyle(HE3Theme.ashLight)
            }
            scoreBar(voice: .ego, label: "EGO", color: HE3Theme.voiceColor(.ego), score: scores.ego, max: 45, band: scores.voiceBand(scores.ego))
            scoreBar(voice: .selfVoice, label: "SELF", color: HE3Theme.voiceColor(.selfVoice), score: scores.selfVoice, max: 45, band: scores.voiceBand(scores.selfVoice))
            scoreBar(voice: .innate, label: "INNATE", color: HE3Theme.voiceColor(.innate), score: scores.innate, max: 45, band: scores.voiceBand(scores.innate))
            Rectangle().fill(HE3Theme.paperDark).frame(height: 1)
            scoreBar(voice: nil, label: "INTEGRATION", color: HE3Theme.crimson, score: scores.integration, max: 35, band: scores.integrationBand)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.surface)
        .padding(.horizontal, 24)
    }

    private func scoreBar(voice: Voice?, label: String, color: Color, score: Int, max: Int, band: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let voice {
                    VoiceIcon(voice: voice, size: 16)
                }
                Text(label).font(BrandFont.mono(11, weight: .medium)).tracking(1).foregroundStyle(HE3Theme.textPrimary)
                Spacer()
                Text("\(score) / \(max)").font(BrandFont.mono(11, weight: .medium)).foregroundStyle(HE3Theme.ash)
                Text(band.uppercased()).font(BrandFont.mono(9, weight: .medium)).tracking(1)
                    .foregroundStyle(color)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .overlay(Rectangle().stroke(color, lineWidth: 1))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(HE3Theme.paperDark).frame(height: 4)
                    Rectangle().fill(color).frame(width: barsAnimated ? geo.size.width * (Double(score) / Double(max)) : 0, height: 4)
                }
            }
            .frame(height: 4)
        }
    }

    private var detailAccordion: some View {
        VStack(spacing: 2) {
            ForEach(copy.sections) { section in
                let isOpen = openSection == section.heading
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        withAnimation(.easeOut(duration: 0.25)) { openSection = isOpen ? nil : section.heading }
                    } label: {
                        HStack {
                            Text(section.heading.uppercased())
                                .font(BrandFont.mono(11, weight: .medium)).tracking(1.5).foregroundStyle(HE3Theme.textPrimary)
                            Spacer()
                            Image(systemName: isOpen ? "minus" : "plus").font(.caption.weight(.semibold)).foregroundStyle(profile.accent)
                        }
                        .padding(16)
                    }
                    if isOpen {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(section.paragraphs.enumerated()), id: \.offset) { _, p in
                                Text(p).font(BrandFont.body(14, weight: .light)).foregroundStyle(HE3Theme.ash).lineSpacing(4)
                            }
                            if !section.bullets.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(section.bullets, id: \.self) { b in
                                        HStack(alignment: .top, spacing: 8) {
                                            Rectangle().fill(profile.accent).frame(width: 6, height: 2).padding(.top, 8)
                                            Text(b).font(BrandFont.body(14, weight: .regular)).foregroundStyle(HE3Theme.textPrimary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16).padding(.bottom, 16)
                    }
                }
                .background(HE3Theme.surface)
            }
        }
        .padding(.horizontal, 24)
    }

    private var bridgeCard: some View {
        HStack(spacing: 0) {
            Rectangle().fill(profile.accent).frame(width: 3)
            VStack(alignment: .leading, spacing: 12) {
                Text("YOUR PATH FORWARD")
                    .font(BrandFont.mono(10, weight: .medium)).tracking(2).foregroundStyle(HE3Theme.ashLight)
                ForEach(copy.weeks, id: \.self) { w in
                    Text(w).font(BrandFont.body(15, weight: .regular)).foregroundStyle(HE3Theme.textPrimary)
                }
                Text(copy.cta).font(BrandFont.quote(16)).foregroundStyle(profile.accent).padding(.top, 4)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.surface)
        .padding(.horizontal, 24)
    }
}
