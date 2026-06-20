import SwiftUI

struct HeroLandingView: View {
    var progress: UserProgressViewModel
    @State private var appeared = false
    @State private var showAssessment = false
    @State private var showLogin = false
    @State private var showPurchase = false
    @State private var meshPhase: CGFloat = 0
    @State private var showAccessCode = false
    @State private var showAdminPortal = false

    var body: some View {
        ZStack(alignment: .top) {
            backgroundLayer

            ScrollView {
                VStack(spacing: 0) {
                    heroSection
                    painPointsSection
                    threeVoicesSection
                    fourPillarsSection
                    transformationSection
                    ctaSection
                }
            }
            .scrollIndicators(.hidden)

            topBar
        }
        .fullScreenCover(isPresented: $showAssessment) {
            AssessmentOnboardingFlow(progress: progress)
        }
        .fullScreenCover(isPresented: $showPurchase) {
            LoginSheet(progress: progress)
        }
        .sheet(isPresented: $showLogin) {
            LoginSheet(progress: progress)
        }
        .sheet(isPresented: $showAccessCode) {
            AccessCodeSheet(
                onAdmin: { showAdminPortal = true },
                onReview: {
                    withAnimation(.easeOut(duration: 0.4)) {
                        progress.godMode = true
                    }
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showAdminPortal) {
            AdminPortalView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                meshPhase = 1
            }
        }
    }

    private var backgroundLayer: some View {
        HE3Theme.bone.ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            Spacer()

            Button {
                showLogin = true
            } label: {
                Text("SIGN IN")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.ashLight)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var heroSection: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 80)

            AnimatedLogoView(animate: true)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                // Concealed owner entry: hold the logo for 3 seconds. Nothing is
                // shown to a normal user, and it does nothing when owner preview
                // is disabled for the App Store build.
                .onLongPressGesture(minimumDuration: 3.0) {
                    guard AppConfig.ownerPreviewEnabled else { return }
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    withAnimation(.easeOut(duration: 0.4)) {
                        progress.godMode = true
                    }
                }

            Text("THE INTEGRATED MAN")
                .font(BrandFont.mono(11, weight: .medium))
                .tracking(5)
                .foregroundStyle(HE3Theme.obsidian)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)
                .animation(.easeOut(duration: 0.8).delay(0.15), value: appeared)

