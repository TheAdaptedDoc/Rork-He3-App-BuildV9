import SwiftUI

struct CommitmentOathView: View {
    var progress: UserProgressViewModel
    var onCommit: (() -> Void)?
    @State private var showOath = false
    @State private var showButton = false

    private let oathLines = [
        "I enter this system by decision, not emotion.",
        "I acknowledge that I have 90 days.",
        "I accept that the work is designed to be completed in 30.",
        "I understand that access closes because discipline matters.",
        "I will not binge this system.\nI will build myself through it.",
        "I will not negotiate with discomfort.\nI will face it.",
        "I recognize the three voices within me — Ego, Self, and Innate.",
        "I commit to aligning them rather than letting one dominate the others.",
        "I accept that knowledge without action changes nothing.",
        "I commit to the practices.\nI commit to the reflection.\nI commit to execution.",
        "No one is coming to save me.\nI move now."
    ]

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {
                    Spacer().frame(height: 40)

                    VStack(spacing: 12) {
                        Text("HE\u{00B3}")
                            .font(BrandFont.display(52))
                            .foregroundStyle(HE3Theme.goldGradient)

                        Text("THE INTEGRATED MAN SYSTEM")
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(4)
                            .foregroundStyle(HE3Theme.ashLight)
                    }

                    VStack(spacing: 8) {
                        Text("BEFORE YOU BEGIN")
                            .font(BrandFont.display(26))
                            .foregroundStyle(HE3Theme.textPrimary)

                        Text("Read this oath out loud.\nNot silently. Out loud.")
                            .font(BrandFont.body(15, weight: .light))
                            .foregroundStyle(HE3Theme.ash)
                            .multilineTextAlignment(.center)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(Array(oathLines.enumerated()), id: \.offset) { index, line in
                            Text(line)
                                .font(BrandFont.body(16, weight: .medium))
                                .foregroundStyle(HE3Theme.textPrimary)
                                .opacity(showOath ? 1 : 0)
                                .offset(y: showOath ? 0 : 12)
                                .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.15), value: showOath)
                        }
                    }
                    .padding(.horizontal, 24)

                    if showButton {
                        Button {
                            progress.commitToOath()
                            onCommit?()
                        } label: {
                            Text("I COMMIT \u{2192}")
                                .font(BrandFont.mono(14, weight: .medium))
                                .tracking(3)
                                .foregroundStyle(HE3Theme.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(HE3Theme.gold)
                                .clipShape(.rect(cornerRadius: 0))
                        }
                        .sensoryFeedback(.impact(weight: .heavy), trigger: progress.hasCommitted)
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer().frame(height: 60)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            withAnimation {
                showOath = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(oathLines.count) * 0.15 + 0.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showButton = true
                }
            }
        }
    }
}
