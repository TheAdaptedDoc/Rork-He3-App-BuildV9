import SwiftUI

struct AssessmentView: View {
    var progress: UserProgressViewModel
    var onComplete: (() -> Void)?
    var onExit: (() -> Void)?
    @State private var currentIndex: Int = 0
    @State private var answers: [Int: Int] = [:]
    @State private var showResults = false
    @State private var appeared = false
    @State private var shuffledQuestions: [AssessmentQuestion] = []

    private var currentQuestion: AssessmentQuestion {
        shuffledQuestions[currentIndex]
    }

    private var overallProgress: Double {
        Double(answers.count) / Double(shuffledQuestions.count)
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
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }

    private var sectionLabel: String {
        switch currentQuestion.section {
        case .egoDominance: return "EGO"
        case .selfFragmentation: return "SELF"
        case .innateSuppression: return "INNATE"
        }
    }

    private var questionView: some View {
        VStack(spacing: 0) {
            // Brand header: HE3 · QUESTION 09 / 27
            VStack(spacing: 14) {
                HStack(alignment: .top) {
                    Button {
                        onExit?()
                    } label: {
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
                        Text("\(sectionLabel) · SECTION \(String(format: "%02d", currentQuestion.id % 9 + 1))")
                            .font(BrandFont.mono(9, weight: .medium))
                            .tracking(3)
                            .foregroundStyle(HE3Theme.crimson)
                    }

                    Spacer()

                    Color.clear.frame(width: 32, height: 32)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(HE3Theme.paperDark)
                            .frame(height: 2)

                        Rectangle()
                            .fill(HE3Theme.crimson)
                            .frame(width: geo.size.width * overallProgress, height: 2)
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

            VStack(spacing: 18) {
                Button {
                    continueAction()
                } label: {
                    Text(currentIndex < shuffledQuestions.count - 1 ? "CONTINUE" : "SEE RESULT")
                        .font(BrandFont.display(20))
                        .tracking(2)
                        .foregroundStyle(HE3Theme.bone)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(answers[currentQuestion.id] != nil ? HE3Theme.obsidian : HE3Theme.paperDark)
                }
                .disabled(answers[currentQuestion.id] == nil)

                Text("27 questions · 5 minutes · clear signal")
                    .font(BrandFont.quote(13))
                    .foregroundStyle(HE3Theme.ashLight)

                if currentIndex > 0 {
                    Button {
                        goBack()
                    } label: {
                        Text("← BACK")
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.ashLight)
                    }
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
                    Button {
                        selectRating(value)
                    } label: {
                        Text("\(value)")
                            .font(BrandFont.mono(15, weight: .medium))
                            .foregroundStyle(isSelected ? HE3Theme.bone : HE3Theme.ash)
                            .frame(width: 46, height: 46)
                            .background(
                                Circle().fill(isSelected ? HE3Theme.crimson : Color.clear)
                            )
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? HE3Theme.crimson : HE3Theme.paperDark, lineWidth: 1.5)
                            )
                    }
                    .sensoryFeedback(.selection, trigger: answers[currentQuestion.id])
                }
            }

            HStack {
                Text("STRONGLY DISAGREE")
                    .font(BrandFont.mono(8, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.ashLight)

                Spacer()

                Text("STRONGLY AGREE")
                    .font(BrandFont.mono(8, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.ashLight)
            }
            .padding(.horizontal, 24)
        }
    }

    private func selectRating(_ value: Int) {
        answers[currentQuestion.id] = value
    }

    private func continueAction() {
        guard answers[currentQuestion.id] != nil else { return }
        Task {
            if currentIndex < shuffledQuestions.count - 1 {
                withAnimation(.easeOut(duration: 0.2)) {
                    appeared = false
                }
                try? await Task.sleep(for: .milliseconds(150))
                currentIndex += 1
                withAnimation(.easeOut(duration: 0.35)) {
                    appeared = true
                }
            } else {
                withAnimation {
                    showResults = true
                }
            }
        }
    }

    private func goBack() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            appeared = false
        }
        Task {
            try? await Task.sleep(for: .milliseconds(150))
            currentIndex -= 1
            withAnimation(.easeOut(duration: 0.35)) {
                appeared = true
            }
        }
    }

    private func computeScores() -> AssessmentScores {
        var ego = 0
        var selfScore = 0
        var innate = 0
        for q in AssessmentData.questions {
            let val = answers[q.id] ?? 3
            switch q.section {
            case .egoDominance: ego += val
            case .selfFragmentation: selfScore += val
            case .innateSuppression: innate += val
            }
        }
        return AssessmentScores(ego: ego, selfVoice: selfScore, innate: innate)
    }
}

struct AssessmentResultsView: View {
    let scores: AssessmentScores
    let onContinue: () -> Void
    @State private var appeared = false
    @State private var barsAnimated = false