            SeriesMarks()
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.2), value: appeared)

            HStack(spacing: 18) {
                ForEach(Voice.allCases) { voice in
                    HStack(spacing: 7) {
                        VoiceIcon(voice: voice, size: 16)
                        Text(voice.displayName.uppercased())
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.ash)
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.8).delay(0.25), value: appeared)

            Spacer().frame(height: 16)

            VStack(spacing: 10) {
                Text("ALIGN YOUR THREE INNER VOICES")
                    .font(BrandFont.display(30))
                    .foregroundStyle(HE3Theme.obsidian)

                Text("“Built from what remained.”")
                    .font(BrandFont.quote(20))
                    .foregroundStyle(HE3Theme.crimson)
            }
            .multilineTextAlignment(.center)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 15)
            .animation(.easeOut(duration: 0.8).delay(0.3), value: appeared)

            Spacer().frame(height: 8)

            Text("You don't need to kill your ego. You need to stop letting it drive. HE\u{00B3} gets your three voices working as one instead of at war.")
                .font(BrandFont.body(18, weight: .regular))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.45), value: appeared)

            Spacer().frame(height: 24)

            Button {
                showAssessment = true
            } label: {
                Text("DISCOVER YOUR ALIGNMENT")
                    .font(BrandFont.display(20))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.bone)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(HE3Theme.obsidian)
            }
            .padding(.horizontal, 32)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.8).delay(0.6), value: appeared)
            .sensoryFeedback(.impact(weight: .medium), trigger: showAssessment)

            Text("34 questions · 3 minutes · clear signal")
                .font(BrandFont.quote(13))
                .foregroundStyle(HE3Theme.ashLight)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.65), value: appeared)

            Button {
                showPurchase = true
            } label: {
                Text("SKIP TO THE 30 DAY SPRINT →")
                    .font(BrandFont.mono(11, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(HE3Theme.crimson)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.8).delay(0.75), value: appeared)

            Spacer().frame(height: 60)
        }
        .padding(.horizontal, 20)
    }

    private var painPointsSection: some View {
        VStack(spacing: 24) {
            SectionHeader(label: "THE PROBLEM", title: "HOW MANY ARE YOU?")

            VStack(spacing: 8) {
                PainPointRow(text: "Everyone leans on you. You wouldn't know who to call at 2am.")
                PainPointRow(text: "\u{201C}I'm good\u{201D} is out of your mouth before the question even lands.")
                PainPointRow(text: "You make fast, confident calls by steamrolling the gut that already knew.")
                PainPointRow(text: "You hit the number. The hollow didn't move an inch.")
                PainPointRow(text: "You feel everything. You'd sooner bleed than show it.")
                PainPointRow(text: "You can't remember the last fully true thing you said out loud.")
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 48)
    }

    private var threeVoicesSection: some View {
        VStack(spacing: 24) {
            SectionHeader(label: "THE FRAMEWORK", title: "THREE VOICES. ONE MAN.")

            Text("Every man carries three voices that shape his identity. When they fight, you fracture. When they harmonize, you become impossible to break.")
                .font(BrandFont.body(16, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)

            VStack(spacing: 2) {
                VoiceCard(
                    voice: .ego,
                    tagline: "The Bodyguard",
                    description: "Drives achievement. Protects your worth. Left unchecked, it drowns everything else in noise."
                )
                VoiceCard(
                    voice: .selfVoice,
                    tagline: "The Witness",
                    description: "Reflects and evaluates. Builds integrity. Without direction, it spirals into analysis paralysis."
                )
                VoiceCard(
                    voice: .innate,
                    tagline: "The Receiver",
                    description: "Speaks through intuition and truth. The soul\u{2019}s signal, always broadcasting, rarely heard."
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 48)
    }

    private var fourPillarsSection: some View {
        VStack(spacing: 24) {
            SectionHeader(label: "THE SYSTEM", title: "4 PILLARS. 30 DAYS.")

            Text("A structured sprint, not a course to binge.\nOne pillar per week. Execution, not consumption.")
                .font(BrandFont.body(16, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)

            VStack(spacing: 2) {
                PillarPreviewCard(week: 1, pillar: .suppressed, accent: HE3Theme.pillarAccent(.suppressed))
                PillarPreviewCard(week: 2, pillar: .awakening, accent: HE3Theme.pillarAccent(.awakening))
                PillarPreviewCard(week: 3, pillar: .integration, accent: HE3Theme.pillarAccent(.integration))
                PillarPreviewCard(week: 4, pillar: .rising, accent: HE3Theme.pillarAccent(.rising))
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 48)
    }

    private var transformationSection: some View {
        VStack(spacing: 24) {
            SectionHeader(label: "THE RESULT", title: "THE MAN YOU BECOME")

            VStack(alignment: .leading, spacing: 16) {
                TransformRow(text: "Internal conflict replaced with integrated power")
                TransformRow(text: "Self trust rebuilt from the foundation up")
                TransformRow(text: "Relationships fueled by authenticity, not performance")
                TransformRow(text: "Discipline that runs on instinct, not willpower")
                TransformRow(text: "A masculine identity that doesn\u{2019}t need a mask")
            }
            .padding(24)
            .background(HE3Theme.iron)
            .overlay(
                Rectangle()
                    .fill(HE3Theme.crimson)
                    .frame(width: 3),
                alignment: .leading
            )
            .padding(.horizontal, 20)

            VStack(spacing: 8) {
                HStack(spacing: 24) {
                    ContainerStat(value: "30", label: "Day Sprint")
                    ContainerStat(value: "90", label: "Day Container")
                    ContainerStat(value: "4", label: "Pillars")
                }
                .padding(.horizontal, 20)

                Text("Most men finish in 30 days.\nThe men who transform start immediately.")
                    .font(BrandFont.body(14, weight: .light))
                    .foregroundStyle(HE3Theme.ash)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 48)
    }

    private var ctaSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                AnimatedLogoView(animate: false, compact: true)

                Text("He leads a mob. Holds a heart. Moves a mountain.")
                    .font(BrandFont.body(16, weight: .light))
                    .foregroundStyle(HE3Theme.crimson)
                    .multilineTextAlignment(.center)
                    .italic()

                Text("This isn\u{2019}t a course.\nIt\u{2019}s an encounter with yourself.")
                    .font(BrandFont.body(16, weight: .light))
                    .foregroundStyle(HE3Theme.ash)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                showAssessment = true
            } label: {
                Text("ENTER THE 30 DAY SPRINT")
                    .font(BrandFont.display(20))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.bone)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(HE3Theme.crimson)
            }
            .padding(.horizontal, 32)

            Text("Discover which voice runs your life\nand which ones you\u{2019}ve silenced")
                .font(BrandFont.mono(10))
                .foregroundStyle(HE3Theme.ashLight)
                .multilineTextAlignment(.center)

            Button {
                showPurchase = true
            } label: {
                Text("SKIP TO THE 30 DAY SPRINT \u{2192}")
                    .font(BrandFont.mono(11, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(HE3Theme.gold)
            }

            Button {
                showLogin = true
            } label: {
                Text("ALREADY A MEMBER? SIGN IN \u{2192}")
                    .font(BrandFont.mono(11, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(HE3Theme.ashLight)
            }

            Spacer().frame(height: 60)
        }
        .padding(.vertical, 48)
    }
}

struct HeroMeshBackground: View {
    let meshPhase: CGFloat

    private var meshPoints: [SIMD2<Float>] {
        let p = Float(meshPhase)
        return [
            SIMD2(0.0, 0.0), SIMD2(0.5, 0.0), SIMD2(1.0, 0.0),
            SIMD2(0.0, 0.25 + p * 0.03), SIMD2(0.5 + p * 0.02, 0.28), SIMD2(1.0, 0.22 + p * 0.02),
            SIMD2(0.0, 0.55), SIMD2(0.5 - p * 0.01, 0.58 + p * 0.02), SIMD2(1.0, 0.52),
            SIMD2(0.0, 1.0), SIMD2(0.5, 1.0), SIMD2(1.0, 1.0)
        ]
    }

    private var meshColors: [Color] {
        [
            Color(hex: 0x0D0A06), Color(hex: 0x100C07), Color(hex: 0x0D0A06),
            Color(hex: 0x0F0B05), Color(hex: 0x1A1308), Color(hex: 0x0F0B05),
            Color(hex: 0x0A0806), Color(hex: 0x12100A), Color(hex: 0x0A0806),
            Color(hex: 0x060504), Color(hex: 0x080604), Color(hex: 0x060504)
        ]
    }

    var body: some View {
        MeshGradient(
            width: 3, height: 4,
            points: meshPoints,
            colors: meshColors
        )
        .ignoresSafeArea()
    }
}

struct SectionHeader: View {
    let label: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(3)
                .foregroundStyle(HE3Theme.gold)

            Text(title)
                .font(BrandFont.display(30))
                .foregroundStyle(HE3Theme.textPrimary)

            Rectangle()
                .fill(HE3Theme.crimson)
                .frame(width: 40, height: 2)
                .padding(.top, 4)
        }
    }
}

struct PainPointRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(HE3Theme.gold.opacity(0.4))
                .frame(width: 2, height: 20)

            Text(text)
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)

            Spacer()
        }
        .padding(16)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }
}

