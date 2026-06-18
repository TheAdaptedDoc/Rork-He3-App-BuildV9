import SwiftUI

struct SettingsView: View {
    var progress: UserProgressViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        profileSection
                        voiceProfileSection
                        programSection
                        aboutSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationDestination(for: AboutDestination.self) { destination in
                AboutDetailView(destination: destination)
            }
        }
    }

    private var profileSection: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(HE3Theme.gold)
                .frame(width: 3)

            HStack(spacing: 16) {
                AnimatedLogoView(animate: false, compact: true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("INTEGRATED MAN")
                        .font(BrandFont.display(20))
                        .foregroundStyle(HE3Theme.textPrimary)

                    if let start = progress.programStartDate {
                        Text("STARTED \(start, style: .date)")
                            .font(BrandFont.mono(10))
                            .foregroundStyle(HE3Theme.bone.opacity(0.5))
                    }
                }

                Spacer()
            }
            .padding(18)
        }
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }

    private var voiceProfileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ALIGNMENT PROFILE")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))

            if let profile = progress.assessmentProfile {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: profile.icon)
                            .font(.caption)
                            .foregroundStyle(HE3Theme.gold)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.title.uppercased())
                                .font(BrandFont.display(16))
                                .foregroundStyle(HE3Theme.textPrimary)

                            Text(profile.bridge)
                                .font(BrandFont.body(13, weight: .light))
                                .foregroundStyle(HE3Theme.gold)
                                .italic()
                        }
                    }

                    if let scores = progress.assessmentScores {
                        Rectangle()
                            .fill(HE3Theme.steel)
                            .frame(height: 1)

                        HStack(spacing: 0) {
                            ScoreMini(voice: .ego, score: scores.ego, isDominant: scores.dominantVoice == .ego)
                            ScoreMini(voice: .selfVoice, score: scores.selfVoice, isDominant: scores.dominantVoice == .selfVoice)
                            ScoreMini(voice: .innate, score: scores.innate, isDominant: scores.dominantVoice == .innate)
                        }
                    }
                }
                .padding(16)
                .background(HE3Theme.iron)
                .clipShape(.rect(cornerRadius: 0))
            } else if let dominant = progress.dominantVoice, let suppressed = progress.suppressedVoice {
                HStack(spacing: 8) {
                    VoiceBadge(label: "Dominant", voice: dominant)
                    VoiceBadge(label: "Suppressed", voice: suppressed)
                }
            }
        }
    }

    private var programSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PROGRAM")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))

            VStack(spacing: 0) {
                SettingsRow(icon: "clock", title: "Days Remaining", value: "\(progress.daysRemaining)")
                Rectangle().fill(HE3Theme.steel).frame(height: 1)
                SettingsRow(icon: "flame.fill", title: "Current Streak", value: "\(progress.currentStreak) days")
                Rectangle().fill(HE3Theme.steel).frame(height: 1)
                SettingsRow(icon: "chart.bar.fill", title: "Progress", value: "\(Int(progress.overallProgress * 100))%")
            }
            .background(HE3Theme.iron)
            .clipShape(.rect(cornerRadius: 0))
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ABOUT")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))

            VStack(spacing: 0) {
                NavigationLink(value: AboutDestination.about) {
                    SettingsLinkRow(icon: "info.circle", title: "About HE\u{00B3}")
                }
                .buttonStyle(.plain)
                Rectangle().fill(HE3Theme.steel).frame(height: 1)
                NavigationLink(value: AboutDestination.contact) {
                    SettingsLinkRow(icon: "envelope", title: "Contact Support")
                }
                .buttonStyle(.plain)
                Rectangle().fill(HE3Theme.steel).frame(height: 1)
                NavigationLink(value: AboutDestination.terms) {
                    SettingsLinkRow(icon: "doc.text", title: "Terms of Service")
                }
                .buttonStyle(.plain)
                Rectangle().fill(HE3Theme.steel).frame(height: 1)
                NavigationLink(value: AboutDestination.privacy) {
                    SettingsLinkRow(icon: "hand.raised", title: "Privacy Policy")
                }
                .buttonStyle(.plain)
            }
            .background(HE3Theme.iron)
            .clipShape(.rect(cornerRadius: 0))

            Text("HE\u{00B3} \u{00B7} THE INTEGRATED MAN SYSTEM\nV1.0")
                .font(BrandFont.mono(10))
                .foregroundStyle(HE3Theme.bone.opacity(0.4))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
}

