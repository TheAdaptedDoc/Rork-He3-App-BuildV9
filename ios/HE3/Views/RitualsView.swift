import SwiftUI
import AVKit

struct RitualsView: View {
    var rituals: RitualVideoViewModel
    @State private var selectedVideo: RitualVideo?

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                if rituals.videos.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            sortBar
                            ForEach(rituals.sortedVideos) { video in
                                Button {
                                    selectedVideo = video
                                } label: {
                                    RitualVideoCard(video: video, rituals: rituals)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Rituals")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .sheet(item: $selectedVideo) { video in
                RitualPlayerSheet(video: video, rituals: rituals)
            }
        }
    }

    private var sortBar: some View {
        HStack(spacing: 4) {
            Text("SORT")
                .font(BrandFont.mono(9, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))
                .padding(.trailing, 4)

            sortChip(title: "NEWEST", order: .newestFirst)
            sortChip(title: "OLDEST", order: .oldestFirst)

            Spacer()

            Text("\(rituals.videos.count) SAVED")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(1)
                .foregroundStyle(HE3Theme.gold)
        }
        .padding(.vertical, 4)
    }

    private func sortChip(title: String, order: RitualSortOrder) -> some View {
        let isSelected = rituals.sortOrder == order
        return Button {
            rituals.setSortOrder(order)
        } label: {
            Text(title)
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(1)
                .foregroundStyle(isSelected ? HE3Theme.background : HE3Theme.ash)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? HE3Theme.gold : HE3Theme.iron)
                .clipShape(.rect(cornerRadius: 0))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.fill")
                .font(.system(size: 44))
                .foregroundStyle(HE3Theme.bone.opacity(0.3))

            Text("NO RITUALS RECORDED")
                .font(BrandFont.display(22))
                .foregroundStyle(HE3Theme.textPrimary)

            Text("Record your Courage Ritual from\nthe Home tab. Saved videos appear here.")
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.ash)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }
}

private struct RitualVideoCard: View {
    let video: RitualVideo
    var rituals: RitualVideoViewModel

    private var durationLabel: String {
        let total = Int(video.durationSeconds.rounded())
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Rectangle()
                    .fill(HE3Theme.steel)
                    .frame(width: 72, height: 72)
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(HE3Theme.gold)
            }
            .clipShape(.rect(cornerRadius: 0))

            VStack(alignment: .leading, spacing: 4) {
                Text(video.date.formatted(date: .abbreviated, time: .shortened))
                    .font(BrandFont.body(15, weight: .medium))
                    .foregroundStyle(HE3Theme.textPrimary)

                HStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.caption2)
                        .foregroundStyle(HE3Theme.gold)
                    Text("COURAGE RITUAL \u{00B7} \(durationLabel)")
                        .font(BrandFont.mono(10, weight: .medium))
                        .tracking(1)
                        .foregroundStyle(HE3Theme.bone.opacity(0.6))
                }

                if let note = video.note, !note.isEmpty {
                    Text(note)
                        .font(BrandFont.body(13, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(HE3Theme.bone.opacity(0.3))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }
}

private struct RitualPlayerSheet: View {
    let video: RitualVideo
    var rituals: RitualVideoViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var player: AVPlayer?
    @State private var noteDraft: String = ""
    @State private var isSavingToPhotos = false
    @State private var savedToast: String?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        videoPlayer

                        HStack(spacing: 8) {
                            Image(systemName: "moon.stars.fill")
                                .font(.caption2)
                                .foregroundStyle(HE3Theme.gold)
                            Text("COURAGE RITUAL")
                                .font(BrandFont.mono(10, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(HE3Theme.gold)
                            Spacer()
                            Text(video.date.formatted(date: .abbreviated, time: .shortened))
                                .font(BrandFont.mono(10))
                                .foregroundStyle(HE3Theme.bone.opacity(0.5))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTE")
                                .font(BrandFont.mono(10, weight: .medium))
                                .tracking(1.5)
                                .foregroundStyle(HE3Theme.bone.opacity(0.6))
                            TextField("Add a private note", text: $noteDraft, axis: .vertical)
                                .font(BrandFont.body(15, weight: .light))
                                .foregroundStyle(HE3Theme.textPrimary)
                                .lineLimit(2...6)
                                .padding(12)
                                .background(HE3Theme.iron)
                                .clipShape(.rect(cornerRadius: 0))
                                .onChange(of: noteDraft) { _, newValue in
                                    rituals.updateNote(for: video, note: newValue)
                                }
                        }

                        Button {
                            saveToPhotos()
                        } label: {
                            HStack(spacing: 10) {
                                if isSavingToPhotos {
                                    ProgressView().tint(HE3Theme.background)
                                } else {
                                    Image(systemName: "square.and.arrow.down")
                                }
                                Text("SAVE TO PHOTOS")
                                    .font(BrandFont.mono(12, weight: .medium))
                                    .tracking(1.5)
                            }
                            .foregroundStyle(HE3Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HE3Theme.gold)
                            .clipShape(.rect(cornerRadius: 0))
                        }
                        .disabled(isSavingToPhotos)

                        if let savedToast {
                            Text(savedToast)
                                .font(BrandFont.mono(11, weight: .medium))
                                .tracking(1)
                                .foregroundStyle(HE3Theme.gold)
                                .frame(maxWidth: .infinity)
                        }

                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "trash")
                                Text("DELETE RITUAL")
                                    .font(BrandFont.mono(12, weight: .medium))
                                    .tracking(1.5)
                            }
                            .foregroundStyle(Color.red.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Ritual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                noteDraft = video.note ?? ""
                let url = rituals.fileURL(for: video)
                if FileManager.default.fileExists(atPath: url.path) {
                    player = AVPlayer(url: url)
                }
            }
            .onDisappear {
                player?.pause()
            }
            .alert("Delete this ritual?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    rituals.delete(video)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The video file will be permanently removed.")
            }
        }
    }

    @ViewBuilder
    private var videoPlayer: some View {
        if let player {
            VideoPlayer(player: player)
                .frame(height: 320)
                .clipShape(.rect(cornerRadius: 0))
                .onAppear { player.play() }
        } else {
            ZStack {
                Rectangle().fill(HE3Theme.iron).frame(height: 320)
                VStack(spacing: 8) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 32))
                        .foregroundStyle(HE3Theme.bone.opacity(0.4))
                    Text("VIDEO FILE MISSING")
                        .font(BrandFont.mono(10, weight: .medium))
                        .tracking(1.5)
                        .foregroundStyle(HE3Theme.bone.opacity(0.5))
                }
            }
            .clipShape(.rect(cornerRadius: 0))
        }
    }

    private func saveToPhotos() {
        isSavingToPhotos = true
        savedToast = nil
        Task {
            let ok = await rituals.saveToPhotos(video)
            isSavingToPhotos = false
            savedToast = ok ? "SAVED TO PHOTOS" : "PHOTOS PERMISSION DENIED"
            try? await Task.sleep(for: .seconds(2.4))
            savedToast = nil
        }
    }
}
