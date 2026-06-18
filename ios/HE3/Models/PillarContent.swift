import Foundation

nonisolated struct PillarSection: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let body: String
    let icon: String
    let videoTitle: String
    let videoDuration: String
    let reflectionPrompts: [String]
    let exercises: [String]
}

nonisolated struct PillarContentData: Sendable {
    let pillarID: PillarID
    let videoTitle: String
    let sections: [PillarSection]
}

nonisolated enum PillarContentStore {
    static let content: [PillarID: PillarContentData] = [
        .suppressed: PillarContentData(
            pillarID: .suppressed,
            videoTitle: "The Cost of Silence",
            sections: [
                PillarSection(
                    id: "s1_cost",
                    title: "The Cost of Silence",
                    body: "We trade truth for safety until safety becomes prison. Suppression burns oxygen the spirit needs. The invoice: distance from self and others. Write the cost. Name it. Debt awareness is the first doorway to change.",
                    icon: "lock.fill",
                    videoTitle: "The Cost of Silence",
                    videoDuration: "12 MIN",
                    reflectionPrompts: [
                        "What truth have you been trading for safety?",
                        "Where in your life has silence cost you the most — relationships, health, or self-trust?"
                    ],
                    exercises: [
                        "Cost Inventory: Write the specific price you've paid for silence — in relationships, health, and self-trust."
                    ]
                ),
                PillarSection(
                    id: "s1_voices",
                    title: "The Voices Within",
                    body: "Identify which voice has dominated your decisions and which you've buried alive. Ego? Self? Innate? Journaling reveals who's running the ship — and who's locked below deck. Awareness starts the rescue.",
                    icon: "person.3.fill",
                    videoTitle: "The Voices Within",
                    videoDuration: "14 MIN",
                    reflectionPrompts: [
                        "Which voice has dominated your decisions this past year?",
                        "Which voice have you buried — and what has that cost you?"
                    ],
                    exercises: [
                        "Voice Identification: Journal about a recent decision. Which voice made it? Which voice was silenced?"
                    ]
                ),
                PillarSection(
                    id: "s1_identity",
                    title: "The Identity Built by Survival",
                    body: "Survival trained you to be admired, not free. Write what traits make you feel 'safe.' Cross off every trait built to appease others. What remains is authenticity trying to breathe again.",
                    icon: "theatermasks",
                    videoTitle: "The Identity Built by Survival",
                    videoDuration: "16 MIN",
                    reflectionPrompts: [
                        "Write three traits you perform for others that aren't authentically you.",
                        "What would your life look like if you stopped performing?"
                    ],
                    exercises: [
                        "Survival Audit: List every trait you maintain to be admired. Cross off the ones built for others. What remains?"
                    ]
                ),
                PillarSection(
                    id: "s1_mirror",
                    title: "The Mirror Exercise",
                    body: "Stare at yourself. Say aloud, 'I see the man beneath the act.' Look until discomfort becomes clarity. You are not correcting — you're remembering.",
                    icon: "person.crop.rectangle",
                    videoTitle: "The Mirror Exercise",
                    videoDuration: "10 MIN",
                    reflectionPrompts: [
                        "What did you see in the mirror that you've been avoiding?",
                        "When discomfort turned to clarity, what did clarity reveal?"
                    ],
                    exercises: [
                        "The Mirror Exercise: Stand before a mirror for 5 minutes. Say 'I see the man beneath the act.' Hold eye contact until discomfort becomes clarity."
                    ]
                )
            ]
        ),
        .awakening: PillarContentData(
            pillarID: .awakening,
            videoTitle: "The Education of the Shadow",
            sections: [
                PillarSection(
                    id: "s2_shadow",
                    title: "The Education of the Shadow",
                    body: "Shadow isn't evil; it's storage. The parts that carried pain now carry coded lessons. Fear wasn't weakness; it was courage without map. Study your own darkness like an archaeologist examining truth.",
                    icon: "moon.fill",
                    videoTitle: "The Education of the Shadow",
                    videoDuration: "15 MIN",
                    reflectionPrompts: [
                        "What shadow do you carry that's actually trying to protect you?",
                        "What lesson is coded inside the pain you've been avoiding?"
                    ],
                    exercises: [
                        "Shadow Dialogue: Write a conversation between you and your shadow. Ask what it wants to protect. Write its answer."
                    ]
                ),
                PillarSection(
                    id: "s2_abandoned",
                    title: "Recognition of the Abandoned Voices",
                    body: "Trace when you silenced yourself to fit. For every lie you told to belong, write the cost. Grieve not the lost years but the unexpressed voice. Mourning makes room for motion.",
                    icon: "waveform.path.ecg",
                    videoTitle: "Recognition of the Abandoned Voices",
                    videoDuration: "13 MIN",
                    reflectionPrompts: [
                        "When did you first learn to silence yourself to belong?",
                        "What voice have you abandoned — and what would it say if it could speak now?"
                    ],
                    exercises: [
                        "Grief Inventory: Write the unexpressed voice. What did you never say? Grieve it. Then release it."
                    ]
                ),
                PillarSection(
                    id: "s2_confrontation",
                    title: "Confrontation and Integration",
                    body: "Visualize your shadow standing across from you. Ask what it wants to protect. Listen before you speak. Maturity is empathy toward the parts that embarrassed you.",
                    icon: "person.2.fill",
                    videoTitle: "Confrontation and Integration",
                    videoDuration: "14 MIN",
                    reflectionPrompts: [
                        "If your shadow could speak, what would it say it's been protecting?",
                        "Which part of yourself have you been at war with that actually needs empathy?"
                    ],
                    exercises: [
                        "Empathy Letter: Write a letter to the part of you that embarrassed you most. Lead with empathy, end with integration."
                    ]
                ),
                PillarSection(
                    id: "s2_realization",
                    title: "The Realization",
                    body: "Fear was never an enemy. It's adrenaline before clarity. Once understood, it becomes compass, not cage.",
                    icon: "lightbulb.fill",
                    videoTitle: "The Realization",
                    videoDuration: "11 MIN",
                    reflectionPrompts: [
                        "Where has fear been pointing you toward clarity, not away from it?",
                        "What does it change when you treat fear as a compass instead of a cage?"
                    ],
                    exercises: [
                        "Fear Compass: List 3 fears active right now. For each, write what direction it's pointing you toward."
                    ]
                ),
                PillarSection(
                    id: "s2_dickens",
                    title: "The Dickens Visualization",
                    body: "See the two futures: one of suppression, one of expression. Walk down both paths. Choose the lane where your soul finally stops whispering and starts broadcasting.",
                    icon: "arrow.triangle.branch",
                    videoTitle: "The Dickens Visualization",
                    videoDuration: "17 MIN",
                    reflectionPrompts: [
                        "Describe both futures: 10 years of suppression vs. 10 years of expression.",
                        "Which version of you are you actively building today?"
                    ],
                    exercises: [
                        "The Dickens Visualization: Sit in silence for 10 minutes. Vividly imagine both futures — suppression and expression. Journal what you saw."
                    ]
                )
            ]
        ),
        .integration: PillarContentData(
            pillarID: .integration,
            videoTitle: "Channeling Recovered Energy",
            sections: [
                PillarSection(
                    id: "s3_energy",
                    title: "Channeling Recovered Energy",
                    body: "Redirect what you once used to hide. Authenticity releases biochemical energy — dopamine now rewards alignment over applause.",
                    icon: "bolt.fill",
                    videoTitle: "Channeling Recovered Energy",
                    videoDuration: "13 MIN",
                    reflectionPrompts: [
                        "Where is your energy currently being spent on hiding rather than building?",
                        "What would change if alignment — not applause — became your reward?"
                    ],
                    exercises: [
                        "Energy Audit: List where your energy goes. Categorize: hiding vs. building. Redirect one hiding expense into building."
                    ]
                ),
                PillarSection(
                    id: "s3_alignment",
                    title: "Alignment in Action",
                    body: "You live as one system: Ego protects integrity, Self organizes truth, Innate signals direction. Each decision is a new vote for harmony.",
                    icon: "arrow.triangle.merge",
                    videoTitle: "Alignment in Action",
                    videoDuration: "14 MIN",
                    reflectionPrompts: [
                        "Describe a moment this week where all three voices aligned.",
                        "Where is one voice still overriding the others?"
                    ],
                    exercises: [
                        "Alignment Check: For every major decision this week, pause and ask all three voices. Write their answers."
                    ]
                ),
                PillarSection(
                    id: "s3_embodiment",
                    title: "Embodiment of Truth",
                    body: "Behavior mirrors belief. People trust you because you no longer negotiate your authenticity.",
                    icon: "checkmark.shield.fill",
                    videoTitle: "Embodiment of Truth",
                    videoDuration: "12 MIN",
                    reflectionPrompts: [
                        "How does your behavior now mirror your deepest beliefs?",
                        "Where are you still negotiating your authenticity?"
                    ],
                    exercises: [
                        "Congruence Practice: Identify one area where your behavior doesn't match your belief. Correct it today."
                    ]
                ),
                PillarSection(
                    id: "s3_leadership",
                    title: "Creative Leadership",
                    body: "You don't perform anymore — you generate resonance. Work, love, and leadership all come from an identical place: congruence.",
                    icon: "star.fill",
                    videoTitle: "Creative Leadership",
                    videoDuration: "15 MIN",
                    reflectionPrompts: [
                        "What does creative leadership look like in your life?",
                        "Where can you stop performing and start generating resonance?"
                    ],
                    exercises: [
                        "Resonance Practice: Pick one arena (work, love, leadership). Take one action today that comes purely from congruence, not performance."
                    ]
                ),
                PillarSection(
                    id: "s3_identity",
                    title: "Identity as HE³",
                    body: "You sign your own name differently now. It represents a structure, not a story. Masculine. Whole. Integrated.",
                    icon: "person.fill.checkmark",
                    videoTitle: "Identity as HE³",
                    videoDuration: "11 MIN",
                    reflectionPrompts: [
                        "How is the man you are now structurally different from the man you were?",
                        "What does it mean to live as HE³ — Ego, Self, and Innate, integrated?"
                    ],
                    exercises: [
                        "Signature Statement: Write a one-sentence statement that signs the man you are becoming. Read it aloud each morning this week."
                    ]
                )
            ]
        ),
        .rising: PillarContentData(
            pillarID: .rising,
            videoTitle: "Embodied Freedom",
            sections: [
                PillarSection(
                    id: "s4_freedom",
                    title: "Embodied Freedom",
                    body: "Discipline turns to instinct. You live in motion without measuring worth. That is peace disguised as power.",
                    icon: "wind",
                    videoTitle: "Embodied Freedom",
                    videoDuration: "13 MIN",
                    reflectionPrompts: [
                        "Where has discipline become instinct in your life?",
                        "What does peace disguised as power feel like in your body?"
                    ],
                    exercises: [
                        "Freedom Inventory: List 5 areas where discipline has become automatic. Celebrate the integration."
                    ]
                ),
                PillarSection(
                    id: "s4_relational",
                    title: "Relational Mastery",
                    body: "Love stops being a rescue mission. Partnership becomes mutual amplification.",
                    icon: "heart.fill",
                    videoTitle: "Relational Mastery",
                    videoDuration: "14 MIN",
                    reflectionPrompts: [
                        "How has your relationship with love changed through this process?",
                        "Where is love still a rescue mission instead of mutual amplification?"
                    ],
                    exercises: [
                        "Relationship Mirror: Write how your closest relationships have shifted during this 30-day journey."
                    ]
                ),
                PillarSection(
                    id: "s4_purpose",
                    title: "Purpose in Motion",
                    body: "Purpose feels less like a plan and more like a current — you just swim aligned with flow.",
                    icon: "water.waves",
                    videoTitle: "Purpose in Motion",
                    videoDuration: "12 MIN",
                    reflectionPrompts: [
                        "What does purpose feel like now compared to when you started?",
                        "Where are you forcing a plan instead of swimming with the current?"
                    ],
                    exercises: [
                        "Current Check: Describe the current pulling you forward. Take one action today that moves with it, not against it."
                    ]
                ),
                PillarSection(
                    id: "s4_needs",
                    title: "Six Human Needs",
                    body: "Recognize how certainty, variety, significance, love, growth, and contribution now co-exist naturally without compromise.",
                    icon: "circle.hexagongrid.fill",
                    videoTitle: "Six Human Needs",
                    videoDuration: "15 MIN",
                    reflectionPrompts: [
                        "Which of the six needs (certainty, variety, significance, love, growth, contribution) is most alive in you right now?",
                        "Which one has been starved, and how will you feed it this week?"
                    ],
                    exercises: [
                        "Needs Map: Rank the six needs from most to least met in your current life. Pick one to deliberately serve this week."
                    ]
                ),
                PillarSection(
                    id: "s4_blueprint",
                    title: "The Living Blueprint",
                    body: "Write your manifesto at completion. All three voices have seats at the table. Your manifesto becomes your integrated identity.",
                    icon: "doc.text.fill",
                    videoTitle: "The Living Blueprint",
                    videoDuration: "18 MIN",
                    reflectionPrompts: [
                        "Write the opening line of your manifesto.",
                        "What do all three voices — Ego, Self, Innate — agree you must commit to going forward?"
                    ],
                    exercises: [
                        "Write Your Manifesto: This is your living blueprint. All three voices contribute. No editing. Raw truth."
                    ]
                )
            ]
        )
    ]
}
