import Foundation
import Supabase

/// Calls the ai-reflection edge function. The Anthropic key lives only on the
/// server, so the app just sends the man's situation and profile and gets back
/// the three voices plus a synthesis.
enum ReflectionService {
    struct Request: Encodable {
        let situation: String
        let pillar: String?
        let profile: Profile
        struct Profile: Encodable {
            let dominant: String
            let suppressed: String
            let archetype: String
            let ego: Int
            let self_: Int
            let innate: Int
            let integration: Int
            enum CodingKeys: String, CodingKey {
                case dominant, suppressed, archetype, ego, innate, integration
                case self_ = "self"
            }
        }
    }

    enum Result {
        case ready(CouncilReflection)
        case locked
        case failed
    }

    static func convene(situation: String, pillar: String?, scores: AssessmentScores) async -> Result {
        let profile = Request.Profile(
            dominant: scores.dominantVoice.displayName,
            suppressed: scores.suppressedVoice.displayName,
            archetype: scores.profile.title,
            ego: scores.ego,
            self_: scores.selfVoice,
            innate: scores.innate,
            integration: scores.integration
        )
        let req = Request(situation: situation, pillar: pillar, profile: profile)
        do {
            let reflection: CouncilReflection = try await SupabaseService.client.functions
                .invoke("ai-reflection", options: .init(body: req))
            return .ready(reflection)
        } catch let FunctionsError.httpError(code, _) where code == 403 {
            return .locked
        } catch {
            return .failed
        }
    }

    /// A man's past sittings, newest first. Empty on any failure.
    static func history() async -> [CouncilSitting] {
        do {
            let rows: [CouncilSitting] = try await SupabaseService.client
                .from("reflections")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            return rows
        } catch {
            return []
        }
    }
}
