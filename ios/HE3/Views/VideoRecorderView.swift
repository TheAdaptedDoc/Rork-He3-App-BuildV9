import SwiftUI
import AVFoundation
import UIKit

@MainActor
@Observable
final class VideoRecorderController: NSObject {
    enum State: Equatable {
        case idle
        case ready
        case recording
        case finished(URL, Double)
        case failed(String)
    }

    var state: State = .idle
    var elapsed: Double = 0

    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let sessionQueue = DispatchQueue(label: "he3.camera.session")
    private var startTime: Date?
    private var timer: Timer?
    private var pendingURL: URL?

    func configure() {
        sessionQueue.async { [self] in
            session.beginConfiguration()
            session.sessionPreset = .high

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let videoInput = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(videoInput) else {
                Task { @MainActor in self.state = .failed("Camera unavailable") }
                session.commitConfiguration()
                return
            }
            session.addInput(videoInput)

            if let audioDevice = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
               session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }

            if session.canAddOutput(movieOutput) {
                session.addOutput(movieOutput)
            }

            session.commitConfiguration()
            session.startRunning()

            Task { @MainActor in self.state = .ready }
        }
    }

    func startRecording(to url: URL) {
        guard !movieOutput.isRecording else { return }
        pendingURL = url
        try? FileManager.default.removeItem(at: url)
        movieOutput.startRecording(to: url, recordingDelegate: self)
        startTime = Date()
        state = .recording
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let s = self.startTime else { return }
                self.elapsed = Date().timeIntervalSince(s)
            }
        }
    }

    func stopRecording() {
        guard movieOutput.isRecording else { return }
        movieOutput.stopRecording()
        timer?.invalidate()
        timer = nil
    }

    func tearDown() {
        sessionQueue.async { [self] in
            if session.isRunning {
                session.stopRunning()
            }
        }
        timer?.invalidate()
        timer = nil
    }
}

extension VideoRecorderController: @preconcurrency AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        Task { @MainActor in
            if let error {
                self.state = .failed(error.localizedDescription)
                return
            }
            let duration = self.elapsed
            self.state = .finished(outputFileURL, duration)
        }
    }
}

struct CameraPreviewLayerView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let v = PreviewUIView()
        v.previewLayer.session = session
        v.previewLayer.videoGravity = .resizeAspectFill
        return v
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    final class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

/// Wraps the real camera view; falls back to a placeholder on simulator / no-camera devices.
struct RitualRecorderView: View {
    @Bindable var controller: VideoRecorderController

    var body: some View {
        Group {
            #if targetEnvironment(simulator)
            CameraUnavailablePlaceholder()
            #else
            if AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil {
                CameraPreviewLayerView(session: controller.session)
            } else {
                CameraUnavailablePlaceholder()
            }
            #endif
        }
    }
}
