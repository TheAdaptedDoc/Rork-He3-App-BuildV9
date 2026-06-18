import SwiftUI

// HE3 Alignment Assessment, v2. Mirrors the live assessment.html exactly:
// 34 statements in four subscales, seven reverse items, recalibrated bands,
// the deterministic five archetype decision tree, and the verbatim result copy.

nonisolated enum AssessmentSubscale: String, CaseIterable, Sendable {
    case ego = "EGO"
    case selfVoice = "SELF"
    case innate = "INNATE"
    case integration = "INTEGRATION"

    /// Integration has no single voice.
    var voice: Voice? {
        switch self {
        case .ego: .ego
        case .selfVoice: .selfVoice
        case .innate: .innate
        case .integration: nil
        }
    }

    var maxScore: Int { self == .integration ? 35 : 45 }
}

nonisolated struct AssessmentQuestion: Identifiable, Sendable {
    let id: Int
    let text: String
    let sub: AssessmentSubscale
    let reverse: Bool
}

// MARK: - Result copy

nonisolated struct ArchetypeSection: Identifiable, Sendable {
    let heading: String
    let paragraphs: [String]
    let bullets: [String]
    var id: String { heading }
}

nonisolated struct ArchetypeCopy: Sendable {
    let blurb: String
    let sections: [ArchetypeSection]
    let weeks: [String]
    let cta: String
}

nonisolated enum AssessmentProfile: String, Codable, Sendable {
    case overdrivenEgo = "overdriven_ego"
    case dividedSelf = "divided_self"
    case mutedInnate = "muted_innate"
    case fragmentedMan = "fragmented_man"
    case emergingIntegrator = "emerging_integrator"

    var title: String {
        switch self {
        case .overdrivenEgo: "The Overdriven Ego"
        case .dividedSelf: "The Divided Self"
        case .mutedInnate: "The Muted Innate"
        case .fragmentedMan: "The Fragmented Man"
        case .emergingIntegrator: "The Emerging Integrator"
        }
    }

    var icon: String {
        switch self {
        case .overdrivenEgo: "flame.fill"
        case .dividedSelf: "brain.head.profile"
        case .mutedInnate: "waveform.path"
        case .fragmentedMan: "square.stack.3d.up.slash.fill"
        case .emergingIntegrator: "arrow.triangle.merge"
        }
    }

    var accent: Color {
        switch self {
        case .overdrivenEgo, .fragmentedMan: HE3Theme.crimson
        case .dividedSelf: HE3Theme.obsidian
        case .mutedInnate, .emergingIntegrator: HE3Theme.ember
        }
    }

    var blurb: String { copy.blurb }
    var bridge: String { copy.cta }
    var copy: ArchetypeCopy { ArchetypeStore.copy[self]! }
}

nonisolated struct AssessmentScores: Codable, Sendable, Equatable {
    var ego: Int
    var selfVoice: Int
    var innate: Int
    var integration: Int

    // Backward compatible decode: older saved scores had no integration field.
    enum CodingKeys: String, CodingKey { case ego, selfVoice, innate, integration }
    init(ego: Int, selfVoice: Int, innate: Int, integration: Int) {
        self.ego = ego; self.selfVoice = selfVoice; self.innate = innate; self.integration = integration
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        ego = try c.decode(Int.self, forKey: .ego)
        selfVoice = try c.decode(Int.self, forKey: .selfVoice)
        innate = try c.decode(Int.self, forKey: .innate)
        integration = try c.decodeIfPresent(Int.self, forKey: .integration) ?? 21
    }

    /// Integration Index, measured directly (7 to 35). The headline re calibration line.
    var integrationIndex: Int { integration }

    /// Highest voice. Tie break order Ego, Self, Innate (matches the web).
    var dominantVoice: Voice {
        var best = Voice.ego
        let v: [(Voice, Int)] = [(.ego, ego), (.selfVoice, selfVoice), (.innate, innate)]
        var bestScore = ego
        for (voice, score) in v where score > bestScore { best = voice; bestScore = score }
        return best
    }

    /// Lowest voice, the Floor. Tie break order Innate, Self, Ego (matches the web).
    var suppressedVoice: Voice {
        var worst = Voice.innate
        let v: [(Voice, Int)] = [(.innate, innate), (.selfVoice, selfVoice), (.ego, ego)]
        var worstScore = innate
        for (voice, score) in v where score < worstScore { worst = voice; worstScore = score }
        return worst
    }

    var voiceSpread: Int {
        let vs = [ego, selfVoice, innate]
        return (vs.max() ?? 0) - (vs.min() ?? 0)
    }

    func voiceBand(_ score: Int) -> String {
        if score <= 20 { return "Suppressed" }
        if score <= 29 { return "Balanced" }
        if score <= 37 { return "Loud" }
        return "Dominant"
    }

    var integrationBand: String {
        if integration <= 15 { return "Fragmented" }
        if integration <= 22 { return "Partial" }
        if integration <= 29 { return "Strong" }
        return "High"
    }

    /// The deterministic five archetype chain, exactly as shipped on the web.
    var profile: AssessmentProfile {
        if integration >= 23 && voiceSpread <= 8 { return .emergingIntegrator }
        if voiceSpread >= 13 || integration <= 15 { return .fragmentedMan }
        if suppressedVoice == .innate { return .mutedInnate }
        if dominantVoice == .ego { return .overdrivenEgo }
        if dominantVoice == .selfVoice { return .dividedSelf }
        return .emergingIntegrator
    }

    func score(for voice: Voice) -> Int {
        switch voice {
        case .ego: ego
        case .selfVoice: selfVoice
        case .innate: innate
        }
    }
}

