import SwiftUI

struct PurchaseFlowWrapper: View {
    var progress: UserProgressViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            PurchaseView(progress: progress, onPurchaseComplete: {
                dismiss()
            })
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(HE3Theme.bone.opacity(0.6))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
