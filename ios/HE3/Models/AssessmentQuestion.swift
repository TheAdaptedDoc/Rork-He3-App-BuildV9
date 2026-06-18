import Foundation

nonisolated struct AssessmentQuestion: Identifiable, Sendable {
    let id: Int
    let text: String
    let section: AssessmentSection
}

nonisolated enum AssessmentSection: String, CaseIterable, Sendable {
    case egoDominance = "EGO DOMINANCE"
    case selfFragmentation = "SELF FRAGMENTATION"
    case innateSuppression = "INNATE SUPPRESSION"

    var voice: Voice {
        switch self {
        case .egoDominance: .ego
        case .selfFragmentation: .selfVoice
        case .innateSuppression: .innate
        }
    }

    var icon: String {
        switch self {
        case .egoDominance: "flame.fill"
        case .selfFragmentation: "eye.fill"
        case .innateSuppression: "waveform.path"
        }
    }

    var questionRange: ClosedRange<Int> {
        switch self {
        case .egoDominance: 1...9
        case .selfFragmentation: 10...18
        case .innateSuppression: 19...27
        }
    }
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

    var description: String {
        switch self {
        case .overdrivenEgo:
            "You move. You produce. You protect.\nBut beneath that motion is tension.\nYou operate from performance more than alignment.\nYour Self voice is drowned by speed.\nYour Innate voice is drowned by noise."
        case .dividedSelf:
            "You think deeply. You reflect.\nBut you hesitate.\nYou live in analysis more than action.\nYour Ego is inconsistent.\nYour Innate is muted."
        case .mutedInnate:
            "You operate logically.\nYou move strategically.\nBut you are disconnected from instinct.\nStillness feels foreign.\nSilence feels uncomfortable."
        case .fragmentedMan:
            "Your voices compete.\nSome days Ego dominates.\nSome days Self spirals.\nInnate rarely speaks.\nInternal conflict is common."
        case .emergingIntegrator:
            "You are not fractured — but you are not fully aligned.\nYou sense more is possible."
        }
    }

    var pillarFocus: String {
        switch self {
        case .overdrivenEgo: "Pillar One + Pillar Three recalibrate you."
        case .dividedSelf: "Pillar Two + Structured Practices."
        case .mutedInnate: "Innate Practices + Integration."
        case .fragmentedMan: "Full 4-Pillar progression required."
        case .emergingIntegrator: "Full system to accelerate integration."
        }
    }

    var bridge: String {
        switch self {
        case .overdrivenEgo: "You don't need less drive. You need integration."
        case .dividedSelf: "Clarity doesn't come from more thinking. It comes from aligned execution."
        case .mutedInnate: "Your strength isn't missing. It's just quiet."
        case .fragmentedMan: "You don't need another tactic. You need internal synchronization."
        case .emergingIntegrator: "You're not broken. You're unfinished."
        }
    }
}

nonisolated struct AssessmentScores: Codable, Sendable {
    var ego: Int
    var selfVoice: Int
    var innate: Int

    var integrationIndex: Int {
        let values = [ego, selfVoice, innate]
        return (values.max() ?? 0) - (values.min() ?? 0)
    }

    func band(for score: Int) -> String {
        switch score {
        case 9...18: "Low Activity"
        case 19...27: "Moderate Activity"
        case 28...36: "High Activity"
        case 37...45: "Dominant / Imbalanced"
        default: "—"
        }
    }

    var dominantVoice: Voice {
        if ego >= selfVoice && ego >= innate { return .ego }
        if selfVoice >= ego && selfVoice >= innate { return .selfVoice }
        return .innate
    }

    var suppressedVoice: Voice {
        if ego <= selfVoice && ego <= innate { return .ego }
        if selfVoice <= ego && selfVoice <= innate { return .selfVoice }
        return .innate
    }

    var profile: AssessmentProfile {
        let maxScore = max(ego, selfVoice, innate)
        let minScore = min(ego, selfVoice, innate)
        let variance = maxScore - minScore

        if variance <= 6 && maxScore <= 27 {
            return .emergingIntegrator
        }

        if variance >= 12 {
            return .fragmentedMan
        }

        if ego == maxScore && ego >= 28 {
            return .overdrivenEgo
        }
        if selfVoice == maxScore && selfVoice >= 28 {
            return .dividedSelf
        }
        if innate == maxScore && innate >= 28 {
            return .mutedInnate
        }

        if ego == maxScore { return .overdrivenEgo }
        if selfVoice == maxScore { return .dividedSelf }
        return .mutedInnate
    }
}