nonisolated enum AssessmentData {
    static let questions: [AssessmentQuestion] = [
        // Subscale A — Ego
        .init(id: 1, text: "I feel uneasy when I'm not progressing toward something measurable.", sub: .ego, reverse: false),
        .init(id: 2, text: "I struggle to relax without feeling like I'm falling behind.", sub: .ego, reverse: false),
        .init(id: 3, text: "When challenged, my first instinct is to defend myself.", sub: .ego, reverse: false),
        .init(id: 4, text: "I replay moments where I felt disrespected or overlooked.", sub: .ego, reverse: false),
        .init(id: 5, text: "I push through exhaustion rather than admit I need space.", sub: .ego, reverse: false),
        .init(id: 6, text: "Being perceived as weak bothers me more than I admit.", sub: .ego, reverse: false),
        .init(id: 7, text: "I measure my worth by output, results, or achievement.", sub: .ego, reverse: false),
        .init(id: 8, text: "I can rest without feeling guilty or behind.", sub: .ego, reverse: true),
        .init(id: 9, text: "I'm comfortable being seen as I am, without proving anything.", sub: .ego, reverse: true),
        // Subscale B — Self
        .init(id: 10, text: "I second guess decisions after I've already made them.", sub: .selfVoice, reverse: false),
        .init(id: 11, text: "I analyze conversations long after they're over.", sub: .selfVoice, reverse: false),
        .init(id: 12, text: "I feel split between who I am internally and who I present externally.", sub: .selfVoice, reverse: false),
        .init(id: 13, text: "I worry about how my choices affect how others see me.", sub: .selfVoice, reverse: false),
        .init(id: 14, text: "I delay action because I want more certainty first.", sub: .selfVoice, reverse: false),
        .init(id: 15, text: "I feel mentally busy even when nothing urgent is happening.", sub: .selfVoice, reverse: false),
        .init(id: 16, text: "I think about becoming \u{201C}better\u{201D} but struggle to define what that means.", sub: .selfVoice, reverse: false),
        .init(id: 17, text: "Once I decide something, I move on without revisiting it.", sub: .selfVoice, reverse: true),
        .init(id: 18, text: "I can act with incomplete information when I need to.", sub: .selfVoice, reverse: true),
        // Subscale C — Innate
        .init(id: 19, text: "I'm comfortable sitting in silence.", sub: .innate, reverse: false),
        .init(id: 20, text: "I trust my gut even when it conflicts with logic.", sub: .innate, reverse: false),
        .init(id: 21, text: "I can be still without needing to fill the space with activity.", sub: .innate, reverse: false),
        .init(id: 22, text: "I trust my first internal answer to a question.", sub: .innate, reverse: false),
        .init(id: 23, text: "I can sit with an emotion without rushing to fix or solve it.", sub: .innate, reverse: false),
        .init(id: 24, text: "I feel connected to something deeper within me.", sub: .innate, reverse: false),
        .init(id: 25, text: "I can recognize and describe what my intuition feels like.", sub: .innate, reverse: false),
        .init(id: 26, text: "I override my gut instinct when it conflicts with logic.", sub: .innate, reverse: true),
        .init(id: 27, text: "I look outward for answers before I look inward.", sub: .innate, reverse: true),
        // Subscale D — Integration
        .init(id: 28, text: "When I make a decision, it feels clean. I don't replay it afterward.", sub: .integration, reverse: false),
        .init(id: 29, text: "Who I am on the inside matches how I show up on the outside.", sub: .integration, reverse: false),
        .init(id: 30, text: "I can act on instinct and back it with reason at the same time.", sub: .integration, reverse: false),
        .init(id: 31, text: "I trust myself to handle whatever comes.", sub: .integration, reverse: false),
        .init(id: 32, text: "I feel internally settled, even when life is demanding.", sub: .integration, reverse: false),
        .init(id: 33, text: "My drive, my reflection, and my gut usually point the same direction.", sub: .integration, reverse: false),
        .init(id: 34, text: "I feel pulled in different directions inside myself.", sub: .integration, reverse: true),
    ]

    static let scaleLabels: [(Int, String)] = [
        (1, "Strongly Disagree"),
        (2, "Disagree"),
        (3, "Neutral"),
        (4, "Agree"),
        (5, "Strongly Agree"),
    ]
}
