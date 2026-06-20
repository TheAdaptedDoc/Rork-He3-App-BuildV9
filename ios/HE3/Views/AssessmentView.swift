import SwiftUI

struct AssessmentView: View {
    var progress: UserProgressViewModel
    var onComplete: (() -> Void)?
    var onExit: (() -> Void)?
    @State private var currentIndex: Int = 0
    @State private var answers: [Int: Int] = [:]
    @State private var showResults = false
    @State private var appeared = false
    @State private var advancing = false
    @State private var shuffledQuestions: [AssessmentQuestion] = []

    private var currentQuestion: AssessmentQuestion { shuffledQuestions[currentIndex] }
    private var overallProgress: Double {
        guard !shuffledQuestions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(shuffledQuestions.count)
    }

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            if shuffledQuestions.isEmpty {
                Color.clear
            } else if showResults {
                AssessmentResultsView(
                    scores: computeScores(),
                    onContinue: {
                        progress.completeAssessment(scores: computeScores())
                        onComplete?()
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                questionView
            }
        }
        .animation(.easeOut(duration: 0.35), value: currentIndex)
        .animation(.easeOut(duration: 0.4), value: showResults)
        .onAppear {
            if shuffledQuestions.isEmpty {
                shuffledQuestions = AssessmentData.questions.shuffled()
            }
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var questionView: some View {
        VStack(spacing: 0) {
            // Header. No subscale label, the assessment is blind so the result
            // is not skewed by the man knowing which voice a statement scores.
            VStack(spacing: 14) {
                HStack(alignment: .top) {
                    Button { onExit?() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(HE3Theme.ashLight)
                            .frame(width: 32, height: 32)
                    }
                    Spacer()
                    VStack(spacing: 6) {
                        AnimatedLogoView(animate: false, compact: true)
                        Text("QUESTION \(String(format: "%02d", currentIndex + 1)) / \(shuffledQuestions.count)")
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(3)
                            .foregroundStyle(HE3Theme.ash)
                    }
                    Spacer()
                    Color.clear.frame(width: 32, height: 32)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(HE3Theme.paperDark).frame(height: 2)
                        Rectangle().fill(HE3Theme.crimson).frame(width: geo.size.width * overallProgress, height: 2)
                    }
                }
                .frame(height: 2)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            VStack(spacing: 48) {
                Text(currentQuestion.text)
                    .font(BrandFont.body(28, weight: .regular))
                    .foregroundStyle(HE3Theme.obsidian)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 28)
                    .id(currentIndex)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(x: 24)),
                        removal: .opacity.combined(with: .offset(x: -24))
                    ))
                likertScale
            }

            Spacer()

            // Selecting a number advances automatically, so there is no Continue
            // button. Only a quiet back arrow to change the previous answer.
            VStack(spacing: 18) {
                Text("34 questions · 3 minutes · clear signal")
                    .font(BrandFont.quote(13))
                    .foregroundStyle(HE3Theme.ashLight)

                if currentIndex > 0 {
                    Button { goBack() } label: {
                        Text("\u{2190} BACK")
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.ashLight)
                    }
                } else {
                    Color.clear.frame(height: 16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private var likertScale: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ForEach(AssessmentData.scaleLabels, id: \.0) { value, _ in
                    let isSelected = answers[currentQuestion.id] == value
                    Button { selectRating(value) } label: {
                        Text("\(value)")
                            .font(BrandFont.mono(15, weight: .medium))
                            .foregroundStyle(isSelected ? HE3Theme.bone : HE3Theme.ash)
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(isSelected ? HE3Theme.crimson : Color.clear))
                            .overlay(Circle().stroke(isSelected ? HE3Theme.crimson : HE3Theme.paperDark, lineWidth: 1.5))
                    }
                    .disabled(advancing)
                    .sensoryFeedback(.selection, trigger: answers[currentQuestion.id])
                }
            }
            HStack {
                Text("STRONGLY DISAGREE").font(BrandFont.mono(8, weight: .medium)).tracking(2).foregroundStyle(HE3Theme.ashLight)
                Spacer()
                Text("STRONGLY AGREE").font(BrandFont.mono(8, weight: .medium)).tracking(2).foregroundStyle(HE3Theme.ashLight)
            }
            .padding(.horizontal, 24)
        }
    }

    /// Tap a number, see it register for a beat, then move on automatically.
    private func selectRating(_ value: Int) {
        guard !advancing else { return }
        answers[currentQuestion.id] = value
        advancing = true
        Task {
            try? await Task.sleep(for: .milliseconds(260))
            if currentIndex < shuffledQuestions.count - 1 {
                withAnimation(.easeOut(duration: 0.2)) { appeared = false }
                try? await Task.sleep(for: .milliseconds(140))
                currentIndex += 1
                withAnimation(.easeOut(duration: 0.35)) { appeared = true }
                advancing = false
            } else {
                withAnimation { showResults = true }
            }
        }
    }

    private func goBack() {
        guard currentIndex > 0, !advancing else { return }
        withAnimation(.easeOut(duration: 0.2)) { appeared = false }
        Task {
            try? await Task.sleep(for: .milliseconds(150))
            currentIndex -= 1
            withAnimation(.easeOut(duration: 0.35)) { appeared = true }
        }
    }

    private func computeScores() -> AssessmentScores {
        var sub: [AssessmentSubscale: Int] = [.ego: 0, .selfVoice: 0, .innate: 0, .integration: 0]
        for q in AssessmentData.questions {
            let raw = answers[q.id] ?? 3
            let scored = q.reverse ? (6 - raw) : raw
            sub[q.sub, default: 0] += scored
        }
        return AssessmentScores(
            ego: sub[.ego] ?? 0,
            selfVoice: sub[.selfVoice] ?? 0,
            innate: sub[.innate] ?? 0,
            integration: sub[.integration] ?? 0
        )
    }
}
