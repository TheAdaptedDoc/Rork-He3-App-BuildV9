import Foundation
import Photos
import UIKit

nonisolated enum RitualSortOrder: String, Codable, Sendable {
    case newestFirst
    case oldestFirst
}

@Observable
@MainActor
class RitualVideoViewModel {
    var videos: [RitualVideo] = []
    var sortOrder: RitualSortOrder = .newestFirst

    private let defaults = UserDefaults.standard
    private let storageKey = "he3_ritual_videos"
    private let sortKey = "he3_ritual_sort"

    var sortedVideos: [RitualVideo] {
        switch sortOrder {
        case .newestFirst:
            return videos.sorted { $0.date > $1.date }
        case .oldestFirst:
            return videos.sorted { $0.date < $1.date }
        }
    }

    var ritualsDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("Rituals", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func fileURL(for video: RitualVideo) -> URL {
        ritualsDirectory.appendingPathComponent(video.filename)
    }

    func newRecordingURL() -> URL {
        let name = "ritual_\(Int(Date().timeIntervalSince1970)).mov"
        return ritualsDirectory.appendingPathComponent(name)
    }

    func load() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([RitualVideo].self, from: data) {
            videos = decoded
        }
        if let raw = defaults.string(forKey: sortKey),
           let s = RitualSortOrder(rawValue: raw) {
            sortOrder = s
        }
    }

    func addVideo(fileURL: URL, duration: Double) {
        let video = RitualVideo(filename: fileURL.lastPathComponent, date: Date(), note: nil, durationSeconds: duration)
        videos.insert(video, at: 0)
        save()
    }

    func updateNote(for video: RitualVideo, note: String) {
        guard let idx = videos.firstIndex(where: { $0.id == video.id }) else { return }
        videos[idx].note = note
        save()
    }

    func delete(_ video: RitualVideo) {
        let url = fileURL(for: video)
        try? FileManager.default.removeItem(at: url)
        videos.removeAll { $0.id == video.id }
        save()
    }

    func setSortOrder(_ order: RitualSortOrder) {
        sortOrder = order
        defaults.set(order.rawValue, forKey: sortKey)
    }

    /// Saves a video file to the user's Photos library. Returns true on success.
    func saveToPhotos(_ video: RitualVideo) async -> Bool {
        let url = fileURL(for: video)
        guard FileManager.default.fileExists(atPath: url.path) else { return false }

        let status = await requestPhotoAuthorization()
        guard status == .authorized || status == .limited else { return false }

        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { success, _ in
                continuation.resume(returning: success)
            }
        }
    }

    private func requestPhotoAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(videos) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
