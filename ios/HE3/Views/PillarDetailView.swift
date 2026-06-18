import SwiftUI

struct ReflectionPrompt: Identifiable, Hashable {
    let id: String
    let text: String
    let isExercise: Bool
}

struct PillarDetailView: View {
    let pillar: PillarID
    var progress: UserProgressViewModel
    var journal: JournalViewModel

    private var content: PillarContentData? {
        PillarContentStore.content[pillar]
    }

    private var isLocked: Bool {
        !progress.isPillarUnlocked(pillar)
    }

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            if isLocked {
                lockedOverlay
            } else if let content {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        progressBar(content.sections)
                        sectionList(content.sections)
                        if pillar == .rising {
                            manifestoLink
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationTitle(pillar.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationDestination(for: PillarSection.self) { section in
            SectionDetailView(pillar: pillar, section: section, progress: progress, journal: journal)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: pillar.icon)
                    .font(.caption)
                    .foregroundStyle(HE3Theme.pillarAccent(pillar))

                Text("PILLAR \(pillar.rawValue) \u{00B7} WEEK \(pillar.week)")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.gold)
            }

            Text(pillar.title.uppercased())
                .font(BrandFont.display(28))
                .foregroundStyle(HE3Theme.textPrimary)

            Text(pillar.purpose)
                .font(BrandFont.body(16, weight: .light))
                .foregroundStyle(HE3Theme.ash)
        }
        .padding(.top, 8)
    }

    private func progressBar(_ sections: [PillarSection]) -> some View {
        let total = sections.count
        let done = progress.completedSectionCount(for: pillar)
        let pct = total > 0 ? Double(done) / Double(total) : 0
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SECTION PROGRESS")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.ashLight)
                Spacer()
                Text("\(done) / \(total)")
                    .font(BrandFont.mono(11, weight: .medium))
                    .foregroundStyle(HE3Theme.gold)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(HE3Theme.iron)
                    Rectangle()
                        .fill(HE3Theme.pillarAccent(pillar))
                        .frame(width: max(0, geo.size.width * pct))
                }
            }
            .frame(height: 3)
            .clipShape(.rect(cornerRadius: 0))
        }
    }

    private func sectionList(_ sections: [PillarSection]) -> some View {
        VStack(spacing: 2) {
            ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                sectionCard(section: section, index: index + 1)
            }
        }
    }

    @ViewBuilder
    private func sectionCard(section: PillarSection, index: Int) -> some View {
        let unlocked = progress.isSectionUnlocked(section, in: pillar)
        let completed = progress.isSectionCompleted(section)

        NavigationLink(value: section) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(unlocked ? HE3Theme.pillarAccent(pillar) : HE3Theme.steel.opacity(0.3))
                    .frame(width: 3)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: completed ? "checkmark.circle.fill" : (unlocked ? section.icon : "lock.fill"))
                            .font(.caption)
                            .foregroundStyle(completed ? HE3Theme.gold : (unlocked ? HE3Theme.pillarAccent(pillar) : HE3Theme.bone.opacity(0.3)))

                        Text("DAY \(index)")
                            .font(BrandFont.mono(9, weight: .medium))
                            .tracking(1.5)
                            .foregroundStyle(HE3Theme.bone.opacity(0.5))

                        if completed {
                            Text("COMPLETE")
                                .font(BrandFont.mono(8, weight: .medium))
                                .tracking(1)
                                .foregroundStyle(HE3Theme.background)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(HE3Theme.gold)
                                .clipShape(.rect(cornerRadius: 0))
                        }

                        Spacer()

                        if unlocked {
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(HE3Theme.ashLight.opacity(0.5))
                        }
                    }

                    Text(section.title.uppercased())
                        .font(BrandFont.display(17))
                        .foregroundStyle(unlocked ? HE3Theme.textPrimary : HE3Theme.ashLight.opacity(0.5))
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Image(systemName: "play.circle")
                            .font(.caption2)
                            .foregroundStyle(HE3Theme.gold.opacity(unlocked ? 0.8 : 0.3))

                        Text(section.videoDuration)
                            .font(BrandFont.mono(10))
                            .tracking(1)
                            .foregroundStyle(HE3Theme.bone.opacity(0.5))
                    }
                }
                .padding(16)
            }
            .background(HE3Theme.iron)
            .clipShape(.rect(cornerRadius: 0))
            .opacity(unlocked ? 1 : 0.55)
        }
        .disabled(!unlocked)
    }

    private var manifestoLink: some View {
        NavigationLink {
            ManifestoView(progress: progress)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.caption)
                    .foregroundStyle(HE3Theme.gold)

                VStack(alignment: .leading, spacing: 2) {
                    Text("WRITE YOUR MANIFESTO")
                        .font(BrandFont.display(16))
                        .foregroundStyle(HE3Theme.textPrimary)

                    Text("YOUR LIVING BLUEPRINT")
                        .font(BrandFont.mono(10))
                        .foregroundStyle(HE3Theme.ashLight)
                }

                Spacer()

                Text("\u{2192}")
                    .font(BrandFont.mono(16))
                    .foregroundStyle(HE3Theme.gold)
            }
            .padding(18)
            .background(HE3Theme.iron)
            .clipShape(.rect(cornerRadius: 0))
            .overlay(
                Rectangle()
                    .fill(HE3Theme.gold)
                    .frame(height: 2),
                alignment: .top
            )
            .clipShape(.rect(cornerRadius: 0))
        }
    }

    private var lockedOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 44))
                .foregroundStyle(HE3Theme.bone.opacity(0.3))

            VStack(spacing: 8) {
                Text(pillar.title.uppercased())
                    .font(BrandFont.display(26))
                    .foregroundStyle(HE3Theme.textPrimary)

                Text("UNLOCKS IN WEEK \(pillar.week)")
                    .font(BrandFont.mono(11, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.gold)

                Text("Complete the current pillar before advancing.\nProgression builds integrity.")
                    .font(BrandFont.body(15, weight: .light))
                    .foregroundStyle(HE3Theme.ash)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Section Detail

struct SectionDetailView: View {
    let pillar: PillarID
    let section: PillarSection
    var progress: UserProgressViewModel
    var journal: JournalViewModel
    @State private var activePrompt: ReflectionPrompt?

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    videoPlaceholder
                    bodyText
                    promptsSection
                    exercisesSection
                    completeButton
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
        .sheet(item: $activePrompt) { prompt in
            JournalEntrySheet(pillar: pillar, prompt: prompt.text, journal: journal)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: pillar.icon)
                    .font(.caption2)
                    .foregroundStyle(HE3Theme.pillarAccent(pillar))

                Text("\(pillar.shortTitle.uppercased()) \u{00B7} SECTION")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.pillarAccent(pillar))
            }

            Text(section.title.uppercased())
                .font(BrandFont.display(26))
                .foregroundStyle(HE3Theme.textPrimary)
        }
        .padding(.top, 8)
    }

    private var videoPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(HE3Theme.iron)
                .frame(height: 210)
                .clipShape(.rect(cornerRadius: 0))

            VStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(HE3Theme.gold)

                Text(section.videoTitle)
                    .font(BrandFont.display(18))
                    .foregroundStyle(HE3Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Text(section.videoDuration)
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(HE3Theme.bone.opacity(0.5))
            }
        }
    }

    private var bodyText: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THE TEACHING")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.ashLight)

            Text(section.body)
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .lineSpacing(4)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(HE3Theme.iron)
                .clipShape(.rect(cornerRadius: 0))
        }
    }

    private var promptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("REFLECTION PROMPTS")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.ashLight)

            ForEach(section.reflectionPrompts, id: \.self) { prompt in
                Button {
                    activePrompt = ReflectionPrompt(id: "p_\(section.id)_\(prompt.hashValue)", text: prompt, isExercise: false)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.line")
                            .font(.caption)
                            .foregroundStyle(HE3Theme.gold)

                        Text(prompt)
                            .font(BrandFont.body(14, weight: .light))
                            .foregroundStyle(HE3Theme.ash)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        Text("\u{2192}")
                            .font(BrandFont.mono(14))
                            .foregroundStyle(HE3Theme.gold)
                    }
                    .padding(14)
                    .background(HE3Theme.iron)
                    .clipShape(.rect(cornerRadius: 0))
                }
            }
        }
    }

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXERCISES")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.ashLight)

            ForEach(section.exercises, id: \.self) { exercise in
                Button {
                    activePrompt = ReflectionPrompt(id: "e_\(section.id)_\(exercise.hashValue)", text: exercise, isExercise: true)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Rectangle()
                            .fill(HE3Theme.pillarAccent(pillar))
                            .frame(width: 2, height: 16)
                            .padding(.top, 3)

                        Text(exercise)
                            .font(BrandFont.body(14, weight: .light))
                            .foregroundStyle(HE3Theme.ash)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(3)

                        Spacer(minLength: 8)

                        Image(systemName: "pencil.line")
                            .font(.caption2)
                            .foregroundStyle(HE3Theme.gold)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(HE3Theme.iron)
                    .clipShape(.rect(cornerRadius: 0))
                }
            }
        }
    }

    private var completeButton: some View {
        let completed = progress.isSectionCompleted(section)
        return Button {
            if completed {
                progress.unmarkSectionCompleted(section)
            } else {
                progress.markSectionCompleted(section)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                Text(completed ? "SECTION COMPLETE" : "MARK SECTION COMPLETE")
                    .font(BrandFont.mono(12, weight: .medium))
                    .tracking(1.5)
            }
            .foregroundStyle(completed ? HE3Theme.background : HE3Theme.gold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(completed ? HE3Theme.gold : HE3Theme.iron)
            .clipShape(.rect(cornerRadius: 0))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(HE3Theme.gold, lineWidth: completed ? 0 : 1)
            )
        }
        .padding(.top, 8)
    }
}
