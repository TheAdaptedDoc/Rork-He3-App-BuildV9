import SwiftUI

/// The Re Calibration. Lays the day 0 baseline next to the day 30 retake so the
/// man sees the proof: Voice Spread falls, Integration Index climbs, and the
/// buried voice climbs out of Suppressed. Same instrument, same engine.
struct RecalibrationView: View {
    var progress: UserProgressViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showRetake = false

    private var baseline: AssessmentScores? { progress.assessmentBaseline }
    private var current: AssessmentScores? { progress.assessmentScores }
    private var hasRetaken: Bool {
        guard let b = baseline, let c = current else { return false }
        return b != c
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Spacer().frame(height: 12)

                    Text("THE RE CALIBRATION")
                        .font(BrandFont.mono(11, weight: .medium))
                        .tracking(3)
                        .foregroundStyle(HE3Theme.crimson)

                    Text("MEASURE THE SHIFT")
                        .font(BrandFont.display(32))
                        .foregroundStyle(HE3Theme.textPrimary)

                    if let b = baseline, let c = current, hasRetaken {
                        compare(baseline: b, current: c)
                    } else if let b = baseline {
                        awaiting(baseline: b)
                    } else {
                        noBaseline
                    }

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 24)
            }
            .scrollIndicators(.hidden)
            .background(HE3Theme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(HE3Theme.ashLight)
                    }
                }
            }
        }
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $showRetake) {
            AssessmentView(progress: progress, onComplete: { showRetake = false }, onExit: { showRetake = false })
        }
    }

    // MARK: - States

    private func compare(baseline b: AssessmentScores, current c: AssessmentScores) -> some View {
        VStack(spacing: 18) {
            Text("Feeling is weather. The measurement is climate. Here is what actually moved.")
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)

            headlineRow(label: "INTEGRATION INDEX", day0: b.integration, day30: c.integration,
                        suffix: "/ 35", goodIsUp: true,
                        band0: b.integrationBand, band30: c.integrationBand)

            headlineRow(label: "VOICE SPREAD", day0: b.voiceSpread, day30: c.voiceSpread,
                        suffix: "", goodIsUp: false,
                        band0: "lower is better", band30: "lower is better")

            Rectangle().fill(HE3Theme.paperDark).frame(height: 1)

            Text("THE VOICES")
                .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                .foregroundStyle(HE3Theme.ashLight)
                .frame(maxWidth: .infinity, alignment: .leading)

            voiceRow(.ego, b.ego, c.ego, b, c)
            voiceRow(.selfVoice, b.selfVoice, c.selfVoice, b, c)
            voiceRow(.innate, b.innate, c.innate, b, c)

            floorNote(baseline: b, current: c)
            archetypeShift(b: b, c: c)
            retakeButton(label: "RETAKE AGAIN")
        }
    }

    private func awaiting(baseline b: AssessmentScores) -> some View {
        VStack(spacing: 18) {
            Text("Your day 0 baseline is locked. Thirty days in, take the same 34 questions again and watch the gap.")
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)

            VStack(spacing: 14) {
                Text("YOUR DAY 0 BASELINE")
                    .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                    .foregroundStyle(HE3Theme.ashLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
                staticRow("Integration Index", "\(b.integration) / 35", b.integrationBand)
                staticRow("Voice Spread", "\(b.voiceSpread)", "lower is better")
                staticRow("Ego", "\(b.ego) / 45", b.voiceBand(b.ego))
                staticRow("Self", "\(b.selfVoice) / 45", b.voiceBand(b.selfVoice))
                staticRow("Innate", "\(b.innate) / 45", b.voiceBand(b.innate))
            }
            .padding(20)
            .background(HE3Theme.surface)

            retakeButton(label: "RETAKE NOW")

            Text("Do not trust the feeling. The feeling lies in both directions. The number does not.")
                .font(BrandFont.quote(14))
                .foregroundStyle(HE3Theme.ashLight)
                .multilineTextAlignment(.center)
        }
    }

    private var noBaseline: some View {
        VStack(spacing: 16) {
            Text("You have not taken the assessment yet. Take it once to set your day 0 baseline, then again at day 30.")
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)
            retakeButton(label: "TAKE THE ASSESSMENT")
        }
    }

    // MARK: - Pieces

    private func headlineRow(label: String, day0: Int, day30: Int, suffix: String, goodIsUp: Bool, band0: String, band30: String) -> some View {
        let delta = day30 - day0
        let improved = goodIsUp ? delta > 0 : delta < 0
        let color = delta == 0 ? HE3Theme.ash : (improved ? HE3Theme.ember : HE3Theme.crimson)
        let verb = delta == 0 ? "holding" : (goodIsUp ? (delta > 0 ? "climbing" : "slipping") : (delta < 0 ? "falling" : "widening"))
        return VStack(alignment: .leading, spacing: 10) {
            Text(label).font(BrandFont.mono(10, weight: .medium)).tracking(2).foregroundStyle(HE3Theme.ashLight)
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                dayValue("DAY 0", "\(day0)\(suffix)")
                Image(systemName: "arrow.right").font(.caption).foregroundStyle(HE3Theme.ashLight)
                dayValue("DAY 30", "\(day30)\(suffix)", accent: color)
                Spacer()
                Text(verb.uppercased())
                    .font(BrandFont.mono(9, weight: .medium)).tracking(1.5)
                    .foregroundStyle(color)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .overlay(Rectangle().stroke(color, lineWidth: 1))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(HE3Theme.surface)
    }

    private func dayValue(_ tag: String, _ value: String, accent: Color = HE3Theme.textPrimary) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(tag).font(BrandFont.mono(8, weight: .medium)).tracking(1.5).foregroundStyle(HE3Theme.ashLight)
            Text(value).font(BrandFont.display(28)).foregroundStyle(accent)
        }
    }

    private func voiceRow(_ voice: Voice, _ d0: Int, _ d30: Int, _ b: AssessmentScores, _ c: AssessmentScores) -> some View {
        let color = HE3Theme.voiceColor(voice)
        let delta = d30 - d0
        return HStack(spacing: 12) {
            Text(voice.displayName.uppercased())
                .font(BrandFont.mono(10, weight: .medium)).tracking(1)
                .foregroundStyle(HE3Theme.textPrimary).frame(width: 64, alignment: .leading)
            Text("\(d0)").font(BrandFont.mono(13)).foregroundStyle(HE3Theme.ash)
            Image(systemName: "arrow.right").font(.caption2).foregroundStyle(HE3Theme.ashLight)
            Text("\(d30)").font(BrandFont.mono(13, weight: .medium)).foregroundStyle(color)
            Text(c.voiceBand(d30).uppercased())
                .font(BrandFont.mono(8, weight: .medium)).tracking(1).foregroundStyle(color)
            Spacer()
            Text(delta == 0 ? "" : (delta > 0 ? "+\(delta)" : "\(delta)"))
                .font(BrandFont.mono(11, weight: .medium)).foregroundStyle(HE3Theme.ashLight)
        }
        .padding(.vertical, 6)
    }

    private func floorNote(baseline b: AssessmentScores, current c: AssessmentScores) -> some View {
        let floor = b.suppressedVoice
        let was = b.score(for: floor)
        let now = c.score(for: floor)
        return Group {
            if now > was {
                HStack(spacing: 0) {
                    Rectangle().fill(HE3Theme.ember).frame(width: 3)
                    Text("Your buried voice, \(floor.displayName), climbed from \(was) to \(now). That is the pulse coming back.")
                        .font(BrandFont.body(14, weight: .regular))
                        .foregroundStyle(HE3Theme.textPrimary)
                        .padding(16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(HE3Theme.surface)
            }
        }
    }

    private func archetypeShift(b: AssessmentScores, c: AssessmentScores) -> some View {
        Group {
            if b.profile != c.profile {
                VStack(spacing: 6) {
                    Text("YOUR PATTERN MOVED")
                        .font(BrandFont.mono(9, weight: .medium)).tracking(2).foregroundStyle(HE3Theme.ashLight)
                    Text("\(b.profile.title)  \u{2192}  \(c.profile.title)")
                        .font(BrandFont.display(20)).foregroundStyle(HE3Theme.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(18)
                .background(HE3Theme.surface)
            }
        }
    }

    private func staticRow(_ label: String, _ value: String, _ band: String) -> some View {
        HStack {
            Text(label).font(BrandFont.body(14, weight: .regular)).foregroundStyle(HE3Theme.textPrimary)
            Spacer()
            Text(value).font(BrandFont.mono(12, weight: .medium)).foregroundStyle(HE3Theme.ash)
            Text(band.uppercased()).font(BrandFont.mono(8, weight: .medium)).tracking(1).foregroundStyle(HE3Theme.ashLight)
        }
    }

    private func retakeButton(label: String) -> some View {
        Button { showRetake = true } label: {
            Text(label)
                .font(BrandFont.mono(13, weight: .medium)).tracking(1.5)
                .foregroundStyle(HE3Theme.bone)
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(HE3Theme.crimson)
        }
        .padding(.top, 4)
    }
}
