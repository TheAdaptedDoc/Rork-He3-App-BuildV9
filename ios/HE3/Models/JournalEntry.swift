import Foundation

nonisolated enum JournalEntryKind: String, Codable, Sendable {
    case pillarPrompt
    case custom
}

nonisolated struct JournalEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let pillarID: PillarID?
    let prompt: String
    let content: String
    let date: Date
    let kind: JournalEntryKind

    init(
        id: UUID = UUID(),
        pillarID: PillarID? = nil,
        prompt: String,
        content: String,
        date: Date = Date(),
        kind: JournalEntryKind = .pillarPrompt
    ) {
        self.id = id
        self.pillarID = pillarID
        self.prompt = prompt
        self.content = content
        self.date = date
        self.kind = kind
    }

    enum CodingKeys: String, CodingKey {
        case id, pillarID, prompt, content, date, kind
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.pillarID = try c.decodeIfPresent(PillarID.self, forKey: .pillarID)
        self.prompt = try c.decode(String.self, forKey: .prompt)
        self.content = try c.decode(String.self, forKey: .content)
        self.date = try c.decode(Date.self, forKey: .date)
        self.kind = (try c.decodeIfPresent(JournalEntryKind.self, forKey: .kind)) ?? (self.pillarID == nil ? .custom : .pillarPrompt)
    }
}
