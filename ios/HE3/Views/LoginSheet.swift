import SwiftUI

struct LoginSheet: View {
    var progress: UserProgressViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    VStack(spacing: 16) {
                        AnimatedLogoView(animate: false, compact: true)

                        Text("WELCOME BACK")
                            .font(BrandFont.display(30))
                            .foregroundStyle(HE3Theme.textPrimary)

                        Text("Sign in to continue your journey.")
                            .font(BrandFont.body(16, weight: .light))
                            .foregroundStyle(HE3Theme.ash)
                    }

                    Button {
                        progress.completePurchase()
                        dismiss()
                    } label: {
                        Text("RETURN TO YOUR JOURNEY \u{2192}")
                            .font(BrandFont.mono(13, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(HE3Theme.gold)
                            .clipShape(.rect(cornerRadius: 0))
                    }
                    .padding(.horizontal, 32)
                    .sensoryFeedback(.impact(weight: .medium), trigger: progress.hasPurchased)

                    if let profile = progress.assessmentProfile {
                        VStack(spacing: 4) {
                            Text(profile.title.uppercased())
                                .font(BrandFont.mono(11, weight: .medium))
                                .tracking(1)
                                .foregroundStyle(HE3Theme.gold)

                            Text("DAY \(progress.daysElapsed) OF 90 \u{00B7} \(progress.daysRemaining) DAYS REMAINING")
                                .font(BrandFont.mono(10))
                                .foregroundStyle(HE3Theme.ashLight)
                        }
                    } else {
                        Text("Sign in to access your program.")
                            .font(BrandFont.body(14, weight: .light))
                            .foregroundStyle(HE3Theme.ashLight)
                    }

                    Spacer()
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(HE3Theme.ashLight)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(HE3Theme.background)
        .preferredColorScheme(.light)
    }
}
