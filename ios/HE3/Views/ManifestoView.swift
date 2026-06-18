import SwiftUI

struct ManifestoView: View {
    var progress: UserProgressViewModel
    @State private var text: String = ""
    @State private var isSaved = false
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR LIVING BLUEPRINT")
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.gold)

                        Text("WRITE YOUR MANIFESTO")
                            .font(BrandFont.display(30))
                            .foregroundStyle(HE3Theme.textPrimary)

                        Text("All three voices have seats at the table. Your manifesto becomes your integrated identity.")
                            .font(BrandFont.body(15, weight: .light))
                            .foregroundStyle(HE3Theme.ash)
                            .lineSpacing(3)
                    }

                    TextEditor(text: $text)
                        .font(.body)
                        .foregroundStyle(HE3Theme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 400)
                        .focused($isFocused)
                        .padding(16)
                        .background(HE3Theme.iron)
                        .clipShape(.rect(cornerRadius: 0))
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(HE3Theme.steel, lineWidth: 1)
                        )

                    Button {
                        progress.saveManifesto(text)
                        isSaved = true
                        isFocused = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isSaved = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isSaved {
                                Image(systemName: "checkmark")
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            Text(isSaved ? "SAVED" : "SAVE MANIFESTO \u{2192}")
                                .font(BrandFont.mono(13, weight: .medium))
                                .tracking(1)
                        }
                        .foregroundStyle(HE3Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(HE3Theme.gold)
                        .clipShape(.rect(cornerRadius: 0))
                    }
                    .sensoryFeedback(.success, trigger: isSaved)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Manifesto")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
        .onAppear {
            text = progress.manifesto
        }
    }
}
