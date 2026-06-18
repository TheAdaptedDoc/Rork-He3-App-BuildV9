import SwiftUI

// MARK: - Models

struct AdminMember: Identifiable, Hashable {
    let id: UUID
    let fullName: String
    let username: String
    let email: String
    let purchaseDate: Date
    let accessDurationDays: Int
    /// Number of days the member has actively used the app within their access window.
    let activeDays: Int
    /// Average minutes spent in app per day (over their access window so far).
    let avgDailyMinutes: Double

    var accessEndsDate: Date {
        Calendar.current.date(byAdding: .day, value: accessDurationDays, to: purchaseDate) ?? purchaseDate
    }

    var daysSincePurchase: Int {
        max(0, Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 0)
    }

    var elapsedDaysInProgram: Int {
        min(accessDurationDays, daysSincePurchase)
    }

    /// 0.0 ... 1.0 — how engaged the member is across their elapsed program time.
    var activityLevel: Double {
        guard elapsedDaysInProgram > 0 else { return 0 }
        return min(1.0, Double(activeDays) / Double(elapsedDaysInProgram))
    }

    var activityLabel: String {
        switch activityLevel {
        case 0.75...: return "HIGH"
        case 0.4..<0.75: return "MEDIUM"
        case 0.01..<0.4: return "LOW"
        default: return "INACTIVE"
        }
    }

    var activityColor: Color {
        switch activityLevel {
        case 0.75...: return HE3Theme.gold
        case 0.4..<0.75: return .orange
        case 0.01..<0.4: return .red.opacity(0.8)
        default: return HE3Theme.steel
        }
    }

    var isExpired: Bool {
        Date() > accessEndsDate
    }
}

// MARK: - Sample / Local Data Source

enum AdminMemberStore {
    static let members: [AdminMember] = {
        let cal = Calendar.current
        func date(daysAgo: Int) -> Date {
            cal.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        }
        return [
            AdminMember(id: UUID(), fullName: "Marcus Hale", username: "marcus.h", email: "marcus@hale.co", purchaseDate: date(daysAgo: 28), accessDurationDays: 30, activeDays: 26, avgDailyMinutes: 34.2),
            AdminMember(id: UUID(), fullName: "Daniel Kovac", username: "dkovac", email: "daniel.kovac@gmail.com", purchaseDate: date(daysAgo: 19), accessDurationDays: 30, activeDays: 14, avgDailyMinutes: 22.5),
            AdminMember(id: UUID(), fullName: "Andre Bishop", username: "andre_b", email: "andre.bishop@proton.me", purchaseDate: date(daysAgo: 12), accessDurationDays: 30, activeDays: 11, avgDailyMinutes: 41.7),
            AdminMember(id: UUID(), fullName: "Theo Marchetti", username: "theom", email: "theo@marchetti.io", purchaseDate: date(daysAgo: 7), accessDurationDays: 30, activeDays: 6, avgDailyMinutes: 28.0),
            AdminMember(id: UUID(), fullName: "Owen Pritchard", username: "owenp", email: "owen.p@outlook.com", purchaseDate: date(daysAgo: 22), accessDurationDays: 30, activeDays: 9, avgDailyMinutes: 12.4),
            AdminMember(id: UUID(), fullName: "Caleb Roy", username: "caleb.roy", email: "caleb@royhouse.co", purchaseDate: date(daysAgo: 3), accessDurationDays: 30, activeDays: 3, avgDailyMinutes: 47.1),
            AdminMember(id: UUID(), fullName: "Nikolai Petrov", username: "n.petrov", email: "nik@petrov.dev", purchaseDate: date(daysAgo: 31), accessDurationDays: 30, activeDays: 22, avgDailyMinutes: 19.8),
            AdminMember(id: UUID(), fullName: "Elias Romero", username: "eli.r", email: "elias.romero@me.com", purchaseDate: date(daysAgo: 15), accessDurationDays: 30, activeDays: 13, avgDailyMinutes: 36.6),
            AdminMember(id: UUID(), fullName: "Jordan Vasquez", username: "jvasquez", email: "jordan@vasquez.studio", purchaseDate: date(daysAgo: 9), accessDurationDays: 30, activeDays: 2, avgDailyMinutes: 6.3),
            AdminMember(id: UUID(), fullName: "Samir Khan", username: "samir.k", email: "samir.khan@yahoo.com", purchaseDate: date(daysAgo: 25), accessDurationDays: 30, activeDays: 24, avgDailyMinutes: 52.9),
            AdminMember(id: UUID(), fullName: "Leon Wexler", username: "lwexler", email: "leon@wexlerco.com", purchaseDate: date(daysAgo: 5), accessDurationDays: 30, activeDays: 5, avgDailyMinutes: 31.0),
            AdminMember(id: UUID(), fullName: "Hayden Cross", username: "haydenx", email: "hayden.cross@icloud.com", purchaseDate: date(daysAgo: 17), accessDurationDays: 30, activeDays: 8, avgDailyMinutes: 14.7),
        ]
    }()
}

