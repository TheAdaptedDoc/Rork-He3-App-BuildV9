import Foundation

/// One sitting of The Council: each voice speaks, then the integrated read.
nonisolated struct CouncilReflection: Codable, Sendable {
    let ego: String
    let selfVoice: String
    let innate: String
    let synthesis: String

    enum CodingKeys: String, CodingKey {
        case ego
        case selfVoice = "self"
        case innate
        case synthesis
    }

    func line(for voice: Voice) -> String {
        switch voice {
        case .ego: ego
        case .selfVoice: selfVoice
        case .innate: innate
        }
    }
}
