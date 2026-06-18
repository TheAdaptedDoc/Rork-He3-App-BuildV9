import SwiftUI

/// End of the free funnel. The man has seen his voice profile. Now he creates an
/// account (Apple or Google), and on sign in ContentView routes him to the Locked
/// screen where Unlock the Program opens web checkout. The app never charges him.
struct UnlockPromptView: View {
    var progress: UserProgressViewModel
    var onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            HE3Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    Text("YOUR SIGNAL IS READ")
                        .font(BrandFont.mono(11, weight: .medium))
                        .tracking(3)
                        .foregroundStyle(HE3Theme.crimson)

                    Text("BEGIN THE 30 DAY SPRINT")
                        .font(BrandFont.display(32))
                        .foregroundStyle(HE3Theme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Create your account to unlock the full program. A 30 day integration sprint inside a 90 day window. You buy once on the web, and the app opens the moment you return.")
                        .font(BrandFont.body(16, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    SignInButtons()
                        .padding(.horizontal, 28)
                        .padding(.top, 8)

                    Spacer()
                }
            }
            .scrollIndicators(.hidden)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
                    .foregroundStyle(HE3Theme.ashLight)
                    .frame(width: 36, height: 36)
                    .background(HE3Theme.surface)
                    .clipShape(Circle())
            }
            .padding(.leading, 20)
            .padding(.top, 12)
        }
    }
}
