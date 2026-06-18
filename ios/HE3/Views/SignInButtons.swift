import SwiftUI
import AuthenticationServices

/// Reusable Apple and Google sign in, wired to Supabase Auth. Used on the login
/// sheet and at the end of the funnel, so a man has an account (and a uid) before
/// he is sent to web checkout.
struct SignInButtons: View {
    var onSignedIn: () -> Void = {}
    @State private var currentNonce: String?
    @State private var error: String?
    @State private var working = false

    var body: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(.signIn) { request in
                let nonce = AuthManager.randomNonce()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = AuthManager.sha256(nonce)
            } onCompletion: { result in
                handleApple(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 54)
            .clipShape(.rect(cornerRadius: 0))

            Button {
                Task {
                    working = true
                    do { try await AuthManager.shared.signInWithGoogle(); onSignedIn() }
                    catch { self.error = "Google sign in did not complete" }
                    working = false
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "g.circle.fill")
                    Text("CONTINUE WITH GOOGLE")
                        .font(BrandFont.mono(12, weight: .medium))
                        .tracking(1.5)
                }
                .foregroundStyle(HE3Theme.obsidian)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .overlay(Rectangle().stroke(HE3Theme.obsidian, lineWidth: 1.5))
            }
            .disabled(working)

            if let error {
                Text(error.uppercased())
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(.red.opacity(0.85))
            }
        }
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                error = "Apple sign in did not return a token"
                return
            }
            Task {
                do { try await AuthManager.shared.signInWithApple(idToken: idToken, nonce: nonce); onSignedIn() }
                catch { self.error = "Could not complete Apple sign in" }
            }
        case .failure:
            error = "Apple sign in was cancelled"
        }
    }
}
