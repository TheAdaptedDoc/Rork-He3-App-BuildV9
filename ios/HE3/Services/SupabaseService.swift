import Foundation
import Supabase

/// Shared Supabase client. The SDK manages the auth session itself (stored in the
/// Keychain, auto refreshed), so requests run as the signed in man and RLS applies.
/// Config values are injected at build time by Rork.
enum SupabaseService {
    /// Lazily initialized so a missing config value does not crash at static-init
    /// time (which the simulator may report as "installation failed").
    static let client: SupabaseClient = {
        guard let url = URL(string: Config.EXPO_PUBLIC_SUPABASE_URL),
              !Config.EXPO_PUBLIC_SUPABASE_ANON_KEY.isEmpty else {
            // Config not yet injected — return a client that won't function but
            // also won't crash. The real values are present in the build artifact;
            // this guard is only a safety net for edge-case environments.
            return SupabaseClient(
                supabaseURL: URL(string: "https://placeholder.rork.app")!,
                supabaseKey: "placeholder"
            )
        }
        return SupabaseClient(supabaseURL: url, supabaseKey: Config.EXPO_PUBLIC_SUPABASE_ANON_KEY)
    }()
}
