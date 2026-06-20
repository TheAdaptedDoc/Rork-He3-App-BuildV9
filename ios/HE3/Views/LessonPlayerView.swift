import SwiftUI
import AVKit

/// The lesson video slot. Resolves the section to its lesson, mints a signed
/// stream URL, and plays it. Until a video is attached it shows a finished,
/// intentional Coming Soon card rather than an error, so the build reads as
/// complete with only the footage pending.
struct LessonPlayerView: View {
    /// The PillarSection id, which equals the lesson slug for core lessons.
    let slug: String
    /// Shown before the catalog resolves, from the section's own copy.
    let fallbackTitle: String
    let fallbackDuration: String
    /// Owner preview always shows the Coming Soon card and skips the network.
    var previewMode: Bool = false

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

    private let height: CGFloat = 210

    var body: some View {
        Group {
            switch phase {
            case .ready:
                if let player {
                    VideoPlayer(player: player)
                        .frame(height: height)
                        .clipShape(.rect(cornerRadius: 0))
                } else {
                    comingSoonCard
                }
            case .loading:
                panel { loadingContent }
            case .comingSoon:
                comingSoonCard
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
        // In owner preview there is no signed in user, so keep it clean and
        // intentional: every module shows the Coming Soon card.
        if previewMode {
            phase = .comingSoon
            return
        }
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

    // MARK: - Coming Soon (the finished placeholder)

    private var comingSoonCard: some View {
        ZStack {
            Rectangle().fill(HE3Theme.obsidian)
            // faint film grain via layered marks, keeps it from looking empty
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(HE3Theme.bone.opacity(0.85), lineWidth: 2)
                        .frame(width: 56, height: 56)
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(HE3Theme.bone)
                        .offset(x: 2)
                }

                Text((lesson?.title ?? fallbackTitle).uppercased())
                    .font(BrandFont.display(20))
                    .foregroundStyle(HE3Theme.bone)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                HStack(spacing: 10) {
                    Text("COMING SOON")
                        .font(BrandFont.mono(9, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(HE3Theme.bone)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(HE3Theme.crimson)

                    if !fallbackDuration.isEmpty {
                        Text(fallbackDuration.uppercased())
                            .font(BrandFont.mono(9, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.bone.opacity(0.7))
                    }
                }
            }
            .padding(.vertical, 24)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipShape(.rect(cornerRadius: 0))
        .overlay(alignment: .topLeading) {
            // top corner accent bar, matches the brand video frame styling
            Rectangle().fill(HE3Theme.crimson).frame(width: 34, height: 3)
        }
    }

    // MARK: - Other states

    private func panel<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ZStack {
            Rectangle()
                .fill(HE3Theme.surface)
                .frame(height: height)
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
