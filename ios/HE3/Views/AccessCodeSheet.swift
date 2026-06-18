import SwiftUI

/// Unified hidden access sheet for operators. Accepts two distinct 6-digit codes:
/// - Admin code → opens the admin member portal
/// - Review (God Mode) code → unlocks all course content for end-to-end review
struct AccessCodeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var code: String = ""
    @State private var error: String?
    @FocusState private var focused: Bool

    /// Admin portal passcode (member analytics).
    static let adminCode = "444999"
    /// Review passcode — unlocks all course content (God Mode).
    static let reviewCode = "999000"

    var onAdmin: () -> Void
    var onReview: () -> Void

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title)
                        .foregroundStyle(HE3Theme.gold)

                    Text("RESTRICTED \u{00B7} OPERATOR ACCESS")
                        .font(BrandFont.mono(11, weight: .medium))
                        .tracking(3)
                        .foregroundStyle(HE3Theme.bone.opacity(0.6))

                    Text("Enter access code")
                        .font(BrandFont.display(22))
                        .foregroundStyle(HE3Theme.textPrimary)

                    Text("One code opens the member portal. A different code unlocks course content for review.")
                        .font(BrandFont.body(12, weight: .light))
                        .foregroundStyle(HE3Theme.bone.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)

                ZStack {
                    HStack(spacing: 10) {
                        ForEach(0..<6, id: \.self) { i in
                            let char = i < code.count ? String(code[code.index(code.startIndex, offsetBy: i)]) : ""
                            Text(char)
                                .font(BrandFont.display(28))
                                .foregroundStyle(HE3Theme.textPrimary)
                                .frame(width: 44, height: 56)
                                .background(HE3Theme.iron)
                                .overlay(
                                    Rectangle()
                                        .fill(i < code.count ? HE3Theme.gold : HE3Theme.steel)
                                        .frame(height: 2)
                                        .frame(maxHeight: .infinity, alignment: .bottom)
                                )
                                .clipShape(.rect(cornerRadius: 0))
                        }
                    }

                    TextField("", text: $code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .foregroundStyle(.clear)
                        .tint(.clear)
                        .focused($focused)
                        .frame(width: 320, height: 56)
                        .background(Color.clear)
                        .onChange(of: code) { _, newValue in
                            let filtered = newValue.filter(\.isNumber)
                            if filtered.count > 6 {
                                code = String(filtered.prefix(6))
                            } else if filtered != newValue {
                                code = filtered
                            }
                            error = nil
                            if code.count == 6 {
                                submit()
                            }
                        }
                }

                if let error {
                    Text(error.uppercased())
                        .font(BrandFont.mono(10, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(.red.opacity(0.9))
                        .transition(.opacity)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("CANCEL")
                        .font(BrandFont.mono(11, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(HE3Theme.bone.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(HE3Theme.iron)
                        .clipShape(.rect(cornerRadius: 0))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
        }
        .onAppear { focused = true }
    }

    private func submit() {
        switch code {
        case Self.adminCode:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onAdmin()
            dismiss()
        case Self.reviewCode:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onReview()
            dismiss()
        default:
            withAnimation(.easeInOut(duration: 0.2)) {
                error = "Invalid code"
            }
            code = ""
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
