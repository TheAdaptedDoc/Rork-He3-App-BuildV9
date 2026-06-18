import Foundation

/// One lesson video in the catalog. Mirrors the `lessons` table.
/// `slug` equals the PillarSection id for core lessons, so a section resolves
/// to its video with no extra mapping.
nonisolated struct Lesson: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let slug: String
    let kind: String
    let pillarId: Int?
    let dayIndex: Int?
    let sort: Int
    let title: String
    let subtitle: String?
    let durationSeconds: Int
    let muxPlaybackId: String?
    let isPublished: Bool

    enum CodingKeys: String, CodingKey {
        case id, slug, kind, sort, title, subtitle
        case pillarId = "pillar_id"
        case dayIndex = "day_index"
        case durationSeconds = "duration_seconds"
        case muxPlaybackId = "mux_playback_id"
        case isPublished = "is_published"
    }

    /// "12 MIN" style label, no hyphen, brand safe.
    var durationLabel: String {
        let minutes = max(1, Int((Double(durationSeconds) / 60.0).rounded()))
        return "\(minutes) MIN"
    }

    var hasVideo: Bool {
        guard let id = muxPlaybackId else { return false }
        return !id.isEmpty
    }
}
