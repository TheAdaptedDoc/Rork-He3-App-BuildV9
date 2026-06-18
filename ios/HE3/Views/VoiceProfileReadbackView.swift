import SwiftUI

/// Reading Your Voice Profile. Plays the Day 0 connective lesson and reads back
/// the man's stored day 0 baseline result underneath it, so David's explanation
/// lines up with his actual numbers. Always reads the day 0 baseline, even after
/// a day 30 retake. The compare lives in the Re Calibration.
struct VoiceProfileReadbackView: View {
    var progress: UserProgressViewModel
    @Environment(\.dismiss) private var dismiss

    private var baseline: AssessmentScores? { progress.assessmentBaseline }
    private var hasRetaken: Bool {
        guard let b = baseline, let c = progress.assessmentScores else { return false }
        return b != c
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Spacer().frame(height: 12)

                    Text("DAY 0 · ORIENTATION")
                        .font(BrandFont.mono(10, weight: .medium))
                        .tracking(3)
                        .foregroundStyle(HE3Theme.crimson)

                    Text("READING YOUR VOICE PROFILE")
                        .font(BrandFont.display(30))
                        .foregroundStyle(HE3Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // The connective lesson, gated by the same entitlement.
                    LessonPlayerView(
                        slug: "c_reading_profile",
                        fallbackTitle: "Reading Your Voice Profile",
                        fallbackDuration: "7 MIN"
                    )
                    .padding(.horizontal, 24)

                    if let baseline {
                        Text("Here is the profile you scored on day 0. Watch the lesson, then read your own numbers back against it.")
                            .font(BrandFont.body(15, weight: .light))
                            .foregroundStyle(HE3Theme.ash)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)

                        ProfileReadout(scores: baseline)

                        if hasRetaken {
                            recalibrationHint
                        }
                    } else {
                        noBaseline
                    }

                    Spacer().frame(height: 36)
                }
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
    }

    private var recalibrationHint: some View {
        HStack(spacing: 0) {
            Rectangle().fill(HE3Theme.ember).frame(width: 3)
            Text("You have retaken the assessment since day 0. Open the Re Calibration to see day 0 next to day 30.")
                .font(BrandFont.body(13, weight: .regular))
                .foregroundStyle(HE3Theme.textPrimary)
                .padding(16)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.surface)
        .padding(.horizontal, 24)
    }

    private var noBaseline: some View {
        VStack(spacing: 8) {
            Text("No day 0 result yet")
                .font(BrandFont.display(20))
                .foregroundStyle(HE3Theme.textPrimary)
            Text("Take the assessment once to set your day 0 baseline. This lesson will then read it back to you.")
                .font(BrandFont.body(14, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(.vertical, 12)
    }
}
