import Foundation

@Observable
@MainActor
class JournalViewModel {
    var entries: [JournalEntry] = []

    private let defaults = UserDefaults.standard
    private let storageKey = "he3_journal_entries"

    func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) else { return }
        entries = decoded
    }

    func addEntry(pillarID: PillarID, prompt: String, content: String) {
        let entry = JournalEntry(pillarID: pillarID, prompt: prompt, content: content, kind: .pillarPrompt)
        entries.insert(entry, at: 0)
        save()
    }

    func addCustomEntry(prompt: String, content: String) {
        let entry = JournalEntry(pillarID: nil, prompt: prompt, content: content, kind: .custom)
        entries.insert(entry, at: 0)
        save()
    }

    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func entriesForPillar(_ pillar: PillarID) -> [JournalEntry] {
        entries.filter { $0.pillarID == pillar && $0.kind == .pillarPrompt }
    }

    var customEntries: [JournalEntry] {
        entries.filter { $0.kind == .custom }
    }

    /// Groups pillar entries by their prompt (acts as "subsection") in original order.
    func groupedByPrompt(for pillar: PillarID) -> [(prompt: String, entries: [JournalEntry])] {
        let filtered = entriesForPillar(pillar)
        var order: [String] = []
        var map: [String: [JournalEntry]] = [:]
        for entry in filtered {
            if map[entry.prompt] == nil {
                order.append(entry.prompt)
                map[entry.prompt] = []
            }
            map[entry.prompt]?.append(entry)
        }
        return order.map { ($0, map[$0] ?? []) }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
