import SwiftUI
import AVFoundation

struct NightPracticeView: View {
    var rituals: RitualVideoViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion = 0
    @State private var appeared = false
    @State private var controller = VideoRecorderController()
    @State private var hasCamera: Bool = {
        #if targetEnvironment(simulator)
        return false
        #else
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
        #endif
    }()
    @State private var savedToast: String?

    private let questions = [
        "Where did I lead with truth today?",
        "Where did I hide?",
        "What will I face tomorrow?"
    ]

    private var isRecording: Bool {
        if case .recording = controller.state { return true }
        return false
    }

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 12)
                cameraArea
                    .padding(.horizontal, 24)
                Spacer(minLength: 12)
                bottomArea
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
            if hasCamera {
                requestPermissionsAndConfigure()
            }
        }
        .onDisappear {
            controller.tearDown()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                if isRecording { controller.stopRecording() }
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.medium))
                    .foregroundStyle(HE3Theme.bone.opacity(0.6))
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Text("COURAGE RITUAL")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.gold)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var cameraArea: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Rectangle()
                    .fill(HE3Theme.iron)
                    .frame(height: 320)

                if hasCamera {
                    CameraPreviewLayerView(session: controller.session)
                        .frame(height: 320)
                        .allowsHitTesting(false)
                } else {
                    CameraUnavailablePlaceholder()
                        .frame(height: 320)
                }
            }
            .clipShape(.rect(cornerRadius: 0))

            if isRecording {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text(timeString(controller.elapsed))
                        .font(BrandFont.mono(11, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.55))
                .clipShape(.rect(cornerRadius: 0))
                .padding(12)
            }
        }
    }

    @ViewBuilder
    private var bottomArea: some View {
        VStack(spacing: 22) {
            Image(systemName: "moon.stars.fill")
                .font(.caption)
                .foregroundStyle(HE3Theme.gold)

            VStack(spacing: 8) {
                Text("QUESTION \(currentQuestion + 1) OF \(questions.count)")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(HE3Theme.ashLight)

                Text(questions[currentQuestion])
                    .font(BrandFont.body(20, weight: .medium))
                    .foregroundStyle(HE3Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .id(currentQuestion)
                    .transition(.opacity)
            }

            if let savedToast {
                Text(savedToast)
                    .font(BrandFont.mono(11, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(HE3Theme.gold)
            }

            recordControls

            navControls
        }
    }

    private var recordControls: some View {
        VStack(spacing: 8) {
            if hasCamera {
                Button {
                    toggleRecording()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: isRecording ? "stop.fill" : "record.circle")
                        Text(isRecording ? "STOP & SAVE" : "RECORD")
                            .font(BrandFont.mono(12, weight: .medium))
                            .tracking(1.5)
                    }
                    .foregroundStyle(isRecording ? .white : HE3Theme.background)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(isRecording ? Color.red : HE3Theme.gold)
                    .clipShape(.rect(cornerRadius: 0))
                }
                .sensoryFeedback(.impact, trigger: isRecording)
            } else {
                Text("RECORDING REQUIRES A REAL DEVICE")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(HE3Theme.ashLight)
            }
        }
    }

    private var navControls: some View {
        HStack(spacing: 12) {
            if currentQuestion > 0 {
                Button {
                    withAnimation(.easeOut(duration: 0.3)) { currentQuestion -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.caption)
                        .foregroundStyle(HE3Theme.ashLight)
                        .frame(width: 44, height: 44)
                        .background(HE3Theme.iron)
                        .clipShape(.rect(cornerRadius: 0))
                }
            }

            if currentQuestion < questions.count - 1 {
                Button {
                    withAnimation(.easeOut(duration: 0.3)) { currentQuestion += 1 }
                } label: {
                    Text("NEXT \u{2192}")
                        .font(BrandFont.mono(12, weight: .medium))
                        .tracking(1)
                        .foregroundStyle(HE3Theme.textPrimary)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(HE3Theme.iron)
                        .clipShape(.rect(cornerRadius: 0))
                }
            } else {
                Button {
                    if isRecording { controller.stopRecording() }
                    dismiss()
                } label: {
                    Text("COMPLETE \u{2192}")
                        .font(BrandFont.mono(12, weight: .medium))
                        .tracking(1)
                        .foregroundStyle(HE3Theme.textPrimary)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(HE3Theme.iron)
                        .clipShape(.rect(cornerRadius: 0))
                }
                .sensoryFeedback(.success, trigger: currentQuestion)
            }
        }
    }

    // MARK: - Logic

    private func toggleRecording() {
        if isRecording {
            controller.stopRecording()
        } else {
            let url = rituals.newRecordingURL()
            controller.startRecording(to: url)
        }
    }

    private func handleStateChange(_ state: VideoRecorderController.State) {
        if case .finished(let url, let duration) = state {
            rituals.addVideo(fileURL: url, duration: duration)
            savedToast = "RITUAL SAVED"
            Task {
                try? await Task.sleep(for: .seconds(2.4))
                savedToast = nil
            }
        }
    }

    private func requestPermissionsAndConfigure() {
        Task {
            let videoOK = await AVCaptureDevice.requestAccess(for: .video)
            _ = await AVCaptureDevice.requestAccess(for: .audio)
            if videoOK {
                controller.configure()
            } else {
                hasCamera = false
            }
        }
        // Observe state changes via task
        Task {
            var lastState: VideoRecorderController.State = .idle
            while !Task.isCancelled {
                let s = controller.state
                if s != lastState {
                    lastState = s
                    handleStateChange(s)
                }
                try? await Task.sleep(for: .milliseconds(150))
            }
        }
    }

    private func timeString(_ t: Double) -> String {
        let total = Int(t)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

struct CameraProxyView: View {
    var body: some View {
        CameraUnavailablePlaceholder()
    }
}

struct CameraUnavailablePlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.fill")
                .font(.system(size: 36))
                .foregroundStyle(HE3Theme.bone.opacity(0.3))

            Text("CAMERA PREVIEW")
                .font(BrandFont.mono(11, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.bone.opacity(0.6))

            Text("Install this app on your device\nvia the Rork App to use the camera.")
                .font(BrandFont.mono(10))
                .foregroundStyle(HE3Theme.bone.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HE3Theme.iron)
    }
}
