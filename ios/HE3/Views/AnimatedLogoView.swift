import SwiftUI

/// HE³ wordmark lockup — Oswald 700 obsidian with a crimson, skewed superscript "3".
struct AnimatedLogoView: View {
    @State private var showH: Bool = false
    @State private var showThree: Bool = false

    var animate: Bool = true
    var compact: Bool = false

    private var fontSize: CGFloat { compact ? 30 : 46 }
    private var superscriptSize: CGFloat { fontSize * 0.46 }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("HE")
                .font(BrandFont.logo(fontSize))
                .tracking(compact ? -0.5 : -1)
                .foregroundStyle(HE3Theme.obsidian)
                .opacity(showH ? 1 : 0)

            Text("3")
                .font(BrandFont.logo(superscriptSize))
                .foregroundStyle(HE3Theme.crimson)
                .italic()
                .transformEffect(.init(a: 1, b: 0, c: tan(-12 * .pi / 180), d: 1, tx: 0, ty: 0))
                .baselineOffset(fontSize * 0.42)
                .opacity(showThree ? 1 : 0)
        }
        .onAppear {
            guard animate else {
                showH = true
                showThree = true
                return
            }
            withAnimation(.easeOut(duration: 0.5)) { showH = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.25)) { showThree = true }
        }
    }
}

/// Three crimson vertical marks — the HE³ series signature.
struct SeriesMarks: View {
    var color: Color? = nil   // nil means use the true tri-color voice marks
    var height: CGFloat = 18
    var width: CGFloat = 4
    var spacing: CGFloat = 5

    // Ego crimson, Self obsidian, Innate ember, matching the brand logo mark.
    private let voiceColors: [Color] = [HE3Theme.crimson, HE3Theme.obsidian, HE3Theme.ember]

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<3, id: \.self) { i in
                Rectangle()
                    .fill(color ?? voiceColors[i])
                    .frame(width: width, height: height)
            }
        }
    }
}

#Preview {
    ZStack {
        HE3Theme.bone.ignoresSafeArea()
        VStack(spacing: 40) {
            AnimatedLogoView(animate: false)
            SeriesMarks()
        }
    }
}
