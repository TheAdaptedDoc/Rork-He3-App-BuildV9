import Foundation

// Verbatim result copy from the live assessment.html. Already hyphen free.
nonisolated enum ArchetypeStore {
    static let copy: [AssessmentProfile: ArchetypeCopy] = [
        .overdrivenEgo: ArchetypeCopy(
            blurb: "Your Ego runs the system alone. Drive without direction. From the outside you look strong; from the inside you're tired. Your Self got drowned out by urgency and your Innate buried under noise. You don't need less ambition or to soften. You need integration. Because drive without calibration is just a slower road to burnout.",
            sections: [
                ArchetypeSection(heading: "The pattern", paragraphs: [
                    "You move fast. You execute. You produce. You protect. You take responsibility. You don't wait for permission.",
                    "From the outside, you look strong. From the inside, you're tired. You operate from drive more than direction, you measure worth in output, and you rarely slow down long enough to hear what's underneath the motion.",
                    "When challenged, you defend. When exhausted, you push. When uncertain, you accelerate. You don't collapse. You override. That has worked. Until now."
                ], bullets: []),
                ArchetypeSection(heading: "What it's costing you", paragraphs: [
                    "You're not broken. But you are imbalanced. Your Ego has been running the system alone. Your Self, the voice that calibrates integrity, got drowned out by urgency. Your Innate, the quiet internal signal, buried under noise.",
                    "The cost is subtle at first. Tension in the body, restlessness in silence, difficulty feeling present. Over time it deepens: disconnection, emotional distance, exhaustion masked as discipline. You've learned to survive. You haven't synchronized."
                ], bullets: ["Achievement replaces alignment", "Control replaces clarity", "Performance replaces peace", "Motion replaces meaning"]),
                ArchetypeSection(heading: "Why you're like this", paragraphs: [
                    "This pattern isn't weakness. It's protection. At some point, moving forward became safer than sitting still. Proving became safer than trusting. Control became safer than listening. You built strength. But strength without integration becomes strain."
                ], bullets: []),
                ArchetypeSection(heading: "The truth most men won't admit", paragraphs: [
                    "You don't need less ambition. You don't need to soften. You don't need to abandon your edge. You need integration. Because drive without calibration leads to burnout. And burnout doesn't feel like failure. It feels like slow erosion."
                ], bullets: []),
                ArchetypeSection(heading: "What changes when you integrate", paragraphs: [
                    "When Ego, Self, and Innate align: drive becomes disciplined power, stillness becomes strategic, silence becomes signal, action becomes intentional. You stop running from discomfort. You start leading from clarity. You don't lose intensity. You gain control over it."
                ], bullets: [])
            ],
            weeks: ["Week 1 recalibrates suppression.", "Week 2 confronts shadow.", "Week 3 synchronizes identity.", "Week 4 stabilizes integration."],
            cta: "Align your voices. Reclaim your direction. Lead from integration."
        ),
        .dividedSelf: ArchetypeCopy(
            blurb: "Your Self is the loud one. You think, analyze, replay, rethink. From the outside you look thoughtful; from the inside you feel split. Your instinct went quiet and your drive turned inconsistent, so clarity never lands. You won't think your way to certainty; it's built through aligned action. You don't need more analysis. You need synchronization.",
            sections: [
                ArchetypeSection(heading: "The pattern", paragraphs: [
                    "You think deeply. You analyze. You reflect. You question. You consider consequences.",
                    "From the outside, you appear thoughtful. From the inside, you feel split. You replay conversations, rethink decisions, ask yourself if you handled things right, worry about being misunderstood.",
                    "When faced with action, you hesitate. When clarity is required, you overprocess. When instinct whispers, you ask for more data. You don't lack intelligence. You lack internal alignment. And that tension drains you."
                ], bullets: []),
                ArchetypeSection(heading: "What it's costing you", paragraphs: [
                    "You're not weak. You're fragmented. Your Self voice is loud, but your Ego lacks consistency, and your Innate has been muted.",
                    "The cost shows up quietly: mental exhaustion, chronic doubt, delayed action, identity confusion. You want to move. But you don't fully trust yourself. And without trust in yourself, momentum dies."
                ], bullets: ["Reflection becomes rumination", "Growth becomes self attack", "Awareness becomes paralysis", "Responsibility becomes guilt"]),
                ArchetypeSection(heading: "Why you're like this", paragraphs: [
                    "At some point, being careful felt safer than being decisive. Being thoughtful felt safer than being bold. Analyzing felt safer than acting. So you sharpened your mind. But you dulled your instinct, and your Ego, the part that drives execution, became inconsistent. You don't need more thinking. You need synchronization."
                ], bullets: []),
                ArchetypeSection(heading: "The truth most men avoid", paragraphs: [
                    "Clarity does not come from more analysis. It comes from aligned action. You will never think your way into certainty. Certainty is built through disciplined execution. Right now, you're intelligent but divided. And division is exhausting."
                ], bullets: []),
                ArchetypeSection(heading: "What changes when you integrate", paragraphs: [
                    "When Ego, Self, and Innate align: thought becomes strategy, instinct becomes trusted, action becomes clean. You decide and move. You reflect and release. You act without replaying. You don't lose depth. You gain momentum."
                ], bullets: [])
            ],
            weeks: ["Week 1 identifies suppression.", "Week 2 confronts internal fragmentation.", "Week 3 rebuilds unified identity.", "Week 4 stabilizes execution."],
            cta: "Stop analyzing. Start aligning. Move with clarity."
        ),
        .mutedInnate: ArchetypeCopy(
            blurb: "You run on logic. You solve, plan, assess. From the outside you look composed. Inside, something feels distant. Your Innate is your internal compass. It has been suppressed. So achievement lacks meaning and stillness feels like a threat. Strength without instinct is brittle. You don't need more control. You need reconnection.",
            sections: [
                ArchetypeSection(heading: "The pattern", paragraphs: [
                    "You operate logically. You solve. You plan. You think ahead. You assess risk.",
                    "From the outside, you appear composed. From the inside, something feels distant. Silence feels uncomfortable, stillness feels inefficient, emotion feels inconvenient.",
                    "You trust logic but distrust instinct. You move strategically but rarely feel internally settled. You're functional. But not fully connected."
                ], bullets: []),
                ArchetypeSection(heading: "What it's costing you", paragraphs: [
                    "You're not broken. You're disconnected. Your Ego may function and your Self may analyze, but your Innate, your internal compass, has been suppressed.",
                    "The cost becomes a subtle numbness. You're productive, but not fully present. Capable, but not fully aligned. And alignment can't be forced through logic alone."
                ], bullets: ["Decisions lack depth", "Achievement lacks meaning", "Silence feels threatening", "Intuition feels unreliable"]),
                ArchetypeSection(heading: "Why you're like this", paragraphs: [
                    "At some point, feeling deeply became unsafe. Stillness became uncomfortable. Trusting instinct felt risky. So you relied on reason. You built intelligence but lost intimacy with yourself. That disconnection doesn't make you weak. It makes you incomplete."
                ], bullets: []),
                ArchetypeSection(heading: "The truth most men miss", paragraphs: [
                    "Strength without intuition is brittle. Strategy without instinct is mechanical. Logic without inner signal leads to slow drift. You don't need more control. You need reconnection."
                ], bullets: []),
                ArchetypeSection(heading: "What changes when you integrate", paragraphs: [
                    "When Ego, Self, and Innate align: silence becomes clarity, stillness becomes power, emotion becomes intelligence, instinct becomes authority. You don't lose logic. You gain depth. You don't lose structure. You gain signal."
                ], bullets: [])
            ],
            weeks: ["Week 1 exposes suppression.", "Week 2 restores emotional awareness.", "Week 3 aligns internal voices.", "Week 4 stabilizes instinctual authority."],
            cta: "Reconnect. Realign. Lead from signal."
        ),
        .fragmentedMan: ArchetypeCopy(
            blurb: "Your voices compete with no consistent center. Driven one day, overthinking the next, numb the next. There's real strength in you, but no synchronization, so you start strong, lose steam, question yourself, and restart. That loop isn't incapacity. It's a system out of sync. You don't need another tactic. You need alignment, where effort compounds instead of leaks.",
            sections: [
                ArchetypeSection(heading: "The pattern", paragraphs: [
                    "Your voices compete. Some days Ego dominates. Some days Self spirals. Some days you feel disconnected entirely.",
                    "Your internal state fluctuates. Driven one day, overthinking the next, numb the next. There's strength in you, but no consistent center.",
                    "You don't lack potential. You lack synchronization. And that internal conflict is exhausting."
                ], bullets: []),
                ArchetypeSection(heading: "What it's costing you", paragraphs: [
                    "Fragmentation creates instability. When voices compete:",
                    "You start strong. You lose steam. You question yourself. You restart. This loop drains confidence and, over time, erodes belief. Not because you're incapable, but because your system is unsynchronized."
                ], bullets: ["Decisions feel inconsistent", "Discipline feels temporary", "Motivation fluctuates", "Identity feels unclear"]),
                ArchetypeSection(heading: "Why you're like this", paragraphs: [
                    "You adapted to survive different environments. You became whoever was required in the moment. Strong when needed, careful when needed, detached when needed. That flexibility kept you alive, but it fractured internal unity. Now, instead of choosing who you are, you react to circumstances. That's not weakness. It's fragmentation."
                ], bullets: []),
                ArchetypeSection(heading: "The truth most men avoid", paragraphs: [
                    "You don't need another tactic. You don't need another motivational burst. You need internal synchronization. Without alignment, effort leaks. With alignment, effort compounds."
                ], bullets: []),
                ArchetypeSection(heading: "What changes when you integrate", paragraphs: [
                    "When Ego, Self, and Innate align: consistency replaces fluctuation, discipline replaces bursts, identity replaces reaction, direction replaces chaos. You become stable. Not rigid. Stable. And stability builds power."
                ], bullets: [])
            ],
            weeks: ["Week 1 stabilizes foundation.", "Week 2 confronts internal conflict.", "Week 3 rebuilds unified identity.", "Week 4 locks in integration."],
            cta: "Synchronize. Stabilize. Lead from unity."
        ),
        .emergingIntegrator: ArchetypeCopy(
            blurb: "You're not fractured and not run by one voice. But you're not fully aligned either. You feel stable, but not optimized; you move, but you know there's another level. You're not broken. You're unfinished. Potential without structure stays potential. You don't need repair, you need acceleration.",
            sections: [
                ArchetypeSection(heading: "The pattern", paragraphs: [
                    "You're not fractured. You're not dominated by one voice. But you're not fully aligned either.",
                    "You sense more is possible. You feel stable, but not optimized. You move, but you know there's another level. There's strength. But there's untapped depth.",
                    "You're not broken. You're unfinished."
                ], bullets: []),
                ArchetypeSection(heading: "What it's costing you", paragraphs: [
                    "Moderate imbalance is subtle. You function well. But you plateau. When integration is partial:",
                    "You don't collapse. But you don't ascend either. And you know it."
                ], bullets: ["Growth slows", "Clarity dulls", "Discipline fluctuates", "Instinct hesitates"]),
                ArchetypeSection(heading: "Why you're like this", paragraphs: [
                    "You've done work. You've reflected. You've grown. You've built strength. But integration requires deliberate structure. Without system, growth drifts. Without container, evolution stalls."
                ], bullets: []),
                ArchetypeSection(heading: "The truth", paragraphs: [
                    "Potential without structure remains potential. Integration without reinforcement fades. You don't need repair. You need acceleration."
                ], bullets: []),
                ArchetypeSection(heading: "What changes when you integrate", paragraphs: [
                    "When Ego, Self, and Innate fully align: you operate clean, you move decisively, you trust instinct, you lead without tension. You don't search for certainty. You embody it."
                ], bullets: [])
            ],
            weeks: ["Week 1 clarifies foundation.", "Week 2 sharpens awareness.", "Week 3 locks alignment.", "Week 4 elevates execution."],
            cta: "Refine. Elevate. Lead from integration."
        )
    ]
}
