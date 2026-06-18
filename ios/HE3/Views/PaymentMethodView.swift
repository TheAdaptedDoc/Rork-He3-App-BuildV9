import SwiftUI

/// Deprecated. In app payment was removed to comply with the build spec: the app
/// never processes payment. Retained as a thin redirect so any stray reference
/// still routes to the compliant web checkout. Safe to delete from the target.
struct PaymentMethodView: View {
    var progress: UserProgressViewModel
    var onPurchaseComplete: () -> Void = {}

    var body: some View {
        PurchaseView(progress: progress, onPurchaseComplete: onPurchaseComplete)
    }
}
