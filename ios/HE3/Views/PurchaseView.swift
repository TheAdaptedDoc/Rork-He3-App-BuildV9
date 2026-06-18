import SwiftUI

struct PurchaseView: View {
    var progress: UserProgressViewModel
    var onPurchaseComplete: () -> Void
    @State private var appeared = false
    @State private var agreedToTerms = false
    @State private var showTerms = false
    @State private var isPurchasing = false
    @State private var showPaymentSheet = false

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 24)

                    headerSection

                    profileBadge

                    containerPhilosophy

                    systemStructure

                    includedSection

                    pricingCard

                    termsToggle

                    purchaseButton

                    guaranteeNote

                    Spacer().frame(height: 60)
                }
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showTerms) {
            TermsSheet()
        }
        .sheet(isPresented: $showPaymentSheet) {
            PaymentMethodView(progress: progress, onPurchaseComplete: {
                showPaymentSheet = false
                onPurchaseComplete()
            })
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            Text("HE\u{00B3}")
                .font(BrandFont.display(52))
                .foregroundStyle(HE3Theme.goldGradient)

            Text("THE INTEGRATED MAN SYSTEM")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(4)
                .foregroundStyle(HE3Theme.bone.opacity(0.6))

            Text("A Proven 4-Pillar Method to Align Your\nThree Inner Voices — and Reclaim\nYour Masculine Identity")
                .font(BrandFont.body(16, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 4)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .padding(.horizontal, 24)
    }

    private var profileBadge: some View {
        Group {
            if let profile = progress.assessmentProfile {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(HE3Theme.gold)
                        .frame(width: 3)

                    HStack(spacing: 14) {
                        Image(systemName: profile.icon)
                            .font(.caption)
                            .foregroundStyle(HE3Theme.gold)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("YOUR PROFILE")
                                .font(BrandFont.mono(8, weight: .medium))
                                .tracking(2)
                                .foregroundStyle(HE3Theme.bone.opacity(0.5))

                            Text(profile.title.uppercased())
                                .font(BrandFont.display(16))
                                .foregroundStyle(HE3Theme.textPrimary)
                        }

                        Spacer()

                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(HE3Theme.gold)
                    }
                    .padding(16)
                }
                .background(HE3Theme.iron)
                .clipShape(.rect(cornerRadius: 0))
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
            }
        }
    }

    private var containerPhilosophy: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("THE CONTAINER")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.gold)

            Text("This is not lifetime content.")
                .font(BrandFont.body(16, weight: .semiBold))
                .foregroundStyle(HE3Theme.textPrimary)

            VStack(alignment: .leading, spacing: 10) {
                ContainerDetail(label: "Access Window", value: "90 Days")
                ContainerDetail(label: "Designed Completion", value: "30 Days")
                ContainerDetail(label: "Integration Phase", value: "Days 30–90")
            }

            Text("Because transformation requires commitment.\nDiscipline doesn't yell. It tracks.")
                .font(BrandFont.body(13, weight: .light))
                .foregroundStyle(HE3Theme.bone.opacity(0.5))
                .lineSpacing(3)
                .italic()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
    }

    private var systemStructure: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("4-PILLAR STRUCTURE")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.gold)

            VStack(spacing: 12) {
                ModuleRow(week: 1, title: "The Suppressed Man", icon: "lock.shield.fill")
                ModuleRow(week: 2, title: "The Awakening", icon: "flame.fill")
                ModuleRow(week: 3, title: "Integration", icon: "arrow.triangle.merge")
                ModuleRow(week: 4, title: "The Rising", icon: "bolt.fill")
            }

            Rectangle()
                .fill(HE3Theme.steel)
                .frame(height: 1)
                .padding(.vertical, 4)

            Text("EACH MODULE CONTAINS")
                .font(BrandFont.mono(9, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))

            VStack(alignment: .leading, spacing: 8) {
                ModuleFeature(text: "Core video lesson (10–20 min)")
                ModuleFeature(text: "AI-supported reflection prompt")
                ModuleFeature(text: "Written exercise")
                ModuleFeature(text: "Identity calibration assignment")
                ModuleFeature(text: "Action directive")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.25), value: appeared)
    }

    private var includedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("INCLUDED")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.gold)

            VStack(alignment: .leading, spacing: 10) {
                IncludedItem(text: "HE\u{00B3} 3-Voices Assessment")
                IncludedItem(text: "Full 4-Pillar System (30-Day Sprint)")
                IncludedItem(text: "Daily Practices & Accountability Tools")
                IncludedItem(text: "Night Practice (Courage Ritual)")
                IncludedItem(text: "Digital HE\u{00B3} Manifesto Template")
                IncludedItem(text: "Completion Certificate")
                IncludedItem(text: "Night Practice Accountability Template")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.35), value: appeared)
    }

    private var pricingCard: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(HE3Theme.gold)
                .frame(height: 2)

            VStack(spacing: 4) {
                Text("ONE-TIME INVESTMENT")
                    .font(BrandFont.mono(9, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.bone.opacity(0.5))

                Text("$297")
                    .font(BrandFont.display(60))
                    .foregroundStyle(HE3Theme.gold)

                Text("90-DAY ACCESS \u{00B7} 30-DAY SPRINT")
                    .font(BrandFont.mono(11))
                    .foregroundStyle(HE3Theme.bone.opacity(0.6))
            }

            Rectangle()
                .fill(HE3Theme.steel)
                .frame(height: 1)

            VStack(spacing: 8) {
                Text("This is not content-based masculine education.")
                    .font(BrandFont.body(13, weight: .light))
                    .foregroundStyle(HE3Theme.ash)

                Text("This is discipline-based masculine transformation.")
                    .font(BrandFont.body(13, weight: .bold))
                    .foregroundStyle(HE3Theme.gold)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
        .overlay(
            Rectangle()
                .fill(HE3Theme.gold)
                .frame(height: 2),
            alignment: .top
        )
        .clipShape(.rect(cornerRadius: 0))
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.45), value: appeared)
    }

    private var termsToggle: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                agreedToTerms.toggle()
            } label: {
                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(agreedToTerms ? HE3Theme.gold : HE3Theme.bone.opacity(0.4))
            }
            .sensoryFeedback(.selection, trigger: agreedToTerms)

            VStack(alignment: .leading, spacing: 4) {
                Text("I agree to the ")
                    .font(BrandFont.body(13, weight: .light))
                    .foregroundStyle(HE3Theme.ash)
                +
                Text("Terms & Conditions")
                    .font(BrandFont.body(13, weight: .semiBold))
                    .foregroundStyle(HE3Theme.gold)

                Text("Including the 90-day access window, no-refund policy, and program structure.")
                    .font(BrandFont.mono(10))
                    .foregroundStyle(HE3Theme.bone.opacity(0.4))
                    .lineSpacing(2)
            }
            .onTapGesture {
                showTerms = true
            }
        }
        .padding(.horizontal, 28)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)
    }

    private var purchaseButton: some View {
        Button {
            guard agreedToTerms else { return }
            showPaymentSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                Text("PURCHASE — $297 \u{2192}")
                    .font(BrandFont.mono(13, weight: .medium))
                    .tracking(1)
            }
            .foregroundStyle(HE3Theme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(agreedToTerms ? HE3Theme.gold : HE3Theme.bone.opacity(0.15))
            .clipShape(.rect(cornerRadius: 0))
        }
        .disabled(!agreedToTerms)
        .padding(.horizontal, 24)
        .sensoryFeedback(.impact(weight: .medium), trigger: showPaymentSheet)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.55), value: appeared)
    }

    private var guaranteeNote: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.caption2)
                Text("SECURE PAYMENT \u{00B7} ENCRYPTED CHECKOUT")
                    .font(BrandFont.mono(9))
            }
            .foregroundStyle(HE3Theme.bone.opacity(0.4))

            HStack(spacing: 16) {
                Image(systemName: "apple.logo")
                Image(systemName: "creditcard.fill")
                Image(systemName: "g.circle.fill")
                Image(systemName: "link.circle.fill")
            }
            .font(.caption)
            .foregroundStyle(HE3Theme.bone.opacity(0.3))

            Text("\"You now have 90 days.\nMost men finish in 30.\nThe men who transform start immediately.\"")
                .font(BrandFont.body(13, weight: .light))
                .foregroundStyle(HE3Theme.bone.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .italic()
                .padding(.top, 4)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.6), value: appeared)
    }
}

