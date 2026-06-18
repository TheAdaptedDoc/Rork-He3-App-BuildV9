import SwiftUI

/// Retained for compatibility. The purchase path is now the Locked screen, which
/// links out to web checkout. The app never processes payment in app.
struct PurchaseFlowWrapper: View {
    var progress: UserProgressViewModel
    var body: some View { LockedProgramView() }
}
