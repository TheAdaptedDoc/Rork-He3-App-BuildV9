import SwiftUI

/// The three-voice icon system, drawn from the brand spec SVG paths.
/// EGO — lightning bolt (crimson, filled)
/// SELF — concentric ring + center dot (obsidian, stroked)
/// INNATE — single sine wave (ember, stroked)
struct VoiceIcon: View {
    let voice: Voice
    var size: CGFloat = 24

    var body: some View {
        switch voice {
        case .ego:
            EgoBolt()
                .fill(HE3Theme.crimson)
                .frame(width: size, height: size)
        case .selfVoice:
            ZStack {
                Circle()
                    .stroke(HE3Theme.obsidian, lineWidth: size * (2.3 / 24))
                    .frame(width: size * (18 / 24), height: size * (18 / 24))
                Circle()
                    .fill(HE3Theme.obsidian)
                    .frame(width: size * (6.6 / 24), height: size * (6.6 / 24))
            }
            .frame(width: size, height: size)
        case .innate:
            InnateWave()
                .stroke(HE3Theme.ember, style: StrokeStyle(lineWidth: size * (2.4 / 24), lineCap: .round))
                .frame(width: size * (28 / 24), height: size)
        }
    }
}

/// M13.5 2 L4 13.6 h6 L9 22 18.5 9.4 h-6 z  (24×24 viewBox)
struct EgoBolt: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 24
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        var path = Path()
        path.move(to: p(13.5, 2))
        path.addLine(to: p(4, 13.6))
        path.addLine(to: p(10, 13.6))
        path.addLine(to: p(9, 22))
        path.addLine(to: p(18.5, 9.4))
        path.addLine(to: p(12.5, 9.4))
        path.closeSubpath()
        return path
    }
}

/// viewBox 28×24 — M2 12 C6 2.5 10 2.5 14 12 S22 21.5 26 12
struct InnateWave: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 28
        let sy = rect.height / 24
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * sx, y: y * sy) }
        var path = Path()
        path.move(to: p(2, 12))
        path.addCurve(to: p(14, 12), control1: p(6, 2.5), control2: p(10, 2.5))
        path.addCurve(to: p(26, 12), control1: p(18, 21.5), control2: p(22, 21.5))
        return path
    }
}

#Preview {
    ZStack {
        HE3Theme.bone.ignoresSafeArea()
        HStack(spacing: 28) {
            VoiceIcon(voice: .ego, size: 40)
            VoiceIcon(voice: .selfVoice, size: 40)
            VoiceIcon(voice: .innate, size: 40)
        }
    }
}
