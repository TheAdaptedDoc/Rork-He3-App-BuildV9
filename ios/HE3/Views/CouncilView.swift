import SwiftUI

/// The Council. A man brings a decision or a knot, and his three voices weigh in,
/// then give one integrated read. Powered by the ai-reflection edge function.
/// In owner preview it shows a sample sitting so the feature can be reviewed
/// without the backend.
struct CouncilView: View {
    var progress: UserProgressViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var situation = ""
    @State private var phase: Phase = .idle
    @State private var reflection: CouncilReflection?
    @State private var showHistory = false
    @FocusState private var editorFocused: Bool

    enum Phase: Equatable { case idle, loading, done, locked, failed }

    private var scores: AssessmentScores? {
        progress.assessmentScores ?? progress.assessmentBaseline
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Spacer().frame(height: 8)

                    Text("PILLAR THREE \u{00B7} KEYSTONE")
                        .font(BrandFont.mono(10, weight: .medium)).tracking(3)
                        .foregroundStyle(HE3Theme.crimson)
                    Text("THE COUNCIL")
                        .font(BrandFont.display(36))
                        .foregroundStyle(HE3Theme.textPrimary)
                    Text("Bring a decision or a knot you are sitting in. Your three voices will weigh in, then give you one read.")
                        .font(BrandFont.body(16, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                    if scores == nil {
                        needsAssessment
                    } else {
                        composer
                        switch phase {
                        case .idle: EmptyView()
                        case .loading: convening
                        case .done: if let reflection { resultView(reflection) }
                        case .locked: lockedView
                        case .failed: failedView
                        }
                    }

                    Spacer().frame(height: 40)
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
                ToolbarItem(placement: .primaryAction) {
                    Button { showHistory = true } label: {
                        Image(systemName: "clock.arrow.circlepath").foregroundStyle(HE3Theme.crimson)
                    }
                }
            }
            .sheet(isPresented: $showHistory) {
                CouncilHistoryView(progress: progress)
            }
        }
        .preferredColorScheme(.light)
    }

    private var composer: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .topLeading) {
                if situation.isEmpty {
                    Text("The decision in front of you, in your words.")
                        .font(BrandFont.body(16, weight: .light))
                        .foregroundStyle(HE3Theme.ashLight)
                        .padding(.horizontal, 14).padding(.vertical, 14)
                }
                TextEditor(text: $situation)
                    .focused($editorFocused)
                    .font(BrandFont.body(16, weight: .regular))
                    .foregroundStyle(HE3Theme.obsidian)
                    .scrollContentBackground(.hidden)
                    .frame(height: 130)
                    .padding(6)
            }
            .background(HE3Theme.surface)
            .overlay(Rectangle().stroke(HE3Theme.paperDark, lineWidth: 1))

            Button {
                convene()
            } label: {
                Text(phase == .loading ? "CONVENING..." : "CONVENE THE COUNCIL")
                    .font(BrandFont.display(20)).tracking(2)
                    .foregroundStyle(HE3Theme.bone)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(situation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || phase == .loading ? HE3Theme.paperDark : HE3Theme.crimson)
            }
            .disabled(situation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || phase == .loading)
        }
    }

    private var convening: some View {
        VStack(spacing: 12) {
            ProgressView().tint(HE3Theme.crimson)
            Text("THE THREE ARE WEIGHING IN")
                .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                .foregroundStyle(HE3Theme.ashLight)
        }
        .padding(.vertical, 20)
    }

    private func resultView(_ r: CouncilReflection) -> some View {
        VStack(spacing: 12) {
            voiceCard(.ego, r.ego)
            voiceCard(.selfVoice, r.selfVoice)
            voiceCard(.innate, r.innate)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    SeriesMarks(height: 14, width: 3, spacing: 4)
                    Text("THE INTEGRATED READ")
                        .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                        .foregroundStyle(HE3Theme.textPrimary)
                }
                Text(r.synthesis)
                    .font(BrandFont.body(17, weight: .regular))
                    .foregroundStyle(HE3Theme.textPrimary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(HE3Theme.obsidian.opacity(0.04))
            .overlay(Rectangle().stroke(HE3Theme.obsidian, lineWidth: 1.5))

            Button {
                withAnimation { phase = .idle; reflection = nil; situation = "" }
            } label: {
                Text("BRING ANOTHER")
                    .font(BrandFont.mono(11, weight: .medium)).tracking(1.5)
                    .foregroundStyle(HE3Theme.ashLight)
            }
            .padding(.top, 4)
        }
    }

    private func voiceCard(_ voice: Voice, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle().fill(HE3Theme.voiceColor(voice)).frame(width: 3)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    VoiceIcon(voice: voice, size: 18)
                    Text("THE \(voice.displayName.uppercased())")
                        .font(BrandFont.display(18))
                        .foregroundStyle(HE3Theme.textPrimary)
                }
                Text(text)
                    .font(BrandFont.body(16, weight: .regular))
                    .foregroundStyle(HE3Theme.ash)
                    .lineSpacing(4)
            }
            .padding(16)
            Spacer(minLength: 0)
        }
        .background(HE3Theme.surface)
    }

    private var needsAssessment: some View {
        VStack(spacing: 8) {
            Text("Take your Voice Dynamic first")
                .font(BrandFont.display(20)).foregroundStyle(HE3Theme.textPrimary)
            Text("The Council reads from your profile. Once you have your three voices measured, bring it a decision.")
                .font(BrandFont.body(14, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center).padding(.horizontal, 28)
        }
        .padding(.vertical, 16)
    }

    private var lockedView: some View {
        Text("The Council opens with the full program.")
            .font(BrandFont.body(15, weight: .light)).foregroundStyle(HE3Theme.ash)
            .padding(.vertical, 16)
    }

    private var failedView: some View {
        VStack(spacing: 10) {
            Text("The Council could not convene. Try again in a moment.")
                .font(BrandFont.body(14, weight: .light)).foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)
            Button { convene() } label: {
                Text("RETRY").font(BrandFont.mono(11, weight: .medium)).tracking(2)
                    .foregroundStyle(HE3Theme.crimson)
            }
        }
        .padding(.vertical, 12)
    }

    private func convene() {
        editorFocused = false
        let text = situation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let scores else { return }
        withAnimation { phase = .loading }

        // Owner preview: show a sample sitting without calling the backend.
        if progress.godMode {
            Task {
                try? await Task.sleep(for: .milliseconds(900))
                reflection = Self.sample
                withAnimation { phase = .done }
            }
            return
        }

        Task {
            let result = await ReflectionService.convene(situation: text, pillar: nil, scores: scores)
            switch result {
            case .ready(let r): reflection = r; withAnimation { phase = .done }
            case .locked: withAnimation { phase = .locked }
            case .failed: withAnimation { phase = .failed }
            }
        }
    }

    /// Sample sitting shown only in owner preview.
    static let sample = CouncilReflection(
        ego: "You already know the answer, you just want permission to move. Stop polling the room. Make the call, own the fallout, and let the result be the proof. Standing still is the only outcome that actually costs you.",
        selfVoice: "Slow down for one breath. The fear here is not the decision, it is being judged for it. Name what you actually want, not what looks defensible. Then act from that, and you will not have to defend anything.",
        innate: "Something in you went quiet the moment you typed this, and that quiet is the answer. You felt it before you built the case against it. Trust the first thing you knew. It was right.",
        synthesis: "All three point the same way, you are just waiting to be talked out of it. Choose the thing you knew in the first ten seconds, move on it today, and let your reasons catch up to your instinct instead of the other way around."
    )
}
