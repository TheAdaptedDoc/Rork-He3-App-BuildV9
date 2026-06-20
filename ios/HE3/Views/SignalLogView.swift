import SwiftUI

/// The Signal Log. The Innate capture discipline: Receive in silence, Capture the
/// signal here, then Act. Captures are dated and kept in order, same format as the
/// Council and the Rituals.
struct SignalLogView: View {
    var log: SignalLogViewModel
    var progress: UserProgressViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var draft = ""
    @State private var selected: SignalEntry?
    @FocusState private var composerFocused: Bool

    private var entries: [SignalEntry] {
        if progress.godMode && log.entries.isEmpty { return Self.sample }
        return log.sortedEntries
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Spacer().frame(height: 6)

                    Text("PILLAR ONE \u{00B7} INNATE")
                        .font(BrandFont.mono(10, weight: .medium)).tracking(3)
                        .foregroundStyle(HE3Theme.ember)
                    Text("THE SIGNAL LOG")
                        .font(BrandFont.display(36)).foregroundStyle(HE3Theme.textPrimary)
                    Text("Receive in silence. Capture the signal before the noise reclaims it. Then act.")
                        .font(BrandFont.body(16, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .multilineTextAlignment(.center).padding(.horizontal, 28)

                    composer

                    if !progress.silenceHabitSet {
                        silenceBanner
                    }

                    if entries.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 12) {
                            Text("\(entries.count) SIGNAL\(entries.count == 1 ? "" : "S") CAPTURED")
                                .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                                .foregroundStyle(HE3Theme.ashLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ForEach(entries) { entry in
                                Button { selected = entry } label: { card(entry) }
                            }
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
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
            .sheet(item: $selected) { entry in
                SignalDetail(
                    entry: entry,
                    log: log,
                    readOnly: progress.godMode && log.entries.isEmpty,
                    actUnlocked: progress.silenceHabitSet,
                    sessions: progress.quietBridgeSessions,
                    threshold: UserProgressViewModel.silenceHabitThreshold
                )
            }
        }
        .preferredColorScheme(.light)
    }

    private var composer: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topLeading) {
                if draft.isEmpty {
                    Text("The thing you just knew, in a line.")
                        .font(BrandFont.body(16, weight: .light))
                        .foregroundStyle(HE3Theme.ashLight)
                        .padding(.horizontal, 14).padding(.vertical, 14)
                }
                TextEditor(text: $draft)
                    .focused($composerFocused)
                    .font(BrandFont.body(16, weight: .regular))
                    .foregroundStyle(HE3Theme.obsidian)
                    .scrollContentBackground(.hidden)
                    .frame(height: 96)
                    .padding(6)
            }
            .background(HE3Theme.surface)
            .overlay(Rectangle().stroke(HE3Theme.paperDark, lineWidth: 1))

            Button {
                composerFocused = false
                log.capture(draft)
                draft = ""
            } label: {
                Text("LOG THE SIGNAL")
                    .font(BrandFont.display(20)).tracking(2)
                    .foregroundStyle(HE3Theme.bone)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? HE3Theme.paperDark : HE3Theme.ember)
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func card(_ e: SignalEntry) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle().fill(HE3Theme.ember).frame(width: 3)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(e.dateLabel)
                        .font(BrandFont.mono(10, weight: .medium)).tracking(1)
                        .foregroundStyle(HE3Theme.ashLight)
                    Spacer()
                    Text(e.acted ? "ACTED" : "CAPTURED")
                        .font(BrandFont.mono(8, weight: .medium)).tracking(1.5)
                        .foregroundStyle(e.acted ? HE3Theme.bone : HE3Theme.ash)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(e.acted ? HE3Theme.ember : HE3Theme.paperDark)
                }
                Text(e.signal)
                    .font(BrandFont.body(16, weight: .regular))
                    .foregroundStyle(HE3Theme.textPrimary).lineLimit(3)
            }
            .padding(14)
            Spacer(minLength: 0)
        }
        .background(HE3Theme.surface)
    }

    private var silenceBanner: some View {
        let sessions = progress.quietBridgeSessions
        let threshold = UserProgressViewModel.silenceHabitThreshold
        let remaining = max(0, threshold - sessions)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12)).foregroundStyle(HE3Theme.ashLight)
                Text("THE ACT PASS OPENS IN \(remaining) MORE SILENCE\(remaining == 1 ? "" : "S")")
                    .font(BrandFont.mono(9, weight: .medium)).tracking(1.5)
                    .foregroundStyle(HE3Theme.ash)
                Spacer()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(HE3Theme.paperDark).frame(height: 4)
                    Rectangle().fill(HE3Theme.ember)
                        .frame(width: geo.size.width * min(1.0, Double(sessions) / Double(max(1, threshold))), height: 4)
                }
            }
            .frame(height: 4)
            Text("Capture freely. Action unlocks once the Quiet Bridge is a habit.")
                .font(BrandFont.body(13, weight: .light)).foregroundStyle(HE3Theme.ashLight)
        }
        .padding(14)
        .background(HE3Theme.surface)
        .overlay(Rectangle().fill(HE3Theme.ember).frame(width: 3), alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            VoiceIcon(voice: .innate, size: 30)
            Text("NO SIGNALS YET")
                .font(BrandFont.display(22)).foregroundStyle(HE3Theme.textPrimary)
            Text("After the Quiet Bridge, capture what you received. Every signal is kept here, in order.")
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center).padding(.horizontal, 34)
        }
        .padding(.vertical, 8)
    }

    static let sample: [SignalEntry] = [
        SignalEntry(date: Date().addingTimeInterval(-3600), signal: "Call the brother I have been avoiding. The avoidance is the message."),
        SignalEntry(date: Date().addingTimeInterval(-86400), signal: "The new client is wrong for me. I felt it before the numbers.", actNote: "Passed on the contract. Relief, not regret.", actedDate: Date().addingTimeInterval(-80000))
    ]
}

