import Foundation
import SwiftUI

@Observable
@MainActor
class UserProgressViewModel {
    var hasCommitted = false
    var hasCompletedAssessment = false
    var hasPurchased = false
    var dominantVoice: Voice?
    var suppressedVoice: Voice?
    var assessmentScores: AssessmentScores?
    var assessmentProfile: AssessmentProfile?
    /// Day 0 baseline, captured on first assessment. The Re Calibration on Day 30
    /// reads this back so the man sees his spread fall and integration climb.
    var assessmentBaseline: AssessmentScores?
    var programStartDate: Date?
    var currentStreak: Int = 0
    var lastPracticeDate: String?
    var dailyLogs: [String: DailyPracticeLog] = [:]
    var manifesto: String = ""
    var completedSectionIDs: Set<String> = []

    /// God Mode / Owner Preview — when true, unlocks all pillars and bypasses the
    /// sign in wall and the paywall so the owner can review the whole app.
    /// In-memory only; resets when the app relaunches so it can't be left on accidentally.
    /// Controlled by AppConfig.ownerPreviewEnabled: when that flag is false (App Store
    /// build) godMode is permanently false and cannot be enabled by any path.
    private var _godMode: Bool = false
    var godMode: Bool {
        get { AppConfig.ownerPreviewEnabled && _godMode }
        set { _godMode = AppConfig.ownerPreviewEnabled ? newValue : false }
    }

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    var daysRemaining: Int {
        guard let start = programStartDate else { return 90 }
        let elapsed = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return max(0, 90 - elapsed)
    }

    var daysElapsed: Int {
        guard let start = programStartDate else { return 0 }
        return min(90, max(0, Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0))
    }

    var currentWeek: Int {
        let elapsed = daysElapsed
        return min(4, (elapsed / 7) + 1)
    }

    var currentPillar: PillarID {
        PillarID(rawValue: min(currentWeek, 4)) ?? .suppressed
    }

    var overallProgress: Double {
        Double(daysElapsed) / 90.0
    }

    var isProgramExpired: Bool {
        daysRemaining <= 0
    }

    var isInIntegrationPhase: Bool {
        daysElapsed > 30 && !isProgramExpired
    }

    func isPillarUnlocked(_ pillar: PillarID) -> Bool {
        if godMode { return true }
        return currentWeek >= pillar.week
    }

    func isSectionUnlocked(_ section: PillarSection, in pillar: PillarID) -> Bool {
        if godMode { return true }
        guard isPillarUnlocked(pillar) else { return false }
        guard let content = PillarContentStore.content[pillar],
              let idx = content.sections.firstIndex(where: { $0.id == section.id }) else {
            return false
        }
        if idx == 0 { return true }
        let previous = content.sections[idx - 1]
        return completedSectionIDs.contains(previous.id)
    }

    func isSectionCompleted(_ section: PillarSection) -> Bool {
        completedSectionIDs.contains(section.id)
    }

    func markSectionCompleted(_ section: PillarSection) {
        completedSectionIDs.insert(section.id)
        save()
    }

    func unmarkSectionCompleted(_ section: PillarSection) {
        completedSectionIDs.remove(section.id)
        save()
    }

    func completedSectionCount(for pillar: PillarID) -> Int {
        guard let content = PillarContentStore.content[pillar] else { return 0 }
        return content.sections.filter { completedSectionIDs.contains($0.id) }.count
    }

    func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func todayLog() -> DailyPracticeLog {
        let key = todayKey()
        return dailyLogs[key] ?? DailyPracticeLog(date: key, completedPracticeIDs: [])
    }

    func togglePractice(_ id: String) {
        let key = todayKey()
        var log = dailyLogs[key] ?? DailyPracticeLog(date: key, completedPracticeIDs: [])
        if log.completedPracticeIDs.contains(id) {
            log.completedPracticeIDs.remove(id)
        } else {
            log.completedPracticeIDs.insert(id)
        }
        dailyLogs[key] = log
        updateStreak()
        save()
    }

    func isPracticeCompleted(_ id: String) -> Bool {
        todayLog().completedPracticeIDs.contains(id)
    }

    /// The Signal Log silence gate. The Act Pass stays locked until a man has held
    /// the Quiet Bridge silence on this many separate days, so action is earned by
    /// the discipline of receiving first.
    static let silenceHabitThreshold = 7

    /// Distinct days the Quiet Bridge silence was held.
    var quietBridgeSessions: Int {
        dailyLogs.values.filter { $0.completedPracticeIDs.contains("quiet_bridge") }.count
    }

    var silenceHabitSet: Bool {
        quietBridgeSessions >= Self.silenceHabitThreshold
    }

    var todayCompletedCount: Int {
        todayLog().completedPracticeIDs.count
    }

    var todayTotalPractices: Int {
        PracticeData.allPractices.count
    }

    func commitToOath() {
        hasCommitted = true
        save()
    }

