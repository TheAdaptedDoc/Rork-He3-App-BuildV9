import Foundation

nonisolated struct Practice: Identifiable, Codable, Sendable {
    let id: String
    let voice: Voice
    let title: String
    let description: String
    let icon: String
}

nonisolated struct DailyPracticeLog: Codable, Sendable {
    let date: String
    var completedPracticeIDs: Set<String>
}

nonisolated enum PracticeData {
    static let egoPractices: [Practice] = [
        Practice(id: "cold_rebirth", voice: .ego, title: "Cold Rebirth", description: "Begin every morning with cold immersion or breathwork to reset nervous equilibrium.", icon: "snowflake"),
        Practice(id: "posture_assertion", voice: .ego, title: "Posture Assertion", description: "60 seconds of perfect stance — spine tall, breath deep. Command presence.", icon: "figure.stand"),
        Practice(id: "boundary_reps", voice: .ego, title: "Boundary Reps", description: "Document micro-moments you enforced truth today.", icon: "shield.checkered"),
        Practice(id: "validation_reset", voice: .ego, title: "Validation Reset", description: "When craving approval, breathe deep: \"Nothing to prove; only presence to keep.\"", icon: "heart.slash")
    ]

    static let selfPractices: [Practice] = [
        Practice(id: "midday_reset", voice: .selfVoice, title: "Midday Reset", description: "Pause mid-task and label your emotion in one word.", icon: "clock.arrow.circlepath"),
        Practice(id: "thought_audit", voice: .selfVoice, title: "Thought Audit", description: "Stream-of-consciousness notes. Don't clean it — clarity is in the mess.", icon: "note.text"),
        Practice(id: "pattern_extraction", voice: .selfVoice, title: "Pattern Extraction", description: "Circle recurring triggers. They reveal inner architecture.", icon: "circle.grid.cross"),
        Practice(id: "decision_journal", voice: .selfVoice, title: "Decision Journal", description: "For each choice from obligation, rewrite through authenticity's lens.", icon: "book.closed")
    ]

    static let innatePractices: [Practice] = [
        Practice(id: "quiet_bridge", voice: .innate, title: "The Quiet Bridge", description: "7 minutes of nightly silence. No screens. Just breath entering awareness.", icon: "moon.stars"),
        Practice(id: "frequency_lock", voice: .innate, title: "Frequency Lock", description: "Ask: \"What's trying to reach me right now?\" Let first impressions come.", icon: "antenna.radiowaves.left.and.right"),
        Practice(id: "transmission_capture", voice: .innate, title: "Transmission Capture", description: "Record spontaneous thoughts as 'downloads' — images, phrases, emotion surges.", icon: "arrow.down.circle"),
        Practice(id: "acting_protocol", voice: .innate, title: "Acting Protocol", description: "Every 24 hours, act on one intuitive message, even if small.", icon: "figure.walk")
    ]

    static let allPractices: [Practice] = egoPractices + selfPractices + innatePractices
}