    private var profile: AssessmentProfile { scores.profile }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer().frame(height: 32)

                Text("YOUR ALIGNMENT PROFILE")
                    .font(BrandFont.mono(11, weight: .medium))
                    .tracking(3)
                    .foregroundStyle(HE3Theme.gold)

                profileCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                voiceBreakdown
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)

                integrationCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.35), value: appeared)

                pillarFocusCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)

                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        Text("ENTER THE 30-DAY SPRINT")
                            .font(BrandFont.display(22))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.bone)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(HE3Theme.crimson)
                    }
                    .padding(.horizontal, 24)

                    Text("“Built from what remained.”")
                        .font(BrandFont.quote(15))
                        .foregroundStyle(HE3Theme.ashLight)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.65), value: appeared)

                Spacer().frame(height: 40)
            }
        }
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                barsAnimated = true
            }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(HE3Theme.gold)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 16) {
                Text("YOUR PRIMARY PATTERN")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.gold)

                Text(profile.title.uppercased())
                    .font(BrandFont.display(28))
                    .foregroundStyle(HE3Theme.textPrimary)

                Text(profile.description)
                    .font(BrandFont.body(15, weight: .light))
                    .foregroundStyle(HE3Theme.ash)
                    .lineSpacing(4)
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
        .padding(.horizontal, 24)
    }

    private var voiceBreakdown: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("VOICE SCORES")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.ashLight)

            VoiceScoreBar(
                voice: .ego,
                score: scores.ego,
                band: scores.band(for: scores.ego),
                isDominant: scores.dominantVoice == .ego,
                animated: barsAnimated
            )

            VoiceScoreBar(
                voice: .selfVoice,
                score: scores.selfVoice,
                band: scores.band(for: scores.selfVoice),
                isDominant: scores.dominantVoice == .selfVoice,
                animated: barsAnimated
            )

            VoiceScoreBar(
                voice: .innate,
                score: scores.innate,
                band: scores.band(for: scores.innate),
                isDominant: scores.dominantVoice == .innate,
                animated: barsAnimated
            )
        }
        .padding(24)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
        .padding(.horizontal, 24)
    }

    private var integrationCard: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("\(scores.integrationIndex)")
                    .font(BrandFont.display(40))
                    .foregroundStyle(HE3Theme.gold)

                Text("INTEGRATION\nINDEX")
                    .font(BrandFont.mono(8, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(HE3Theme.ashLight)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100)

            VStack(alignment: .leading, spacing: 8) {
                Text("Variance between your highest and lowest voice scores.")
                    .font(BrandFont.body(13, weight: .light))
                    .foregroundStyle(HE3Theme.ash)

                Text(integrationMessage)
                    .font(BrandFont.body(13, weight: .medium))
                    .foregroundStyle(HE3Theme.gold)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
        .padding(.horizontal, 24)
    }

    private var integrationMessage: String {
        let index = scores.integrationIndex
        if index <= 6 { return "Relatively balanced — integration is within reach." }
        if index <= 12 { return "Moderate imbalance — focused work will realign you." }
        return "Significant imbalance — the full system is essential."
    }

    private var pillarFocusCard: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(HE3Theme.goldDeep)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 12) {
                Text("YOUR PATH FORWARD")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.ashLight)

                Text(profile.pillarFocus)
                    .font(BrandFont.body(16, weight: .semiBold))
                    .foregroundStyle(HE3Theme.textPrimary)

                Text(profile.bridge)
                    .font(BrandFont.body(15, weight: .light))
                    .foregroundStyle(HE3Theme.gold)
                    .italic()
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
        .padding(.horizontal, 24)
    }
}

struct VoiceScoreBar: View {
    let voice: Voice
    let score: Int
    let band: String
    let isDominant: Bool
    let animated: Bool

    private var fillFraction: Double {
        Double(score) / 45.0
    }

    private var barColor: Color {
        HE3Theme.voiceColor(voice)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                VoiceIcon(voice: voice, size: 18)

                Text(voice.displayName.uppercased())
                    .font(BrandFont.mono(11, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(isDominant ? barColor : HE3Theme.ashLight)

                Spacer()

                Text("\(Int(fillFraction * 100))%")
                    .font(BrandFont.mono(12, weight: .medium))
                    .foregroundStyle(isDominant ? barColor : HE3Theme.bone.opacity(0.5))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(HE3Theme.steel)
                        .frame(height: 4)

                    Rectangle()
                        .fill(barColor)
                        .frame(width: animated ? geo.size.width * fillFraction : 0, height: 4)
                }
            }
            .frame(height: 4)

            Text(band)
                .font(BrandFont.mono(9, weight: .medium))
                .tracking(1)
                .foregroundStyle(isDominant ? barColor : HE3Theme.bone.opacity(0.4))
        }
    }
}
