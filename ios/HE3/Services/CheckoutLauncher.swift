import UIKit

/// The app never processes payment. To unlock, it opens the system browser to
/// the Stripe web checkout, passing the Supabase user id so the webhook can match
/// the man to his purchase. This is the only purchase path in the app.
enum CheckoutLauncher {
    static let base = "https://checkout.theintegratedman.com"

    static func openCheckout(uid: String?) {
        var urlString = base
        if let uid, !uid.isEmpty {
            var comps = URLComponents(string: base)
            comps?.queryItems = [URLQueryItem(name: "uid", value: uid)]
            urlString = comps?.url?.absoluteString ?? base
        }
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    /// The Standard continuity tier, sold on web or via an in app link out.
    static func openStandard(uid: String?) {
        guard let url = URL(string: "\(base)/standard\(uid.map { "?uid=\($0)" } ?? "")") else { return }
        UIApplication.shared.open(url)
    }
}
