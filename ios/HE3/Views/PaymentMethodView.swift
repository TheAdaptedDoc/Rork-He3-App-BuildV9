import SwiftUI

enum PaymentMethod: String, CaseIterable {
    case applePay
    case googlePay
    case creditCard
    case link

    var displayName: String {
        switch self {
        case .applePay: "Apple Pay"
        case .googlePay: "Google Pay"
        case .creditCard: "Credit Card"
        case .link: "Link"
        }
    }

    var icon: String {
        switch self {
        case .applePay: "apple.logo"
        case .googlePay: "g.circle.fill"
        case .creditCard: "creditcard.fill"
        case .link: "link.circle.fill"
        }
    }
}

struct PaymentMethodView: View {
    var progress: UserProgressViewModel
    var onPurchaseComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMethod: PaymentMethod?
    @State private var showCreditCardForm: Bool = false
    @State private var isProcessing: Bool = false
    @State private var appeared: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                HE3Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        Spacer().frame(height: 12)

                        priceHeader

                        paymentOptions

                        if showCreditCardForm {
                            CreditCardFormView(
                                isProcessing: $isProcessing,
                                onSubmit: { processPayment() }
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        if selectedMethod != nil && selectedMethod != .creditCard {
                            quickPayButton
                        }

                        secureNote

                        Spacer().frame(height: 40)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(HE3Theme.bone.opacity(0.6))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    appeared = true
                }
            }
        }
        .presentationBackground(HE3Theme.background)
        .presentationDragIndicator(.visible)
    }

    private var priceHeader: some View {
        VStack(spacing: 8) {
            Text("COMPLETE YOUR PURCHASE")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(3)
                .foregroundStyle(HE3Theme.gold)

            Text("$297")
                .font(BrandFont.display(52))
                .foregroundStyle(HE3Theme.gold)

            Text("HE\u{00B3}: The Integrated Man System")
                .font(BrandFont.body(15, weight: .medium))
                .foregroundStyle(HE3Theme.ash)

            Text("90-DAY ACCESS \u{00B7} 30-DAY SPRINT")
                .font(BrandFont.mono(11))
                .foregroundStyle(HE3Theme.ashLight)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .padding(.horizontal, 24)
    }

    private var paymentOptions: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("PAYMENT METHOD")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.gold)
                .padding(.horizontal, 24)

            VStack(spacing: 2) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    PaymentOptionRow(
                        method: method,
                        isSelected: selectedMethod == method,
                        onSelect: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                selectedMethod = method
                                showCreditCardForm = method == .creditCard
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private var quickPayButton: some View {
        Button {
            processPayment()
        } label: {
            HStack(spacing: 10) {
                if isProcessing {
                    ProgressView()
                        .tint(HE3Theme.background)
                } else {
                    if let method = selectedMethod {
                        Image(systemName: method.icon)
                            .font(.caption)
                        Text("PAY WITH \(method.displayName.uppercased()) \u{2192}")
                            .font(BrandFont.mono(13, weight: .medium))
                            .tracking(1)
                    }
                }
            }
            .foregroundStyle(HE3Theme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(HE3Theme.gold)
            .clipShape(.rect(cornerRadius: 0))
        }
        .disabled(isProcessing)
        .padding(.horizontal, 24)
        .sensoryFeedback(.impact(weight: .heavy), trigger: isProcessing)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var secureNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.caption2)
            Text("ALL TRANSACTIONS ARE ENCRYPTED AND SECURE")
                .font(BrandFont.mono(9))
        }
        .foregroundStyle(HE3Theme.ashLight)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
    }

    private func processPayment() {
        isProcessing = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            progress.completePurchase()
            isProcessing = false
            onPurchaseComplete()
        }
    }
}

