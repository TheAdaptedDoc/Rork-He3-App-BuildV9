import SwiftUI

/// Value proposition plus the single unlock action. No in app payment, no card
/// form, no store terms. The button opens the Stripe web checkout, passing the
/// signed in man's id so the webhook can match him.
struct PurchaseView: View {
    var progress: UserProgressViewModel
    var onPurchaseComplete: () -> Void = {}

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    Spacer().frame(height: 40)

                    Text("HE\u{00B3} · THE INTEGRATED MAN")
                        .font(BrandFont.mono(11, weight: .medium))
                        .tracking(3)
                        .foregroundStyle(HE3Theme.crimson)

                    Text("$297")
                        .font(BrandFont.display(56))
                        .foregroundStyle(HE3Theme.textPrimary)

                    Text("90 DAY ACCESS · 30 DAY SPRINT")
                        .font(BrandFont.mono(11))
                        .foregroundStyle(HE3Theme.ashLight)

                    Text("A one time purchase. You buy once on the web. Your 90 day window opens the day the app lets you in, and the work is built to be done in the first 30. After 90 days, access closes. There is no lifetime access, because there is no lifetime procrastination.")
                        .font(BrandFont.body(16, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Button {
                        CheckoutLauncher.openCheckout(uid: AuthManager.shared.userId)
                    } label: {
                        Text("UNLOCK THE PROGRAM \u{2192}")
                            .font(BrandFont.mono(13, weight: .medium))
                            .tracking(1.5)
                            .foregroundStyle(HE3Theme.bone)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(HE3Theme.crimson)
                            .clipShape(.rect(cornerRadius: 0))
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