private struct SignalDetail: View {
    let entry: SignalEntry
    var log: SignalLogViewModel
    var readOnly: Bool
    var actUnlocked: Bool
    var sessions: Int
    var threshold: Int
    @Environment(\.dismiss) private var dismiss
    @State private var actDraft = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(entry.dateLabel.uppercased())
                        .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                        .foregroundStyle(HE3Theme.ashLight)

                    HStack(spacing: 8) {
                        VoiceIcon(voice: .innate, size: 18)
                        Text("THE SIGNAL")
                            .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                            .foregroundStyle(HE3Theme.ember)
                    }
                    Text(entry.signal)
                        .font(BrandFont.body(19, weight: .regular))
                        .foregroundStyle(HE3Theme.textPrimary).lineSpacing(4)

                    Rectangle().fill(HE3Theme.paperDark).frame(height: 1)

                    Text("THE ACT PASS")
                        .font(BrandFont.mono(10, weight: .medium)).tracking(2)
                        .foregroundStyle(HE3Theme.textPrimary)

                    if let note = entry.actNote, entry.acted {
                        Text(note)
                            .font(BrandFont.body(16, weight: .regular))
                            .foregroundStyle(HE3Theme.ash).lineSpacing(4)
                        if let d = entry.actedDate {
                            Text("ACTED \u{00B7} \(d.formatted(date: .abbreviated, time: .shortened))".uppercased())
                                .font(BrandFont.mono(9, weight: .medium)).tracking(1)
                                .foregroundStyle(HE3Theme.ember)
                        }
                    } else if !actUnlocked {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 13)).foregroundStyle(HE3Theme.ashLight)
                                Text("LOCKED UNTIL THE HABIT IS SET")
                                    .font(BrandFont.mono(10, weight: .medium)).tracking(1.5)
                                    .foregroundStyle(HE3Theme.ash)
                            }
                            Text("Action is earned by silence. Hold the Quiet Bridge \(threshold) days to set the habit, then the Act Pass opens.")
                                .font(BrandFont.body(15, weight: .light))
                                .foregroundStyle(HE3Theme.ash).lineSpacing(3)
                            VStack(alignment: .leading, spacing: 6) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Rectangle().fill(HE3Theme.paperDark).frame(height: 4)
                                        Rectangle().fill(HE3Theme.ember)
                                            .frame(width: geo.size.width * min(1.0, Double(sessions) / Double(max(1, threshold))), height: 4)
                                    }
                                }
                                .frame(height: 4)
                                Text("\(min(sessions, threshold)) OF \(threshold) SILENCES HELD")
                                    .font(BrandFont.mono(9, weight: .medium)).tracking(1.5)
                                    .foregroundStyle(HE3Theme.ashLight)
                            }
                        }
                    } else if readOnly {
                        Text("A signal received is not yet a signal honored. The Act Pass is where you move on it.")
                            .font(BrandFont.body(15, weight: .light)).foregroundStyle(HE3Theme.ash)
                    } else {
                        Text("A signal received is not yet a signal honored. Name the one move you will make.")
                            .font(BrandFont.body(14, weight: .light)).foregroundStyle(HE3Theme.ash)
                        ZStack(alignment: .topLeading) {
                            if actDraft.isEmpty {
                                Text("What you will do about it.")
                                    .font(BrandFont.body(15, weight: .light))
                                    .foregroundStyle(HE3Theme.ashLight)
                                    .padding(.horizontal, 14).padding(.vertical, 12)
                            }
                            TextEditor(text: $actDraft)
                                .font(BrandFont.body(15, weight: .regular))
                                .foregroundStyle(HE3Theme.obsidian)
                                .scrollContentBackground(.hidden)
                                .frame(height: 90).padding(6)
                        }
                        .background(HE3Theme.surface)
                        .overlay(Rectangle().stroke(HE3Theme.paperDark, lineWidth: 1))

                        Button {
                            log.recordAct(for: entry, note: actDraft)
                            dismiss()
                        } label: {
                            Text("MARK THE ACT PASS")
                                .font(BrandFont.display(18)).tracking(2)
                                .foregroundStyle(HE3Theme.bone)
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .background(actDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? HE3Theme.paperDark : HE3Theme.ember)
                        }
                        .disabled(actDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .background(HE3Theme.background)
            .navigationTitle("Signal").navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .preferredColorScheme(.light)
    }
}
