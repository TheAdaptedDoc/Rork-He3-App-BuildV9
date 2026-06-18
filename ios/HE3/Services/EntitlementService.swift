import Foundation
import Supabase

/// The single source of access truth, read from the server. Same entitlement the
/// 30 day sprint and the lesson streams gate on. get_entitlement() returns a
/// single row table, so we decode an array and take the first.
nonisolated struct Entitlement: Codable, Sendable, Equatable {
    var programAccess: Bool
    var accessEnd: Date?
    var standardActive: Bool
    var brotherhoodActive: Bool

    enum CodingKeys: String, CodingKey {
        case programAccess = "program_access"
        case accessEnd = "access_end"
        case standardActive = "standard_active"
        case brotherhoodActive = "brotherhood_active"
    }

    static let locked = Entitlement(
        programAccess: false, accessEnd: nil,
        standardActive: false, brotherhoodActive: false
    )
}

/// The three gating states from the App Build Spec.
enum AccessState: Equatable {
    case fullProgram      // program_access and within the window
    case dailyPracticeOnly // expired but The Standard is active
    case locked           // nothing active
}

@Observable
@MainActor
final class EntitlementService {
    static let shared = EntitlementService()
    private init() {}

    private(set) var current: Entitlement = .locked
    private(set) var lastChecked: Date?

    /// Call on launch and whenever the app returns to the foreground.
    /// Any failure falls back to locked, so a failed check never grants access.
    func refresh() async {
        guard AuthManager.shared.isSignedIn else {
            current = .locked
            return
        }
        do {
            let rows: [Entitlement] = try await SupabaseService.client
                .rpc("get_entitlement")
                .execute()
                .value
            current = rows.first ?? .locked
            lastChecked = Date()
        } catch {
            current = .locked
        }
    }

    var hasProgramAccess: Bool {
        guard current.programAccess else { return false }
        if let end = current.accessEnd { return end > Date() }
        return true
    }

    var state: AccessState {
        if hasProgramAccess { return .fullProgram }
        if current.standardActive { return .dailyPracticeOnly }
        return .locked
    }
}
