import Foundation

nonisolated struct RitualVideo: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let filename: String
    let date: Date
    var note: String?
    var durationSeconds: Double

    init(
        id: UUID = UUID(),
        filename: String,
        date: Date = Date(),
        note: String? = nil,
        durationSeconds: Double = 0
    ) {
        self.id = id
        self.filename = filename
        self.date = date
        self.note = note
        self.durationSeconds = durationSeconds
    }
}
