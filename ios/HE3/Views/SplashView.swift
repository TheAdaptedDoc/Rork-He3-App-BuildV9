import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                AnimatedLogoView(animate: true)

                Text("THE INTEGRATED MAN SYSTEM")
                    .font(BrandFont.mono(10, weight: .medium))
                    .tracking(4)
                    .foregroundStyle(HE3Theme.ashLight)
            }
        }
    }
}
