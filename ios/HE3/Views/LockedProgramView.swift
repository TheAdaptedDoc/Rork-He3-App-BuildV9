import SwiftUI

/// The Locked state from the App Build Spec. Shown to a signed in man with no
/// active entitlement. One primary action: Unlock the Program, which opens the
/// web checkout. The app never processes the payment.
struct LockedProgramView: View {
    var entitlement = EntitlementService.shared
    @State private var checking = false

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                AnimatedLogoView(animate: false, compact: true)

                VStack(spacing: 10) {
                    Text("THE INTEGRATED MAN")
                        .font(BrandFont.mono(11, weight: .medium))
                        .tracking(4)
                        .foregroundStyle(HE3Theme.obsidian)

                    Text("UNLOCK THE PROGRAM")
                        .font(BrandFont.display(34))
                        .foregroundStyle(HE3Theme.textPrimary)

                    Text("“Built from what remained.”")
                        .font(BrandFont.quote(18))
                        .foregroundStyle(HE3Theme.crimson)
                }
                .multilineTextAlignment(.center)

                Text("A 30 day integration sprint inside a 90 day window. You buy once on the web. Your access opens the moment you return.")
                    .font(BrandFont.body(16, weight: .light))
                    .foregroundStyle(HE3Theme.ash)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)

                VStack(spacing: 12) {
                    Button {
                        CheckoutLauncher.openCheckout(uid: AuthManager.shared.userId)
                    } label: {
                        Text("UNLOCK THE PROGRAM  ·  $297")
                            .font(BrandFont.mono(13, weight: .medium))
                            .tracking(1.5)
                            .foregroundStyle(HE3Theme.bone)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(HE3Theme.crimson)
                            .clipShape(.rect(cornerRadius: 0))
                    }

                    Button {
                        Task {
                            checking = true
                            await entitlement.refresh()
                            checking = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if checking { ProgressView().tint(HE3Theme.obsidian) }
                            Text(checking ? "CHECKING" : "I ALREADY PAID. REFRESH")
                                .font(BrandFont.mono(11, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(HE3Theme.obsidian)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(Rectangle().stroke(HE3Theme.obsidian, lineWidth: 1.5))
                    }
                }
                .padding(.horizontal, 24)

                Button {
                    Task { await AuthManager.shared.signOut() }
                } label: {
                    Text("SIGN OUT")
                        .font(BrandFont.mono(10, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(HE3Theme.ashLight)
                }

                Spacer()
            }
        }
    }
}
