import SwiftUI

struct DashboardView: View {
    var progress: UserProgressViewModel
    var journal: JournalViewModel
    var rituals: RitualVideoViewModel
    var signalLog: SignalLogViewModel
    var accessState: AccessState = .fullProgram
    @State private var showNightPractice = false
    @State private var showRecalibration = false
    @State private var showReadback = false
    @State private var showCouncil = false
    @State private var showSignalLog = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if progress.godMode {
                        godModeBanner
                    }
                    if accessState == .dailyPracticeOnly {
                        dailyPracticeBanner
                    }
                    if accessState == .fullProgram {
                        countdownSection
                        currentPillarCard
                    } else {
                        lockedProgramCard
                    }
                    practiceSection
                    streakSection
                    if accessState == .fullProgram {
                        councilButton
                        signalLogButton
                    }
                    if progress.hasCompletedAssessment {
                        voiceProfileButton
                        recalibrationButton
                    }
                    nightPracticeButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .background(HE3Theme.background)
            .navigationTitle("HE\u{00B3}")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .fullScreenCover(isPresented: $showNightPractice) {
                NightPracticeView(rituals: rituals)
            }
            .fullScreenCover(isPresented: $showRecalibration) {
                RecalibrationView(progress: progress)
            }
            .fullScreenCover(isPresented: $showReadback) {
                VoiceProfileReadbackView(progress: progress)
            }
            .fullScreenCover(isPresented: $showCouncil) {
                CouncilView(progress: progress)
            }
            .fullScreenCover(isPresented: $showSignalLog) {
                SignalLogView(log: signalLog, progress: progress)
            }
        }
    }

    private var dailyPracticeBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.caption)
                .foregroundStyle(HE3Theme.obsidian)
            VStack(alignment: .leading, spacing: 2) {
                Text("DAILY PRACTICE")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.obsidian)
                Text("Your ritual and journal stay open. The full program window has closed.")
                    .font(BrandFont.body(11, weight: .light))
                    .foregroundStyle(HE3Theme.ash)
            }
            Spacer()
        }
        .padding(12)
        .overlay(Rectangle().stroke(HE3Theme.obsidian, lineWidth: 1.5))
    }

    private var lockedProgramCard: some View {
        Button {
            CheckoutLauncher.openCheckout(uid: AuthManager.shared.userId)
        } label: {
            HStack(spacing: 0) {
                Rectangle().fill(HE3Theme.crimson).frame(width: 3)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(HE3Theme.crimson)
                        Text("THE FULL PROGRAM")
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.crimson)
                        Spacer()
                    }
                    Text("UNLOCK THE 30 DAY SPRINT")
                        .font(BrandFont.display(22))
                        .foregroundStyle(HE3Theme.textPrimary)
                    Text("Open a new 90 day window and walk all four pillars again.")
                        .font(BrandFont.body(14, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                }
                .padding(18)
            }
            .background(HE3Theme.surface)
        }
    }

    private var signalLogButton: some View {
        Button {
            showSignalLog = true
        } label: {
            HStack(spacing: 0) {
                Rectangle().fill(HE3Theme.ember).frame(width: 3)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        VoiceIcon(voice: .innate, size: 16)
                        Text("PILLAR ONE \u{00B7} INNATE")
                            .font(BrandFont.mono(9, weight: .medium)).tracking(2)
                            .foregroundStyle(HE3Theme.ember)
                        Spacer()
                    }
                    Text("THE SIGNAL LOG")
                        .font(BrandFont.display(24))
                        .foregroundStyle(HE3Theme.textPrimary)
                    Text("Capture what you receive in the silence. Then act on it.")
                        .font(BrandFont.body(14, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                }
                .padding(18)
                Spacer(minLength: 0)
            }
            .background(HE3Theme.surface)
        }
    }

    private var councilButton: some View {
        Button {
            showCouncil = true
        } label: {
            HStack(spacing: 0) {
                Rectangle().fill(HE3Theme.crimson).frame(width: 3)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        SeriesMarks(height: 13, width: 3, spacing: 3)
                        Text("PILLAR THREE \u{00B7} KEYSTONE")
                            .font(BrandFont.mono(9, weight: .medium)).tracking(2)
                            .foregroundStyle(HE3Theme.crimson)
                        Spacer()
                    }
                    Text("THE COUNCIL")
                        .font(BrandFont.display(24))
                        .foregroundStyle(HE3Theme.textPrimary)
                    Text("Bring a decision. Your three voices weigh in, then give you one read.")
                        .font(BrandFont.body(14, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                }
                .padding(18)
                Spacer(minLength: 0)
            }
            .background(HE3Theme.surface)
        }
    }

    private var voiceProfileButton: some View {
        Button {
            showReadback = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "waveform.path")
                    .font(.caption)
                    .foregroundStyle(HE3Theme.ember)
                VStack(alignment: .leading, spacing: 2) {
                    Text("READING YOUR VOICE PROFILE")
                        .font(BrandFont.display(16))
                        .foregroundStyle(HE3Theme.textPrimary)
                    Text("YOUR DAY 0 RESULT, READ BACK")
                        .font(BrandFont.mono(10))
                        .foregroundStyle(HE3Theme.ashLight)
                }
                Spacer()
                Text("\u{2192}")
                    .font(BrandFont.mono(16))
                    .foregroundStyle(HE3Theme.ember)
            }
            .padding(18)
            .background(HE3Theme.surface)
        }
    }

    private var recalibrationButton: some View {
        Button {
            showRecalibration = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundStyle(HE3Theme.crimson)
                VStack(alignment: .leading, spacing: 2) {
                    Text("THE RE CALIBRATION")
                        .font(BrandFont.display(16))
                        .foregroundStyle(HE3Theme.textPrimary)
                    Text("MEASURE THE SHIFT, DAY 0 TO DAY 30")
                        .font(BrandFont.mono(10))
                        .foregroundStyle(HE3Theme.ashLight)
                }
                Spacer()
                Text("\u{2192}")
                    .font(BrandFont.mono(16))
                    .foregroundStyle(HE3Theme.crimson)
            }
            .padding(18)
            .background(HE3Theme.surface)
        }
    }

    private var godModeBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "eye.trianglebadge.exclamationmark.fill")
                .font(.caption)
                .foregroundStyle(HE3Theme.background)

            VStack(alignment: .leading, spacing: 2) {
                Text("GOD MODE ACTIVE")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.background)
                Text("All pillars and screens unlocked for review")
                    .font(BrandFont.body(11, weight: .light))
                    .foregroundStyle(HE3Theme.background.opacity(0.75))
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.3)) {
                    progress.godMode = false
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Text("EXIT")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.background)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(HE3Theme.background.opacity(0.18))
                    .clipShape(.rect(cornerRadius: 0))
            }
        }
        .padding(12)
        .background(HE3Theme.gold)
        .clipShape(.rect(cornerRadius: 0))
    }

    private var countdownSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(HE3Theme.steel, lineWidth: 6)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: progress.overallProgress)
                    .stroke(HE3Theme.gold, style: StrokeStyle(lineWidth: 6, lineCap: .butt))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(progress.daysRemaining)")
                        .font(BrandFont.display(48))
                        .foregroundStyle(HE3Theme.textPrimary)

                    Text("DAYS LEFT")
                        .font(BrandFont.mono(9, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(HE3Theme.ashLight)
                }
            }

            if progress.isInIntegrationPhase {
                Text("INTEGRATION PHASE")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.gold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(HE3Theme.gold.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 0))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var currentPillarCard: some View {
        let pillar = progress.currentPillar
        return NavigationLink(value: pillar) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(HE3Theme.pillarAccent(pillar))
                    .frame(width: 3)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: pillar.icon)
                            .font(.caption)
                            .foregroundStyle(HE3Theme.pillarAccent(pillar))

                        Text("WEEK \(pillar.week)")
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.gold)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(HE3Theme.ashLight.opacity(0.5))
                    }

                    Text(pillar.title.uppercased())
                        .font(BrandFont.display(22))
                        .foregroundStyle(HE3Theme.textPrimary)

                    Text(pillar.purpose)
                        .font(BrandFont.body(14, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .lineLimit(2)
                }
                .padding(18)
            }
            .background(HE3Theme.iron)
            .clipShape(.rect(cornerRadius: 0))
        }
        .navigationDestination(for: PillarID.self) { pillar in
            PillarDetailView(pillar: pillar, progress: progress, journal: journal)
        }
    }

    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TODAY'S PRACTICES")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.ashLight)

                Spacer()

                Text("\(progress.todayCompletedCount)/\(progress.todayTotalPractices)")
                    .font(BrandFont.mono(12, weight: .medium))
                    .foregroundStyle(HE3Theme.gold)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(HE3Theme.steel)
                        .frame(height: 3)

                    Rectangle()
                        .fill(HE3Theme.gold)
                        .frame(width: geo.size.width * Double(progress.todayCompletedCount) / Double(max(1, progress.todayTotalPractices)), height: 3)
                }
            }
            .frame(height: 3)

            VStack(spacing: 6) {
                ForEach(PracticeData.allPractices.prefix(4)) { practice in
                    PracticeRow(practice: practice, isCompleted: progress.isPracticeCompleted(practice.id)) {
                        progress.togglePractice(practice.id)
                    }
                }
            }
        }
        .padding(18)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }

    private var streakSection: some View {
        HStack(spacing: 8) {
            StatCard(value: "\(progress.currentStreak)", label: "DAY STREAK", icon: "flame.fill")
            StatCard(value: "W\(progress.currentWeek)", label: "CURRENT WEEK", icon: "calendar")
            StatCard(value: "\(Int(progress.overallProgress * 100))%", label: "COMPLETE", icon: "chart.bar.fill")
        }
    }

    private var nightPracticeButton: some View {
        Button {
            showNightPractice = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "moon.stars.fill")
                    .font(.caption)
                    .foregroundStyle(HE3Theme.gold)

                VStack(alignment: .leading, spacing: 2) {
                    Text("NIGHT PRACTICE")
                        .font(BrandFont.display(16))
                        .foregroundStyle(HE3Theme.textPrimary)

                    Text("THE COURAGE RITUAL")
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
        }
    }
}

struct PracticeRow: View {
    let practice: Practice
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                    .font(.body)
                    .foregroundStyle(isCompleted ? HE3Theme.gold : HE3Theme.steel)
                    .contentTransition(.symbolEffect(.replace))

                VStack(alignment: .leading, spacing: 1) {
                    Text(practice.title)
                        .font(BrandFont.body(15, weight: .medium))
                        .foregroundStyle(isCompleted ? HE3Theme.bone.opacity(0.4) : HE3Theme.textPrimary)
                        .strikethrough(isCompleted)

                    Text(practice.voice.displayName.uppercased())
                        .font(BrandFont.mono(9, weight: .medium))
                        .tracking(1)
                        .foregroundStyle(HE3Theme.voiceColor(practice.voice).opacity(0.6))
                }

                Spacer()
            }
            .padding(.vertical, 4)
        }
        .sensoryFeedback(.selection, trigger: isCompleted)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(HE3Theme.gold)

            Text(value)
                .font(BrandFont.display(26))
                .foregroundStyle(HE3Theme.textPrimary)

            Text(label)
                .font(BrandFont.mono(7, weight: .medium))
                .tracking(1)
                .foregroundStyle(HE3Theme.ashLight)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }
}