struct PaymentOptionRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(isSelected ? HE3Theme.gold : HE3Theme.steel, lineWidth: 1.5)
                        .frame(width: 20, height: 20)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(HE3Theme.gold)
                            .frame(width: 10, height: 10)
                    }
                }

                Image(systemName: method.icon)
                    .font(.body.weight(.medium))
                    .foregroundStyle(isSelected ? HE3Theme.gold : HE3Theme.ashLight.opacity(0.6))
                    .frame(width: 24)

                Text(method.displayName.uppercased())
                    .font(BrandFont.mono(12, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(isSelected ? HE3Theme.textPrimary : HE3Theme.ash)

                Spacer()
            }
            .padding(16)
            .background(isSelected ? HE3Theme.gold.opacity(0.06) : HE3Theme.iron)
            .clipShape(.rect(cornerRadius: 0))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(isSelected ? HE3Theme.gold.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

struct CreditCardFormView: View {
    @Binding var isProcessing: Bool
    var onSubmit: () -> Void

    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvv: String = ""
    @State private var cardholderName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var addressLine1: String = ""
    @State private var addressLine2: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = "United States"
    @FocusState private var focusedField: CreditCardField?

    enum CreditCardField {
        case cardNumber, expiry, cvv, name, email, phone, address1, address2, city, state, zip
    }

    private var isFormValid: Bool {
        !cardNumber.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty &&
        !cardholderName.isEmpty && !email.isEmpty && !phone.isEmpty &&
        !addressLine1.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("CARD INFORMATION")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.gold)

            VStack(spacing: 0) {
                PaymentTextField(
                    placeholder: "Card Number",
                    text: $cardNumber,
                    icon: "creditcard",
                    keyboardType: .numberPad,
                    focused: $focusedField,
                    field: .cardNumber
                )

                Rectangle().fill(HE3Theme.steel).frame(height: 1)

                HStack(spacing: 0) {
                    PaymentTextField(
                        placeholder: "MM / YY",
                        text: $expiryDate,
                        icon: "calendar",
                        keyboardType: .numberPad,
                        focused: $focusedField,
                        field: .expiry
                    )

                    Rectangle().fill(HE3Theme.steel).frame(width: 1, height: 52)

                    PaymentTextField(
                        placeholder: "CVV",
                        text: $cvv,
                        icon: "lock",
                        keyboardType: .numberPad,
                        focused: $focusedField,
                        field: .cvv
                    )
                }
            }
            .background(HE3Theme.iron)
            .clipShape(.rect(cornerRadius: 0))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(HE3Theme.steel, lineWidth: 1)
            )

            Text("PERSONAL INFORMATION")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.gold)

            VStack(spacing: 0) {
                PaymentTextField(
                    placeholder: "Full Name",
                    text: $cardholderName,
                    icon: "person",
                    keyboardType: .default,
                    focused: $focusedField,
                    field: .name
                )

                Rectangle().fill(HE3Theme.steel).frame(height: 1)

                PaymentTextField(
                    placeholder: "Email Address",
                    text: $email,
                    icon: "envelope",
                    keyboardType: .emailAddress,
                    focused: $focusedField,
                    field: .email
                )

                Rectangle().fill(HE3Theme.steel).frame(height: 1)

                PaymentTextField(
                    placeholder: "Phone Number",
                    text: $phone,
                    icon: "phone",
                    keyboardType: .phonePad,
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

            Text("BILLING ADDRESS")
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.gold)

            VStack(spacing: 0) {
                PaymentTextField(
                    placeholder: "Address Line 1",
                    text: $addressLine1,
                    icon: "house",
                    keyboardType: .default,
                    focused: $focusedField,
                    field: .address1
                )

                Rectangle().fill(HE3Theme.steel).frame(height: 1)

                PaymentTextField(
                    placeholder: "Address Line 2 (Optional)",
                    text: $addressLine2,
                    icon: "building.2",
                    keyboardType: .default,
                    focused: $focusedField,
                    field: .address2
                )

                Rectangle().fill(HE3Theme.steel).frame(height: 1)

                PaymentTextField(
                    placeholder: "City",
                    text: $city,
                    icon: "mappin",
                    keyboardType: .default,
                    focused: $focusedField,
                    field: .city
                )

                Rectangle().fill(HE3Theme.steel).frame(height: 1)

                HStack(spacing: 0) {
                    PaymentTextField(
                        placeholder: "State",
                        text: $state,
                        icon: "map",
                        keyboardType: .default,
                        focused: $focusedField,
                        field: .state
                    )

                    Rectangle().fill(HE3Theme.steel).frame(width: 1, height: 52)

                    PaymentTextField(
                        placeholder: "ZIP",
                        text: $zipCode,
                        icon: "number",
                        keyboardType: .numberPad,
                        focused: $focusedField,
                        field: .zip
                    )
                }
            }
            .background(HE3Theme.iron)
            .clipShape(.rect(cornerRadius: 0))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(HE3Theme.steel, lineWidth: 1)
            )

            HStack(spacing: 6) {
                Image(systemName: "flag.fill")
                    .font(.caption2)
                    .foregroundStyle(HE3Theme.ashLight.opacity(0.5))
                Text(country.uppercased())
                    .font(BrandFont.mono(11))
                    .foregroundStyle(HE3Theme.ash)
            }
            .padding(.leading, 4)

            Button {
                focusedField = nil
                onSubmit()
            } label: {
                HStack(spacing: 10) {
                    if isProcessing {
                        ProgressView()
                            .tint(HE3Theme.background)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("PAY $297 \u{2192}")
                            .font(BrandFont.mono(13, weight: .medium))
                            .tracking(1)
                    }
                }
                .foregroundStyle(HE3Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(isFormValid ? HE3Theme.gold : HE3Theme.bone.opacity(0.15))
                .clipShape(.rect(cornerRadius: 0))
            }
            .disabled(!isFormValid || isProcessing)
            .sensoryFeedback(.impact(weight: .heavy), trigger: isProcessing)
        }
        .padding(.horizontal, 24)
    }
}

struct PaymentTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    let keyboardType: UIKeyboardType
    var focused: FocusState<CreditCardFormView.CreditCardField?>.Binding
    let field: CreditCardFormView.CreditCardField

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

    private var contentType: UITextContentType? {
        switch field {
        case .cardNumber: .creditCardNumber
        case .name: .name
        case .email: .emailAddress
        case .phone: .telephoneNumber
        case .address1: .streetAddressLine1
        case .address2: .streetAddressLine2
        case .city: .addressCity
        case .state: .addressState
        case .zip: .postalCode
        default: nil
        }
    }
}