struct VoiceBadge: View {
    let label: String
    let voice: Voice

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: voice.icon)
                .font(.caption)
                .foregroundStyle(HE3Theme.voiceColor(voice))

            Text(voice.displayName.uppercased())
                .font(BrandFont.display(16))
                .foregroundStyle(HE3Theme.textPrimary)

            Text(label.uppercased())
                .font(BrandFont.mono(8, weight: .medium))
                .tracking(1)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(HE3Theme.gold)
                .frame(width: 24)

            Text(title)
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)

            Spacer()

            Text(value)
                .font(BrandFont.mono(13, weight: .medium))
                .foregroundStyle(HE3Theme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct SettingsLinkRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(HE3Theme.gold)
                .frame(width: 24)

            Text(title)
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)

            Spacer()

            Text("\u{2192}")
                .font(BrandFont.mono(14))
                .foregroundStyle(HE3Theme.ashLight.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

enum AboutDestination: Hashable {
    case about, contact, terms, privacy

    var title: String {
        switch self {
        case .about: return "About HE\u{00B3}"
        case .contact: return "Contact Support"
        case .terms: return "Terms of Service"
        case .privacy: return "Privacy Policy"
        }
    }

    var icon: String {
        switch self {
        case .about: return "info.circle"
        case .contact: return "envelope"
        case .terms: return "doc.text"
        case .privacy: return "hand.raised"
        }
    }
}

struct AboutDetailView: View {
    let destination: AboutDestination

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: destination.icon)
                            .font(.title3)
                            .foregroundStyle(HE3Theme.gold)
                        Text(destination.title.uppercased())
                            .font(BrandFont.display(22))
                            .foregroundStyle(HE3Theme.textPrimary)
                    }

                    Rectangle()
                        .fill(HE3Theme.gold)
                        .frame(width: 40, height: 2)

                    content
                        .font(BrandFont.body(15, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .lineSpacing(6)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(destination.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
    }

    @ViewBuilder
    private var content: some View {
        switch destination {
        case .about:
            VStack(alignment: .leading, spacing: 16) {
                Text("HE\u{00B3} \u{2014} The Integrated Man System is a 90-day program designed to guide men through the integration of their three core voices: Ego, Self, and Innate.")
                Text("Built on the principle that suppression breeds suffering, HE\u{00B3} provides a structured path through four pillars \u{2014} Suppressed Man, Awakening, Integration, and Rising \u{2014} unlocking one phase at a time to prevent binge consumption and force embodiment.")
                Text("This is not motivation. This is reconstruction.")
                    .italic()
                    .foregroundStyle(HE3Theme.gold)
                Text("Version 1.0")
                    .font(BrandFont.mono(11))
                    .foregroundStyle(HE3Theme.bone.opacity(0.5))
                    .padding(.top, 12)
            }
        case .contact:
            VStack(alignment: .leading, spacing: 16) {
                Text("Need help with your account, purchase, or program access? Reach out and we\u{2019}ll respond within 48 hours.")
                infoCard(label: "EMAIL", value: "support@he3system.com")
                infoCard(label: "RESPONSE TIME", value: "Within 48 hours")
                Text("For technical issues, please include your account email and a description of the problem.")
                    .foregroundStyle(HE3Theme.bone.opacity(0.7))
            }
        case .terms:
            VStack(alignment: .leading, spacing: 16) {
                sectionTitle("1. Acceptance of Terms")
                Text("By accessing or using HE\u{00B3}, you agree to be bound by these Terms of Service. If you do not agree, do not use the app.")
                sectionTitle("2. The Program")
                Text("HE\u{00B3} provides educational personal growth content. It is not a substitute for medical, psychological, or professional advice.")
                sectionTitle("3. Purchases")
                Text("The $297 program is a one time purchase that grants 90 days of access, with the work built to be completed in the first 30. Payment is processed securely on the web by Stripe. The app never processes payment. Refunds, if any, follow the policy shown at checkout.")
                sectionTitle("4. User Conduct")
                Text("You agree to use HE\u{00B3} for personal growth and not to redistribute, resell, or reproduce the content.")
                sectionTitle("5. Limitation of Liability")
                Text("HE\u{00B3} and its creators are not liable for any outcomes resulting from your use of the program. Your transformation is your responsibility.")
                sectionTitle("6. Changes")
                Text("We may update these terms at any time. Continued use constitutes acceptance.")
            }
        case .privacy:
            VStack(alignment: .leading, spacing: 16) {
                sectionTitle("What We Collect")
                Text("Account email, program progress, journal entries, and assessment results. Night Practice videos are stored locally on your device only.")
                sectionTitle("How We Use It")
                Text("To deliver the program, sync progress across your devices, and improve the experience. We never sell your data.")
                sectionTitle("Storage")
                Text("Account data is stored securely with our authentication provider. Journal entries and progress sync to your account.")
                sectionTitle("Your Rights")
                Text("You may request deletion of your account and all associated data at any time by contacting support@he3system.com.")
                sectionTitle("Third Parties")
                Text("We use Stripe for web checkout, Supabase for authentication and data storage, and Mux for lesson video delivery. No advertising trackers.")
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(BrandFont.mono(11, weight: .medium))
            .tracking(2)
            .foregroundStyle(HE3Theme.gold)
            .padding(.top, 4)
    }

    private func infoCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))
            Text(value)
                .font(BrandFont.body(16))
                .foregroundStyle(HE3Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }
}

struct ScoreMini: View {
    let voice: Voice
    let score: Int
    let isDominant: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: voice.icon)
                .font(.caption2)
                .foregroundStyle(isDominant ? HE3Theme.voiceColor(voice) : HE3Theme.bone.opacity(0.4))

            Text("\(score)")
                .font(BrandFont.display(22))
                .foregroundStyle(isDominant ? HE3Theme.voiceColor(voice) : HE3Theme.textPrimary)

            Text(voice.displayName.uppercased())
                .font(BrandFont.mono(8, weight: .medium))
                .tracking(1)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}
