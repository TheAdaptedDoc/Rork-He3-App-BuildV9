import Foundation
import UserNotifications

@MainActor
class NotificationService {
    static let shared = NotificationService()

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }

    func scheduleSprintNotifications(from startDate: Date) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let dailyMessages: [(Int, String, String)] = [
            (1, "Day 1 — The Sprint Begins", "You now have 90 days. The men who transform start immediately."),
            (2, "Day 2 — Show Up Again", "Consistency isn't motivation. It's identity."),
            (3, "Day 3 — Stay in the Work", "You didn't commit to feel comfortable. You committed to grow."),
            (4, "Day 4 — The Ego Speaks", "Notice which voice is loudest today. That's your signal."),
            (5, "Day 5 — Midweek Check", "Five days in. You're building something most men never will."),
            (6, "Day 6 — Prepare for Integration", "Tomorrow you level up. Rest with intention tonight."),
            (7, "Day 7 — Week 1 Complete", "Pillar One is behind you. Pillar Two awaits. Keep moving."),
            (14, "Week 2 Complete", "Halfway through the sprint. The Awakening is taking hold."),
            (21, "Week 3 Complete", "Integration is underway. You're becoming the man you designed."),
            (28, "Week 4 — The Rising", "The final pillar. This is where identity solidifies."),
            (30, "Sprint Complete", "30 days. You did what most men talk about. Now integrate."),
            (45, "Day 45 — Integration Phase", "Keep practicing. Repetition is how identity locks in."),
            (60, "Day 60 — Two Months In", "60 days of discipline. The old you wouldn't recognize this man."),
            (75, "15 Days Remaining", "Your access closes in 15 days. Finish what you started."),
            (85, "5 Days Remaining", "Access expires in 5 days. Complete any remaining work now."),
            (89, "Final Day Tomorrow", "Tomorrow your access closes. Make it count."),
        ]

        for (day, title, body) in dailyMessages {
            guard let triggerDate = Calendar.current.date(byAdding: .day, value: day, to: startDate) else { continue }

            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
            dateComponents.hour = 8
            dateComponents.minute = 0

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "sprint_day_\(day)", content: content, trigger: trigger)
            center.add(request)
        }

        for day in [8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 22, 23, 24, 25, 26, 27, 29] {
            guard let triggerDate = Calendar.current.date(byAdding: .day, value: day, to: startDate) else { continue }

            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
            dateComponents.hour = 8
            dateComponents.minute = 0

            let content = UNMutableNotificationContent()
            content.title = "HE\u{00B3} Daily Practice"
            content.body = "Your practices are waiting. Discipline doesn't yell. It tracks."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "sprint_day_\(day)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
