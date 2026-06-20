import Foundation

/// One stored Council sitting, read back from the reflections table.
nonisolated struct CouncilSitting: Codable, Sendable, Identifiable {
    let id: UUID
    let pillar: String?
    let situation: String
    let ego: String
    let selfVoice: String
    let innate: String
    let synthesis: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, pillar, situation, ego, innate, synthesis
        case selfVoice = "self_voice"
        case createdAt = "created_at"
    }

    var reflection: CouncilReflection {
        CouncilReflection(ego: ego, selfVoice: selfVoice, innate: innate, synthesis: synthesis)
    }

    /// Lenient parse of the Postgres timestamp for display and sorting.
    var date: Date {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: createdAt) { return d }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: createdAt) { return d }
        return .distantPast
    }

    var dateLabel: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}
