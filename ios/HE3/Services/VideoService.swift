import Foundation
import Supabase

/// Resolves lessons to a signed, short lived stream URL.
/// The catalog is loaded once. Each time a lesson opens we ask the edge function
/// for a fresh token, which it only mints if the man is entitled.
@Observable
@MainActor
final class VideoService {
    static let shared = VideoService()
    private init() {}

    private(set) var catalog: [Lesson] = []
    private var bySlug: [String: Lesson] = [:]

    /// Load the lesson catalog. RLS already restricts this to entitled users,
    /// so an empty result is a normal locked state, not an error.
    func loadCatalog() async {
        do {
            let rows: [Lesson] = try await SupabaseService.client
                .from("lessons")
                .select()
                .eq("is_published", value: true)
                .order("sort", ascending: true)
                .execute()
                .value
            catalog = rows
            bySlug = Dictionary(uniqueKeysWithValues: rows.map { ($0.slug, $0) })
        } catch {
            catalog = []
            bySlug = [:]
        }
    }

    func lesson(forSlug slug: String) -> Lesson? { bySlug[slug] }

    enum PlaybackResult: Sendable {
        case ready(URL)
        case locked
        case comingSoon
        case failed
    }

    /// Mint a signed URL for a lesson. Returns `.locked` when the server says
    /// the man is not entitled, `.comingSoon` when no video is attached yet.
    func playbackURL(for lesson: Lesson) async -> PlaybackResult {
        guard let playbackId = lesson.muxPlaybackId, !playbackId.isEmpty else {
            return .comingSoon
        }
        do {
            let response: TokenResponse = try await SupabaseService.client.functions
                .invoke(
                    "mint-playback-token",
                    options: .init(body: ["playbackId": playbackId])
                )
            guard let url = URL(string: response.url) else { return .failed }
            return .ready(url)
        } catch let FunctionsError.httpError(code, _) where code == 403 {
            return .locked
        } catch {
            return .failed
        }
    }

    private struct TokenResponse: Decodable {
        let token: String
        let url: String
        let expiresIn: Int
    }
}
