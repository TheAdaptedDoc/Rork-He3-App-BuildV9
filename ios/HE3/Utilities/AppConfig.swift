import Foundation

/// App wide switches.
enum AppConfig {
    /// OWNER PREVIEW / GOD ACCESS.
    /// When true, an owner can bypass the Apple and Google sign in wall and the
    /// paywall to walk the entire app as a fully entitled user, for review.
    ///
    /// WARNING. This is a backdoor. Set it to FALSE before you submit to the App
    /// Store. Shipping it true means anyone who finds the entry can unlock the
    /// program for free, and Apple may reject a build with an undocumented bypass.
    static let ownerPreviewEnabled = true
}