// MARK: - Admin Code Sheet

struct AdminCodeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var code: String = ""
    @State private var error: String?
    @FocusState private var focused: Bool

    /// Default admin passcode. Change here to rotate.
    static let adminCode = "444999"

    var onUnlock: () -> Void

    var body: some View {
        ZStack {
            HE3Theme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title)
                        .foregroundStyle(HE3Theme.gold)

                    Text("ADMIN ACCESS")
                        .font(BrandFont.mono(11, weight: .medium))
                        .tracking(3)
                        .foregroundStyle(HE3Theme.bone.opacity(0.6))

                    Text("Enter 6-digit code")
                        .font(BrandFont.display(22))
                        .foregroundStyle(HE3Theme.textPrimary)
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
        if code == Self.adminCode {
            onUnlock()
            dismiss()
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                error = "Invalid code"
            }
            code = ""
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

// MARK: - Admin Portal

struct AdminPortalView: View {
    @Environment(\.dismiss) private var dismiss

    enum SortOption: String, CaseIterable, Identifiable {
        case recent = "RECENT"
        case activity = "ACTIVITY"
        case expiring = "EXPIRING"
        case name = "NAME"
        var id: String { rawValue }
    }

    @State private var sort: SortOption = .recent
    @State private var search: String = ""

    private var members: [AdminMember] {
        let base = AdminMemberStore.members
        let filtered = search.isEmpty
            ? base
            : base.filter {
                $0.fullName.localizedCaseInsensitiveContains(search) ||
                $0.username.localizedCaseInsensitiveContains(search) ||
                $0.email.localizedCaseInsensitiveContains(search)
            }
        switch sort {
        case .recent:
            return filtered.sorted { $0.purchaseDate > $1.purchaseDate }
        case .activity:
            return filtered.sorted { $0.activityLevel > $1.activityLevel }
        case .expiring:
            return filtered.sorted { $0.accessEndsDate < $1.accessEndsDate }
        case .name:
            return filtered.sorted { $0.fullName < $1.fullName }
        }
    }

    private var totalActive: Int {
        AdminMemberStore.members.filter { !$0.isExpired }.count
    }

    private var avgActivity: Double {
        let vals = AdminMemberStore.members.map(\.activityLevel)
        guard !vals.isEmpty else { return 0 }
        return vals.reduce(0, +) / Double(vals.count)
    }

    private var avgMinutes: Double {
        let vals = AdminMemberStore.members.map(\.avgDailyMinutes)
        guard !vals.isEmpty else { return 0 }
        return vals.reduce(0, +) / Double(vals.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    statsRow

                    sortRow

                    LazyVStack(spacing: 8) {
                        ForEach(members) { member in
                            NavigationLink(value: member) {
                                AdminMemberRow(member: member)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .searchable(text: $search, prompt: "Search members")
            .background(HE3Theme.background)
            .navigationTitle("Admin Portal")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("DONE")
                            .font(BrandFont.mono(11, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(HE3Theme.gold)
                    }
                }
            }
            .navigationDestination(for: AdminMember.self) { member in
                AdminMemberDetailView(member: member)
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            adminStat(value: "\(totalActive)", label: "ACTIVE")
            adminStat(value: "\(Int(avgActivity * 100))%", label: "AVG ENGAGE")
            adminStat(value: String(format: "%.0f", avgMinutes), label: "AVG MIN/DAY")
        }
    }

    private func adminStat(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(BrandFont.display(24))
                .foregroundStyle(HE3Theme.textPrimary)
            Text(label)
                .font(BrandFont.mono(8, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }

    private var sortRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SortOption.allCases) { opt in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { sort = opt }
                    } label: {
                        Text(opt.rawValue)
                            .font(BrandFont.mono(10, weight: .medium))
                            .tracking(2)
                            .foregroundStyle(sort == opt ? HE3Theme.background : HE3Theme.bone)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(sort == opt ? HE3Theme.gold : HE3Theme.iron)
                            .clipShape(.rect(cornerRadius: 0))
                    }
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }
}

// MARK: - Row

struct AdminMemberRow: View {
    let member: AdminMember

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(HE3Theme.steel.opacity(0.5))
                Text(initials(for: member.fullName))
                    .font(BrandFont.display(14))
                    .foregroundStyle(HE3Theme.gold)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(member.fullName)
                    .font(BrandFont.body(15, weight: .medium))
                    .foregroundStyle(HE3Theme.textPrimary)
                Text("@\(member.username)")
                    .font(BrandFont.mono(10))
                    .foregroundStyle(HE3Theme.bone.opacity(0.55))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(member.activityLabel)
                    .font(BrandFont.mono(9, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(member.activityColor)
                Text(member.isExpired ? "EXPIRED" : "\(daysRemaining)D LEFT")
                    .font(BrandFont.mono(9))
                    .foregroundStyle(HE3Theme.bone.opacity(0.45))
            }
        }
        .padding(14)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }

    private var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: member.accessEndsDate).day ?? 0)
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}

// MARK: - Detail

struct AdminMemberDetailView: View {
    let member: AdminMember

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header

                infoCard

                metricsGrid
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(HE3Theme.background)
        .navigationTitle(member.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.light, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(HE3Theme.steel.opacity(0.5))
                Text(initials)
                    .font(BrandFont.display(28))
                    .foregroundStyle(HE3Theme.gold)
            }
            .frame(width: 72, height: 72)

            Text(member.fullName)
                .font(BrandFont.display(24))
                .foregroundStyle(HE3Theme.textPrimary)

            Text("@\(member.username)")
                .font(BrandFont.mono(11))
                .foregroundStyle(HE3Theme.bone.opacity(0.6))

            Text(member.activityLabel)
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(member.activityColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(member.activityColor.opacity(0.12))
                .clipShape(.rect(cornerRadius: 0))
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(label: "EMAIL", value: member.email)
            Divider().background(HE3Theme.steel.opacity(0.4))
            infoRow(label: "PURCHASED", value: dateFormatter.string(from: member.purchaseDate))
            Divider().background(HE3Theme.steel.opacity(0.4))
            infoRow(label: "ACCESS ENDS", value: dateFormatter.string(from: member.accessEndsDate))
            Divider().background(HE3Theme.steel.opacity(0.4))
            infoRow(label: "STATUS", value: member.isExpired ? "Expired" : "Active")
        }
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))
            Spacer()
            Text(value)
                .font(BrandFont.body(14, weight: .medium))
                .foregroundStyle(HE3Theme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var metricsGrid: some View {
        VStack(spacing: 8) {
            metricCard(
                title: "ACTIVITY LEVEL",
                value: "\(Int(member.activityLevel * 100))%",
                detail: "\(member.activeDays) of \(member.elapsedDaysInProgram) days active",
                tint: member.activityColor,
                progress: member.activityLevel
            )

            metricCard(
                title: "AVG TIME / DAY",
                value: String(format: "%.1f min", member.avgDailyMinutes),
                detail: "Across full access window",
                tint: HE3Theme.gold,
                progress: min(1.0, member.avgDailyMinutes / 60.0)
            )

            metricCard(
                title: "PROGRAM PROGRESS",
                value: "Day \(member.elapsedDaysInProgram) of \(member.accessDurationDays)",
                detail: member.isExpired ? "Window closed" : "In progress",
                tint: HE3Theme.gold,
                progress: Double(member.elapsedDaysInProgram) / Double(member.accessDurationDays)
            )
        }
    }

    private func metricCard(title: String, value: String, detail: String, tint: Color, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(BrandFont.mono(10, weight: .medium))
                .tracking(2)
                .foregroundStyle(HE3Theme.bone.opacity(0.5))

            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(BrandFont.display(22))
                    .foregroundStyle(HE3Theme.textPrimary)
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(HE3Theme.steel)
                        .frame(height: 3)
                    Rectangle()
                        .fill(tint)
                        .frame(width: geo.size.width * max(0, min(1, progress)), height: 3)
                }
            }
            .frame(height: 3)

            Text(detail)
                .font(BrandFont.body(12, weight: .light))
                .foregroundStyle(HE3Theme.bone.opacity(0.65))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HE3Theme.iron)
        .clipShape(.rect(cornerRadius: 0))
    }

    private var initials: String {
        let parts = member.fullName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }
}
