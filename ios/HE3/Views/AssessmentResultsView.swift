import SwiftUI

struct AssessmentResultsView: View {
    let scores: AssessmentScores
    let onContinue: () -> Void
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 32)

                Text("YOUR ALIGNMENT PROFILE")
                    .font(BrandFont.mono(11, weight: .medium))
                    .tracking(3)
                    .foregroundStyle(HE3Theme.crimson)

                ProfileReadout(scores: scores)

                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        Text("ENTER THE 30 DAY SPRINT")
                            .font(BrandFont.display(22))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.bone)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(HE3Theme.crimson)
                    }
                    .padding(.horizontal, 24)

                    Text("\u{201C}Built from what remained.\u{201D}")
                        .font(BrandFont.quote(15))
                        .foregroundStyle(HE3Theme.ashLight)
                }

                Spacer().frame(height: 40)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }
}