    func completeAssessment(scores: AssessmentScores) {
        hasCompletedAssessment = true
        let isFirstTake = assessmentBaseline == nil
        assessmentScores = scores
        assessmentProfile = scores.profile
        dominantVoice = scores.dominantVoice
        suppressedVoice = scores.suppressedVoice
        // First time through sets the day 0 baseline for the Re Calibration.
        if isFirstTake { assessmentBaseline = scores }
        save()
        AssessmentSync.persist(scores: scores, phase: isFirstTake ? "day0" : "day30")
    }

    var userName: String = ""
    var userEmail: String = ""
    var userPhone: String = ""

    func completePurchase() {
        hasPurchased = true
        programStartDate = Date()
        save()
        Task {
            let granted = await NotificationService.shared.requestPermission()
            if granted, let start = programStartDate {
                NotificationService.shared.scheduleSprintNotifications(from: start)
            }
        }
    }

    func saveContactInfo(name: String, email: String, phone: String) {
        userName = name
        userEmail = email
        userPhone = phone
        defaults.set(name, forKey: "he3_userName")
        defaults.set(email, forKey: "he3_userEmail")
        defaults.set(phone, forKey: "he3_userPhone")
    }

    var hasContactInfo: Bool {
        !userName.isEmpty && !userEmail.isEmpty && !userPhone.isEmpty
    }

    func saveManifesto(_ text: String) {
        manifesto = text
        save()
    }

    private func updateStreak() {
        let key = todayKey()
        if dailyLogs[key]?.completedPracticeIDs.isEmpty == false {
            if lastPracticeDate != key {
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let yesterdayKey = formatter.string(from: yesterday)
                if lastPracticeDate == yesterdayKey {
                    currentStreak += 1
                } else if lastPracticeDate != key {
                    currentStreak = 1
                }
                lastPracticeDate = key
            }
        }
    }

    func save() {
        defaults.set(hasCommitted, forKey: "he3_committed")
        defaults.set(hasCompletedAssessment, forKey: "he3_assessed")
        defaults.set(hasPurchased, forKey: "he3_purchased")
        defaults.set(dominantVoice?.rawValue, forKey: "he3_dominant")
        defaults.set(suppressedVoice?.rawValue, forKey: "he3_suppressed")
        defaults.set(assessmentProfile?.rawValue, forKey: "he3_profile")
        defaults.set(programStartDate, forKey: "he3_startDate")
        defaults.set(currentStreak, forKey: "he3_streak")
        defaults.set(lastPracticeDate, forKey: "he3_lastPractice")
        defaults.set(manifesto, forKey: "he3_manifesto")
        defaults.set(Array(completedSectionIDs), forKey: "he3_completedSections")
        if let data = try? encoder.encode(dailyLogs) {
            defaults.set(data, forKey: "he3_dailyLogs")
        }
        if let scoresData = try? encoder.encode(assessmentScores) {
            defaults.set(scoresData, forKey: "he3_scores")
        }
        if let baselineData = try? encoder.encode(assessmentBaseline) {
            defaults.set(baselineData, forKey: "he3_scores_day0")
        }
    }

    func load() {
        hasCommitted = defaults.bool(forKey: "he3_committed")
        hasCompletedAssessment = defaults.bool(forKey: "he3_assessed")
        hasPurchased = defaults.bool(forKey: "he3_purchased")
        if let raw = defaults.string(forKey: "he3_dominant") {
            dominantVoice = Voice(rawValue: raw)
        }
        if let raw = defaults.string(forKey: "he3_suppressed") {
            suppressedVoice = Voice(rawValue: raw)
        }
        if let raw = defaults.string(forKey: "he3_profile") {
            assessmentProfile = AssessmentProfile(rawValue: raw)
        }
        if let data = defaults.data(forKey: "he3_scores"),
           let scores = try? decoder.decode(AssessmentScores.self, from: data) {
            assessmentScores = scores
        }
        if let data = defaults.data(forKey: "he3_scores_day0"),
           let baseline = try? decoder.decode(AssessmentScores.self, from: data) {
            assessmentBaseline = baseline
        }
        programStartDate = defaults.object(forKey: "he3_startDate") as? Date
        currentStreak = defaults.integer(forKey: "he3_streak")
        lastPracticeDate = defaults.string(forKey: "he3_lastPractice")
        manifesto = defaults.string(forKey: "he3_manifesto") ?? ""
        if let arr = defaults.array(forKey: "he3_completedSections") as? [String] {
            completedSectionIDs = Set(arr)
        }
        userName = defaults.string(forKey: "he3_userName") ?? ""
        userEmail = defaults.string(forKey: "he3_userEmail") ?? ""
        userPhone = defaults.string(forKey: "he3_userPhone") ?? ""
        if let data = defaults.data(forKey: "he3_dailyLogs"),
           let logs = try? decoder.decode([String: DailyPracticeLog].self, from: data) {
            dailyLogs = logs
        }
    }
}
