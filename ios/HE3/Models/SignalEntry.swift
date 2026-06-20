import Foundation

/// One captured signal in the Signal Log, the Innate capture discipline.
/// Receive (the Quiet Bridge), Capture (this), Act (the Act Pass).
nonisolated struct SignalEntry: Codable, Sendable, Identifiable {
    let id: UUID
    let date: Date
    var signal: String
    var actNote: String?
    var actedDate: Date?

    init(id: UUID = UUID(), date: Date = Date(), signal: String, actNote: String? = nil, actedDate: Date? = nil) {
        self.id = id
        self.date = date
        self.signal = signal
        self.actNote = actNote
        self.actedDate = actedDate
    }

    var acted: Bool { actedDate != nil }

    var dateLabel: String { date.formatted(date: .abbreviated, time: .shortened) }
}
