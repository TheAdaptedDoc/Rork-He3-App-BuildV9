import SwiftUI

struct ContactInfoView: View {
    var progress: UserProgressViewModel
    var onComplete: () -> Void
    var onClose: () -> Void
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var appeared: Bool = false
    @FocusState private var focusedField: Field?

    enum Field {
        case name, email, phone
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(HE3Theme.bone.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(HE3Theme.iron)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 24)

                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(HE3Theme.gold)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    VStack(spacing: 12) {
                        Text("BEFORE YOU BEGIN")
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(3)
                            .foregroundStyle(HE3Theme.gold)

                        Text("TELL US WHO\nYOU ARE")
                            .font(BrandFont.display(30))
                            .foregroundStyle(HE3Theme.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: appeared)

                    Text("We'll send your assessment results\nto the email you provide below.")
                        .font(BrandFont.body(16, weight: .light))
                        .foregroundStyle(HE3Theme.ash)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: appeared)

                    VStack(spacing: 0) {
                        ContactTextField(
                            placeholder: "Full Name",
                            text: $name,
                            icon: "person",
                            keyboardType: .default,
                            contentType: .name,
                            focused: $focusedField,
                            field: .name
                        )

                        Rectangle().fill(HE3Theme.steel).frame(height: 1)

                        ContactTextField(
                            placeholder: "Email Address",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            contentType: .emailAddress,
                            focused: $focusedField,
                            field: .email
                        )

                        Rectangle().fill(HE3Theme.steel).frame(height: 1)

                        ContactTextField(
                            placeholder: "Phone Number",
                            text: $phone,
                            icon: "phone",
                            keyboardType: .phonePad,
                            contentType: .telephoneNumber,
                            focused: $focusedField,
                            field: .phone
                        )
                    }
                    .background(HE3Theme.iron)
                    .clipShape(.rect(cornerRadius: 0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(HE3Theme.steel, lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: appeared)

                    Button {
                        focusedField = nil
                        progress.saveContactInfo(name: name.trimmingCharacters(in: .whitespaces), email: email.trimmingCharacters(in: .whitespaces), phone: phone.trimmingCharacters(in: .whitespaces))
                        onComplete()
                    } label: {
                        Text("CONTINUE TO ASSESSMENT \u{2192}")
                            .font(BrandFont.mono(13, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(isValid ? HE3Theme.gold : HE3Theme.bone.opacity(0.15))
                            .clipShape(.rect(cornerRadius: 0))
                    }
                    .disabled(!isValid)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: appeared)
                    .sensoryFeedback(.impact(weight: .medium), trigger: isValid)

                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.caption2)
                        Text("YOUR INFORMATION IS PRIVATE AND SECURE")
                            .font(BrandFont.mono(9))
                    }
                    .foregroundStyle(HE3Theme.ashLight)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.45), value: appeared)

                    Spacer().frame(height: 48)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            Task {
                try? await Task.sleep(for: .milliseconds(600))
                focusedField = .name
            }
        }
    }
}

struct ContactTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    let keyboardType: UIKeyboardType
    let contentType: UITextContentType?
    var focused: FocusState<ContactInfoView.Field?>.Binding
    let field: ContactInfoView.Field

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(HE3Theme.ashLight.opacity(0.5))
                .frame(width: 20)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(HE3Theme.ashLight.opacity(0.4)))
                .font(BrandFont.body(15, weight: .light))
                .foregroundStyle(HE3Theme.textPrimary)
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .autocorrectionDisabled()
                .focused(focused, equals: field)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }
}
