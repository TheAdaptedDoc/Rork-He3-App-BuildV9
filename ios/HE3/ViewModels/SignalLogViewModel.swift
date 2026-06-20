import Foundation

/// Local store for the Signal Log, mirroring how the Journal and Rituals persist.
/// Captures stay on the device, newest first.
@Observable
@MainActor
final class SignalLogViewModel {
    var entries: [SignalEntry] = []

    private let defaults = UserDefaults.standard
    private let storageKey = "he3_signal_log"

    var sortedEntries: [SignalEntry] { entries.sorted { $0.date > $1.date } }

    func load() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([SignalEntry].self, from: data) {
            entries = decoded
        }
    }

    func capture(_ signal: String) {
        let trimmed = signal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        entries.insert(SignalEntry(signal: trimmed), at: 0)
        save()
    }

    func recordAct(for entry: SignalEntry, note: String) {
        guard let i = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[i].actNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        entries[i].actedDate = Date()
        save()
    }

    func delete(_ entry: SignalEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
