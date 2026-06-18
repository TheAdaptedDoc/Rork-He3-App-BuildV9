import SwiftUI

struct AssessmentOnboardingFlow: View {
    var progress: UserProgressViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var step: OnboardingStep = .intro
    @State private var showExitConfirmation = false

    enum OnboardingStep {
        case intro
        case contactInfo
        case assessment
        case purchase
    }

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            switch step {
            case .intro:
                AssessmentIntroView(
                    onBegin: {
                        withAnimation(.easeOut(duration: 0.4)) {
                            if progress.hasContactInfo {
                                step = .assessment
                            } else {
                                step = .contactInfo
                            }
                        }
                    },
                    onClose: {
                        dismiss()
                    },
                    onSkipToPurchase: {
                        withAnimation(.easeOut(duration: 0.4)) {
                            step = .purchase
                        }
                    }
                )
            case .contactInfo:
                ContactInfoView(
                    progress: progress,
                    onComplete: {
                        withAnimation(.easeOut(duration: 0.4)) {
                            step = .assessment
                        }
                    },
                    onClose: {
                        showExitConfirmation = true
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            case .assessment:
                AssessmentView(
                    progress: progress,
                    onComplete: {
                        withAnimation(.easeOut(duration: 0.4)) {
                            step = .purchase
                        }
                    },
                    onExit: {
                        showExitConfirmation = true
                    }
                )
            case .purchase:
                UnlockPromptView(progress: progress, onClose: { dismiss() })
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .preferredColorScheme(.light)
        .confirmationDialog("Leave Assessment?", isPresented: $showExitConfirmation, titleVisibility: .visible) {
            Button("Return Home", role: .destructive) {
                dismiss()
            }
            Button("Skip to Program") {
                withAnimation(.easeOut(duration: 0.4)) {
                    step = .purchase
                }
            }
            Button("Continue Assessment", role: .cancel) {}
        } message: {
            Text("Your progress will not be saved if you leave now.")
        }
    }
}

struct AssessmentIntroView: View {
    var onBegin: () -> Void
    var onClose: () -> Void
    var onSkipToPurchase: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(HE3Theme.bone.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(HE3Theme.iron)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 16)

                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 44))
                        .foregroundStyle(HE3Theme.gold)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    VStack(spacing: 12) {
                        Text("HE\u{00B3} ALIGNMENT ASSESSMENT")
                            .font(BrandFont.mono(11, weight: .medium))
                            .tracking(3)
                            .foregroundStyle(HE3Theme.gold)

                        Text("DISCOVER YOUR\nVOICE DYNAMIC")
                            .font(BrandFont.display(30))
                            .foregroundStyle(HE3Theme.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: appeared)

                    VStack(alignment: .leading, spacing: 16) {
                        InstructionRow(number: "01", text: "34 statements about how you operate")

                        InstructionRow(number: "02", text: "Rate each from 1 (Strongly Disagree) to 5 (Strongly Agree)")

                        InstructionRow(number: "03", text: "Answer honestly, there are no right or wrong answers")
                    }
                    .padding(24)
                    .background(HE3Theme.iron)
                    .clipShape(.rect(cornerRadius: 0))
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.6).delay(0.25), value: appeared)

                    Text("When you finish, you'll immediately see which of your three inner voices is dominant, and which you've silenced.")
                        .font(BrandFont.body(15, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: appeared)

                    Spacer().frame(height: 8)
                }
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 12) {
                Button(action: onBegin) {
                    Text("BEGIN ASSESSMENT \u{2192}")
                        .font(BrandFont.mono(13, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(HE3Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(HE3Theme.gold)
                        .clipShape(.rect(cornerRadius: 0))
                }
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.55), value: appeared)

                Text("34 QUESTIONS \u{00B7} 7 MINUTES \u{00B7} CLEAR SIGNAL")
                    .font(BrandFont.mono(10))
                    .foregroundStyle(HE3Theme.ashLight)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: appeared)

                Button(action: onSkipToPurchase) {
                    Text("SKIP TO THE 30 DAY SPRINT \u{2192}")
                        .font(BrandFont.mono(11, weight: .medium))
                        .tracking(1)
                        .foregroundStyle(HE3Theme.gold)
                }
                .padding(.top, 4)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.65), value: appeared)
            }
            .padding(.top, 12)
            .padding(.bottom, 48)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
}

struct ScaleLabel: View {
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Text(value)
                .font(BrandFont.mono(14, weight: .medium))
                .foregroundStyle(HE3Theme.gold)
                .frame(width: 16)

            Text("= \(label)")
                .font(BrandFont.body(14, weight: .light))
                .foregroundStyle(HE3Theme.ash)
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Text(number)
                .font(BrandFont.mono(13, weight: .medium))
                .foregroundStyle(HE3Theme.gold)
                .frame(width: 28)

            Rectangle()
                .fill(HE3Theme.steel)
                .frame(width: 1, height: 20)

            Text(text)
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .lineSpacing(2)
        }
    }
}
