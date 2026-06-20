import SwiftUI

enum JournalFilter: Hashable {
    case all
    case myJournaling
    case pillar(PillarID)
}

struct JournalView: View {
    var journal: JournalViewModel
    var progress: UserProgressViewModel
    @State private var filter: JournalFilter = .all
    @State private var showCustomSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                if journal.entries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            filterChips
                            content
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCustomSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(HE3Theme.gold)
                    }
                    .accessibilityLabel("New Journal Entry")
                }
            }
            .sheet(isPresented: $showCustomSheet) {
                CustomJournalEntrySheet(journal: journal)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch filter {
        case .all:
            allEntriesList
        case .myJournaling:
            myJournalingList
        case .pillar(let pillar):
            pillarGroupedList(pillar: pillar)
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                FilterChip(title: "ALL", isSelected: filter == .all) {
                    filter = .all
                }
                FilterChip(title: "MY JOURNALING", isSelected: filter == .myJournaling) {
                    filter = .myJournaling
                }
                ForEach(PillarID.allCases) { pillar in
                    FilterChip(title: pillar.shortTitle.uppercased(), isSelected: filter == .pillar(pillar)) {
                        filter = .pillar(pillar)
                    }
                }
            }
        }
        .contentMargins(.horizontal, 0)
        .scrollIndicators(.hidden)
    }

    private var allEntriesList: some View {
        LazyVStack(spacing: 2) {
            ForEach(journal.entries) { entry in
                JournalEntryCard(entry: entry) {
                    journal.deleteEntry(entry)
                }
            }
        }
    }

    private var myJournalingList: some View {
        let entries = journal.customEntries
        return Group {
            if entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 36))
                        .foregroundStyle(HE3Theme.ashLight)
                    Text("NO PERSONAL ENTRIES")
                        .font(BrandFont.display(20))
                        .foregroundStyle(HE3Theme.textPrimary)
                    Text("Tap the + button to write\nyour own journal prompt.")
                        .font(BrandFont.body(14, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: 2) {
                    ForEach(entries) { entry in
                        JournalEntryCard(entry: entry) {
                            journal.deleteEntry(entry)
                        }
                    }
                }
            }
        }
    }

    private func pillarGroupedList(pillar: PillarID) -> some View {
        let groups = journal.groupedByPrompt(for: pillar)
        return Group {
            if groups.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: pillar.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(HE3Theme.pillarAccent(pillar).opacity(0.4))
                    Text("NO ENTRIES YET")
                        .font(BrandFont.display(20))
                        .foregroundStyle(HE3Theme.textPrimary)
                    Text("Reflections from \(pillar.shortTitle) prompts\nwill appear here.")
                        .font(BrandFont.body(14, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
            } else {
                LazyVStack(alignment: .leading, spacing: 18) {
                    ForEach(groups, id: \.prompt) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(group.prompt.uppercased())
                                .font(BrandFont.mono(10, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(HE3Theme.pillarAccent(pillar))
                                .padding(.horizontal, 4)

                            VStack(spacing: 2) {
                                ForEach(group.entries) { entry in
                                    JournalEntryCard(entry: entry) {
                                        journal.deleteEntry(entry)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 44))
                .foregroundStyle(HE3Theme.ashLight)

            Text("NO JOURNAL ENTRIES")
                .font(BrandFont.display(24))
                .foregroundStyle(HE3Theme.textPrimary)

            Text("Tap + to write your own prompt,\nor start a reflection from any pillar.")
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)

            Button {
                showCustomSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("NEW ENTRY")
                        .font(BrandFont.mono(12, weight: .medium))
                        .tracking(1.5)
                }
                .foregroundStyle(HE3Theme.background)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(HE3Theme.gold)
                .clipShape(.rect(cornerRadius: 0))
            }
            .padding(.top, 8)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BrandFont.mono(11, weight: .medium))
                .tracking(1)
                .foregroundStyle(isSelected ? HE3Theme.background : HE3Theme.ash)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? HE3Theme.gold : HE3Theme.iron)
                .clipShape(.rect(cornerRadius: 0))
        }
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let onDelete: () -> Void
    @State private var showDeleteAlert = false

    private var accentColor: Color {
        if let pillar = entry.pillarID {
            return HE3Theme.pillarAccent(pillar)
        }
        return HE3Theme.gold
    }

    private var tagIcon: String {
        if let pillar = entry.pillarID { return pillar.icon }
        return "square.and.pencil"
    }

    private var tagLabel: String {
        if let pillar = entry.pillarID { return pillar.shortTitle.uppercased() }
        return "MY JOURNALING"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: tagIcon)
                    .font(.caption2)
                    .foregroundStyle(accentColor)

                Text(tagLabel)
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(accentColor)

                Spacer()

                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(BrandFont.mono(10))
                    .foregroundStyle(HE3Theme.ashLight)
            }

            Text(entry.prompt)
                .font(BrandFont.body(15, weight: .medium))
                .foregroundStyle(HE3Theme.gold)
                .lineLimit(2)

            Text(entry.content)
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .lineLimit(4)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
        .contextMenu {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Entry?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This journal entry will be permanently deleted.")
        }
    }
}

struct JournalEntrySheet: View {
    let pillar: PillarID
    let prompt: String
    var journal: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 8) {
                            Image(systemName: pillar.icon)
                                .font(.caption2)
                                .foregroundStyle(HE3Theme.pillarAccent(pillar))

                            Text(pillar.shortTitle.uppercased())
                                .font(BrandFont.mono(10, weight: .medium))
                                .tracking(1)
                                .foregroundStyle(HE3Theme.pillarAccent(pillar))
                        }

                        Text(prompt)
                            .font(BrandFont.body(20, weight: .medium))
                            .foregroundStyle(HE3Theme.gold)

                        TextEditor(text: $text)
                            .font(.body)
                            .foregroundStyle(HE3Theme.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 300)
                            .focused($isFocused)
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Reflect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        journal.addEntry(pillarID: pillar, prompt: prompt, content: text)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear { isFocused = true }
        }
    }
}

struct CustomJournalEntrySheet: View {
    var journal: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var prompt: String = ""
    @State private var content: String = ""
    @State private var createdAt: Date = Date()
    @FocusState private var focus: Field?

    enum Field { case prompt, content }

    private var isValid: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.pencil")
                                .font(.caption2)
                                .foregroundStyle(HE3Theme.gold)

                            Text("MY JOURNALING")
                                .font(BrandFont.mono(10, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(HE3Theme.gold)

                            Spacer()

                            Text(createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(BrandFont.mono(10))
                                .foregroundStyle(HE3Theme.ashLight)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("YOUR PROMPT")
                                .font(BrandFont.mono(10, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(HE3Theme.ashLight)

                            TextField("What do you want to reflect on?", text: $prompt, axis: .vertical)
                                .font(BrandFont.body(18, weight: .medium))
                                .foregroundStyle(HE3Theme.gold)
                                .lineLimit(1...3)
                                .focused($focus, equals: .prompt)
                                .padding(14)
                                .background(HE3Theme.iron)
                                .clipShape(.rect(cornerRadius: 0))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("YOUR RESPONSE")
                                .font(BrandFont.mono(10, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(HE3Theme.ashLight)

                            TextEditor(text: $content)
                                .font(.body)
                                .foregroundStyle(HE3Theme.textPrimary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 260)
                                .focused($focus, equals: .content)
                                .padding(10)
                                .background(HE3Theme.iron)
                                .clipShape(.rect(cornerRadius: 0))
                        }
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        journal.addCustomEntry(prompt: prompt, content: content)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                createdAt = Date()
                focus = .prompt
            }
        }
    }
}
