import Foundation

nonisolated enum Voice: String, Codable, CaseIterable, Identifiable, Sendable {
    case ego = "Ego"
    case selfVoice = "Self"
    case innate = "Innate"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .ego: "flame.fill"
        case .selfVoice: "eye.fill"
        case .innate: "waveform.path"
        }
    }

    var subtitle: String {
        switch self {
        case .ego: "The Bodyguard"
        case .selfVoice: "The Witness"
        case .innate: "The Receiver"
        }
    }

    var description: String {
        switch self {
        case .ego: "Aggressive, protective, obsessed with proving worth. It drives achievement but, left unchecked, becomes noise."
        case .selfVoice: "Reflective, aware, disciplined. It evaluates choices and builds integrity."
        case .innate: "Quiet, instinctual, deeply spiritual. It speaks through intuition and truth."
        }
    }

    var role: String {
        switch self {
        case .ego: "Ego drives."
        case .selfVoice: "Self directs."
        case .innate: "Innate guides."
        }
    }
}
