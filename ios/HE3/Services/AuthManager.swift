import Foundation
import Supabase
import CryptoKit
import AuthenticationServices

/// Real auth, per the App Build Spec: Sign in with Apple and Google through
/// Supabase Auth. The app never processes payment, it only authenticates and
/// reads entitlement. The Supabase user id links the app to Stripe at checkout.
@Observable
@MainActor
final class AuthManager: NSObject {
    static let shared = AuthManager()
    private override init() { super.init() }

    private(set) var userId: String?
    private(set) var email: String?
    private(set) var isSignedIn: Bool = false

    /// Restore any stored session on launch.
    func restore() async {
        do {
            let session = try await SupabaseService.client.auth.session
            apply(session)
        } catch {
            clear()
        }
    }

    /// Sign in with Apple. Pass the identity token and the raw nonce from the
    /// SignInWithAppleButton flow (see LoginSheet).
    func signInWithApple(idToken: String, nonce: String) async throws {
        let session = try await SupabaseService.client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        apply(session)
    }

    /// Sign in with Google through Supabase OAuth. Opens the system browser,
    /// returns to the app via the configured redirect scheme, then reads the
    /// session the SDK stored. Verify this call against your installed
    /// supabase-swift version when you wire the Google provider.
    func signInWithGoogle() async throws {
        try await SupabaseService.client.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "he3://login-callback")
        )
        let session = try await SupabaseService.client.auth.session
        apply(session)
    }

    func signOut() async {
        try? await SupabaseService.client.auth.signOut()
        clear()
    }

    private func apply(_ session: Session) {
        userId = session.user.id.uuidString
        email = session.user.email
        isSignedIn = true
    }

    private func clear() {
        userId = nil
        email = nil
        isSignedIn = false
    }

    // MARK: - Nonce helpers for Sign in with Apple

    static func randomNonce(length: Int = 32) -> String {
        let chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if random < chars.count {
                result.append(chars[Int(random)])
                remaining -= 1
            }
        }
        return result
    }

    static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
