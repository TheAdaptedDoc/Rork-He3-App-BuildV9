import Foundation

nonisolated enum PillarID: Int, Codable, CaseIterable, Identifiable, Sendable {
    case suppressed = 1
    case awakening = 2
    case integration = 3
    case rising = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .suppressed: "The Suppressed Man"
        case .awakening: "The Awakening"
        case .integration: "The Integrated Identity"
        case .rising: "The Rising"
        }
    }

    var shortTitle: String {
        switch self {
        case .suppressed: "Suppression"
        case .awakening: "Awakening"
        case .integration: "Integration"
        case .rising: "Rising"
        }
    }

    var week: Int { rawValue }

    var icon: String {
        switch self {
        case .suppressed: "lock.shield.fill"
        case .awakening: "flame.fill"
        case .integration: "arrow.triangle.merge"
        case .rising: "bolt.fill"
        }
    }

    var purpose: String {
        switch self {
        case .suppressed: "To confront the cost of silence and recover the foundation of emotional truth."
        case .awakening: "To transform fear, shadow, and grief into intelligence."
        case .integration: "Channel recovered energy into congruent power."
        case .rising: "Sustain evolution through freedom and mastery."
        }
    }
}
