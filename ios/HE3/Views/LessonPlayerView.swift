import SwiftUI
import AVKit

/// Drop in replacement for the static video placeholder in SectionDetailView.
/// Resolves the section to its lesson, mints a signed stream URL, and plays it.
/// Every state stays on brand: bone surface, crimson accent, no rounded corners.
struct LessonPlayerView: View {
    /// The PillarSection id, which equals the lesson slug for core lessons.
    let slug: String
    /// Shown before the catalog resolves, from the section's own copy.
    let fallbackTitle: String
    let fallbackDuration: String

    @State private var phase: Phase = .loading
    @State private var player: AVPlayer?
    @State private var lesson: Lesson?

    enum Phase: Equatable {
        case loading
        case ready
        case comingSoon
        case locked
        case failed
    }

    var body: some View {
        Group {
            switch phase {
            case .ready:
                if let player {
                    VideoPlayer(player: player)
                        .frame(height: 210)
                        .clipShape(.rect(cornerRadius: 0))
                } else {
                    panel { failedContent }
                }
            case .loading:
                panel { loadingContent }
            case .comingSoon:
                panel { comingSoonContent }
            case .locked:
                panel { lockedContent }
            case .failed:
                panel { failedContent }
            }
        }
        .task { await resolve() }
        .onDisappear { player?.pause() }
    }

    // MARK: - Resolution

    private func resolve() async {
        if VideoService.shared.catalog.isEmpty {
            await VideoService.shared.loadCatalog()
        }
        guard let found = VideoService.shared.lesson(forSlug: slug) else {
            phase = .comingSoon
            return
        }
        lesson = found

        switch await VideoService.shared.playbackURL(for: found) {
        case .ready(let url):
            let p = AVPlayer(url: url)
            player = p
            phase = .ready
        case .comingSoon:
            phase = .comingSoon
        case .locked:
            phase = .locked
        case .failed:
            phase = .failed
        }
    }

    // MARK: - States

    private func panel<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ZStack {
            Rectangle()
                .fill(HE3Theme.surface)
                .frame(height: 210)
                .clipShape(.rect(cornerRadius: 0))
            content()
        }
    }

    private var loadingContent: some View {
        VStack(spacing: 12) {
            ProgressView().tint(HE3Theme.crimson)
            Text((lesson?.title ?? fallbackTitle).uppercased())
                .font(BrandFont.display(18))
                .foregroundStyle(HE3Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }

    private var comingSoonContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "play.circle")
                .font(.system(size: 44))
                .foregroundStyle(HE3Theme.crimson.opacity(0.7))
            Text((lesson?.title ?? fallbackTitle).uppercased())
                .font(BrandFont.display(18))
                .foregroundStyle(HE3Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            Text("LESSON DROPS SOON")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(HE3Theme.ashLight)
        }
    }

    private var lockedContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundStyle(HE3Theme.ashLight)
            Text("UNLOCK THE PROGRAM TO WATCH")
                .font(BrandFont.mono(11, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(HE3Theme.ash)
        }
    }

    private var failedContent: some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 32))
                .foregroundStyle(HE3Theme.ashLight)
            Text("COULD NOT LOAD")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(HE3Theme.ash)
            Button {
                phase = .loading
                Task { await resolve() }
            } label: {
                Text("RETRY")
                    .font(BrandFont.mono(11, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HE3Theme.crimson)
            }
        }
    }
}