struct ContainerDetail: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
            Spacer()
            Text(value)
                .font(BrandFont.mono(13, weight: .medium))
                .foregroundStyle(HE3Theme.textPrimary)
        }
    }
}

struct ModuleRow: View {
    let week: Int
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(HE3Theme.gold)
                .frame(width: 24, height: 24)
                .background(HE3Theme.gold.opacity(0.1))
                .clipShape(.rect(cornerRadius: 0))

            VStack(alignment: .leading, spacing: 2) {
                Text("WEEK \(week)")
                    .font(BrandFont.mono(8, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(HE3Theme.gold)

                Text(title)
                    .font(BrandFont.body(15, weight: .semiBold))
                    .foregroundStyle(HE3Theme.textPrimary)
            }

            Spacer()
        }
    }
}

struct ModuleFeature: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(HE3Theme.gold)
                .frame(width: 4, height: 4)

            Text(text)
                .font(BrandFont.body(13, weight: .light))
                .foregroundStyle(HE3Theme.ash)
        }
    }
}

struct IncludedItem: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(HE3Theme.gold)
                .frame(width: 2, height: 14)

            Text(text)
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
        }
    }
}

struct TermsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer().frame(height: 8)

                        Text("HE\u{00B3} TERMS & CONDITIONS")
                            .font(BrandFont.mono(11, weight: .medium))
                            .tracking(3)
                            .foregroundStyle(HE3Theme.gold)

                        TermsSection(title: "Program Access", content: "Upon purchase, you are granted 90 days of access to the HE\u{00B3}: The Integrated Man System. The system is designed to be completed within 30 days, with the remaining 60 days serving as your integration and repetition phase. After 90 days, your access will close automatically.")

                        TermsSection(title: "No Lifetime Access", content: "This is an intentional design decision. HE\u{00B3} is a discipline-based transformation system, not a content library. The 90-day container exists to create urgency, structure, and accountability. There is no lifetime access option.")

                        TermsSection(title: "Pricing", content: "The one-time purchase price is $297 USD. This is a non-recurring charge processed through the Apple App Store.")

                        TermsSection(title: "Reactivation Policy", content: "If your 90-day access expires before completion, a one-time reactivation is available for $147 USD. This grants an additional 45 days of access. No second reactivation is available. If a man fails twice, the system has done its part. This is a filter, not a rescue.")

                        TermsSection(title: "Refund Policy", content: "All purchases are final. Due to the immediate digital delivery of the program content, no refunds will be issued. By purchasing, you acknowledge and agree to this policy.")

                        TermsSection(title: "Program Structure", content: "HE\u{00B3} consists of four modules (pillars), each designed to be completed in one week:\n\n\u{2022} Week 1: The Suppressed Man\n\u{2022} Week 2: The Awakening\n\u{2022} Week 3: Integration\n\u{2022} Week 4: The Rising\n\nEach module includes a core video lesson, AI-supported reflection prompts, written exercises, identity calibration assignments, and action directives.")

                        TermsSection(title: "Mandatory Assessment", content: "The HE\u{00B3} 3-Voices Assessment must be completed before accessing Pillar One. This assessment identifies your dominant and suppressed voice dynamics and is integral to the program's personalization.")

                        TermsSection(title: "Content Disclaimer", content: "HE\u{00B3} is a self-guided personal development program. It is not therapy, counseling, or medical treatment. If you are experiencing a mental health crisis, please contact a licensed professional. The creator and distributor of HE\u{00B3} are not liable for individual outcomes.")

                        TermsSection(title: "Intellectual Property", content: "All content within HE\u{00B3} — including but not limited to text, video, audio, assessments, and frameworks — is the intellectual property of HE\u{00B3} and its creator. Reproduction, distribution, or resale of any program content is strictly prohibited.")

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 24)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(HE3Theme.gold)
                }
            }
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(HE3Theme.background)
        .preferredColorScheme(.light)
    }
}

struct TermsSection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(BrandFont.display(18))
                .foregroundStyle(HE3Theme.textPrimary)

            Text(content)
                .font(BrandFont.body(14, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .lineSpacing(3)
        }
    }
}
