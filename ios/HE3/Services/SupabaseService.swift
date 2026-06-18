import Foundation
import Supabase

/// Shared Supabase client for all database and edge function calls.
/// Uses Config values injected at build time by Rork.
/// Backend provisioned 2026-06-18.
enum SupabaseService {
    static let client = SupabaseClient(
        supabaseURL: URL(string: Config.EXPO_PUBLIC_SUPABASE_URL)!,
        supabaseKey: Config.EXPO_PUBLIC_SUPABASE_ANON_KEY,
        options: .init(
            auth: .init(
                accessToken: {
                    // Returns the Rork Auth JWT when signed in, nil when signed out.
                    // With nil the SDK sends only the apikey header and the request
                    // runs as the `anon` role, so public reads keep working.
                    return AuthManager.shared.getAccessToken()
                }
            )
        )
    )
}

/// Minimal placeholder auth manager.
/// Integrate with the Rork Auth skill to populate the token and sign-in state.
final class AuthManager: Sendable {
    static let shared = AuthManager()

    private init() {}

    func getAccessToken() -> String? {
        // TODO: Return the active Rork Auth JWT from Keychain when signed in.
        // This stub returns nil so the client operates as the anon role
        // (public reads still work via permissive RLS policies).
        return nil
    }

    func isSignedIn() -> Bool { getAccessToken() != nil }
}
