import Foundation
import Supabase

/// Best effort write of an assessment take to Supabase. Mirrors the four metrics
/// the web stores, tagged day0 or day30 so the Re Calibration can compare them.
/// Silent on failure: the local copy is always the working source.
enum AssessmentSync {
    private struct Row: Encodable {
        let user_id: String
        let phase: String
        let ego_score: Int
        let self_score: Int
        let innate_score: Int
        let integration_score: Int
        let voice_spread: Int
        let dominant: String
        let suppressed: String
        let archetype: String
    }

    static func persist(scores: AssessmentScores, phase: String) {
        Task {
            guard let uid = AuthManager.shared.userId else { return }
            let row = Row(
                user_id: uid,
                phase: phase,
                ego_score: scores.ego,
                self_score: scores.selfVoice,
                innate_score: scores.innate,
                integration_score: scores.integration,
                voice_spread: scores.voiceSpread,
                dominant: scores.dominantVoice.displayName,
                suppressed: scores.suppressedVoice.displayName,
                archetype: scores.profile.title
            )
            _ = try? await SupabaseService.client
                .from("assessment_results")
                .insert(row)
                .execute()
        }
    }
}
