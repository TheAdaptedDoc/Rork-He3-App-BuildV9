import Foundation
import Supabase

/// Shared Supabase client. The SDK manages the auth session itself (stored in the
/// Keychain, auto refreshed), so requests run as the signed in man and RLS applies.
/// Config values are injected at build time by Rork.
enum SupabaseService {
    static let client = SupabaseClient(
        supabaseURL: URL(string: Config.EXPO_PUBLIC_SUPABASE_URL)!,
        supabaseKey: Config.EXPO_PUBLIC_SUPABASE_ANON_KEY
    )
}