nonisolated enum AssessmentData {
    static let questions: [AssessmentQuestion] = [
        AssessmentQuestion(id: 1, text: "I feel uneasy when I'm not progressing toward something measurable.", section: .egoDominance),
        AssessmentQuestion(id: 2, text: "I struggle to relax without feeling like I'm falling behind.", section: .egoDominance),
        AssessmentQuestion(id: 3, text: "When challenged, my first instinct is to defend myself.", section: .egoDominance),
        AssessmentQuestion(id: 4, text: "I replay moments where I felt disrespected or overlooked.", section: .egoDominance),
        AssessmentQuestion(id: 5, text: "I push through physical or emotional exhaustion rather than admit I need space.", section: .egoDominance),
        AssessmentQuestion(id: 6, text: "Being perceived as weak bothers me more than I admit.", section: .egoDominance),
        AssessmentQuestion(id: 7, text: "I often take responsibility for fixing situations even when no one asked me to.", section: .egoDominance),
        AssessmentQuestion(id: 8, text: "I measure my worth by output, results, or achievement.", section: .egoDominance),
        AssessmentQuestion(id: 9, text: "Slowing down feels threatening.", section: .egoDominance),

        AssessmentQuestion(id: 10, text: "I second-guess decisions after I've already made them.", section: .selfFragmentation),
        AssessmentQuestion(id: 11, text: "I analyze conversations long after they're over.", section: .selfFragmentation),
        AssessmentQuestion(id: 12, text: "I feel split between who I am internally and who I present externally.", section: .selfFragmentation),
        AssessmentQuestion(id: 13, text: "I worry about how my choices affect how others see me.", section: .selfFragmentation),
        AssessmentQuestion(id: 14, text: "I struggle to clearly define what I truly want.", section: .selfFragmentation),
        AssessmentQuestion(id: 15, text: "I feel responsible for maintaining emotional balance in my relationships.", section: .selfFragmentation),
        AssessmentQuestion(id: 16, text: "I delay action because I want more certainty first.", section: .selfFragmentation),
        AssessmentQuestion(id: 17, text: "I often think about becoming \"better\" but struggle to define what that means.", section: .selfFragmentation),
        AssessmentQuestion(id: 18, text: "I feel mentally busy even when nothing urgent is happening.", section: .selfFragmentation),

        AssessmentQuestion(id: 19, text: "Silence makes me uncomfortable.", section: .innateSuppression),
        AssessmentQuestion(id: 20, text: "I override my gut instinct when it conflicts with logic.", section: .innateSuppression),
        AssessmentQuestion(id: 21, text: "I avoid stillness by staying busy.", section: .innateSuppression),
        AssessmentQuestion(id: 22, text: "I struggle to trust my first internal answer to a question.", section: .innateSuppression),
        AssessmentQuestion(id: 23, text: "I rarely sit with emotion without trying to fix or solve it.", section: .innateSuppression),
        AssessmentQuestion(id: 24, text: "I feel disconnected from something deeper within me.", section: .innateSuppression),
        AssessmentQuestion(id: 25, text: "I distract myself quickly when uncomfortable feelings surface.", section: .innateSuppression),
        AssessmentQuestion(id: 26, text: "I find it difficult to describe what my intuition feels like.", section: .innateSuppression),
        AssessmentQuestion(id: 27, text: "I often look outward for answers before looking inward.", section: .innateSuppression),
    ]

    static let scaleLabels: [(Int, String)] = [
        (1, "Strongly Disagree"),
        (2, "Disagree"),
        (3, "Neutral"),
        (4, "Agree"),
        (5, "Strongly Agree"),
    ]
}