struct VoiceCard: View {
    let voice: Voice
    let tagline: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(HE3Theme.voiceColor(voice))
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    VoiceIcon(voice: voice, size: 18)

                    Text(voice.displayName.uppercased())
                        .font(BrandFont.display(18))
                        .foregroundStyle(HE3Theme.textPrimary)

                    Text("\u{00B7} \(tagline)")
                        .font(BrandFont.mono(10))
                        .foregroundStyle(HE3Theme.ashLight)
                }

                Text(description)
                    .font(BrandFont.body(14, weight: .light))
                    .foregroundStyle(HE3Theme.ash)
                    .lineSpacing(3)
            }
            .padding(16)
        }
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }
}

struct PillarPreviewCard: View {
    let week: Int
    let pillar: PillarID
    let accent: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: pillar.icon)
                .font(.caption)
                .foregroundStyle(accent)
                .frame(width: 28, height: 28)
                .background(accent.opacity(0.12))

            VStack(alignment: .leading, spacing: 2) {
                Text("WEEK \(week)")
                    .font(BrandFont.mono(9, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(accent)

                Text(pillar.title.uppercased())
                    .font(BrandFont.display(15))
                    .foregroundStyle(HE3Theme.textPrimary)
            }

            Spacer()

            Text(pillar.purpose)
                .font(BrandFont.body(11, weight: .light))
                .foregroundStyle(HE3Theme.ashLight)
                .lineLimit(2)
                .frame(maxWidth: 120, alignment: .trailing)
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }
}

struct TransformRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(HE3Theme.gold)
                .frame(width: 4, height: 4)

            Text(text)
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .lineSpacing(2)
        }
    }
}

struct ContainerStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(BrandFont.display(32))
                .foregroundStyle(HE3Theme.gold)

            Text(label.uppercased())
                .font(BrandFont.mono(8, weight: .medium))
                .tracking(1)
                .foregroundStyle(HE3Theme.ash)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }
}
