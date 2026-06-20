import SwiftUI

/// Real sign in. Apple or Google through Supabase Auth. No payment here.
/// After sign in, ContentView reads entitlement and routes to the program or
/// the Locked screen.
struct LoginSheet: View {
    var progress: UserProgressViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAccessCode = false
    @State private var showAdminPortal = false

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    AnimatedLogoView(animate: false, compact: true)

                    VStack(spacing: 10) {
                        Text("WELCOME")
                            .font(BrandFont.display(30))
                            .foregroundStyle(HE3Theme.textPrimary)

                        Text("Sign in to enter your program. One login across the app and your Brotherhood space.")
                            .font(BrandFont.body(16, weight: .light))
                            .foregroundStyle(HE3Theme.ash)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }

                    SignInButtons(onSignedIn: { dismiss() })
                        .padding(.horizontal, 28)

                    Spacer()

                    // Discreet owner entry. Hidden in the App Store build.
                    if AppConfig.ownerPreviewEnabled {
                        Button {
                            showAccessCode = true
                        } label: {
                            Text("Admin access")
                                .font(BrandFont.mono(10))
                                .tracking(1)
                                .foregroundStyle(HE3Theme.ashLight.opacity(0.6))
                        }
                        .padding(.bottom, 12)
                    }

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(HE3Theme.ashLight)
                    }
                }
            }
        }
        .sheet(isPresented: $showAccessCode) {
            AccessCodeSheet(
                onAdmin: { showAdminPortal = true },
                onReview: {
                    progress.godMode = true
                    dismiss()
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showAdminPortal) {
            AdminPortalView()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(HE3Theme.background)
        .preferredColorScheme(.light)
    }
}
