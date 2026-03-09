import Foundation
import SwiftUI

struct DFTask: Identifiable, Codable {
    var id: UUID = UUID()
    var emoji: String
    var title: String
    var category: TaskCategory
    var startHour: Int       // 0–23
    var startMinute: Int     // 0–59
    var durationMinutes: Int
    var isDone: Bool = false
    var hasConflict: Bool = false
    var date: Date           // normalized to midnight

    var color: Color { category.color }

    var startTimeString: String {
        let period = startHour >= 12 ? "PM" : "AM"
        let display = startHour % 12 == 0 ? 12 : startHour % 12
        return "\(display):\(String(format: "%02d", startMinute)) \(period)"
    }

    var endTimeString: String {
        let total = startHour * 60 + startMinute + durationMinutes
        let h = (total / 60) % 24
        let m = total % 60
        let period = h >= 12 ? "PM" : "AM"
        let display = h % 12 == 0 ? 12 : h % 12
        return "\(display):\(String(format: "%02d", m)) \(period)"
    }

    var timeRangeString: String { "\(startTimeString) – \(endTimeString)" }

    var durationLabel: String {
        if durationMinutes < 60 { return "\(durationMinutes)m" }
        let h = durationMinutes / 60
        let m = durationMinutes % 60
        return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }

    var startDate: Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        c.hour = startHour
        c.minute = startMinute
        c.second = 0
        return Calendar.current.date(from: c) ?? date
    }
}

// MARK: - Preview Data
extension DFTask {
    static let previewTasks: [DFTask] = [
        DFTask(emoji: "🏃", title: "Morning Run",   category: .health,   startHour: 7,  startMinute: 0,  durationMinutes: 60,  isDone: true,  date: Date().normalizedToMidnight),
        DFTask(emoji: "👥", title: "Team Standup",  category: .work,     startHour: 10, startMinute: 0,  durationMinutes: 30,  isDone: true,  date: Date().normalizedToMidnight),
        DFTask(emoji: "📧", title: "Answer Emails", category: .work,     startHour: 9,  startMinute: 0,  durationMinutes: 30,  isDone: false, date: Date().normalizedToMidnight),
        DFTask(emoji: "🛒", title: "Go Shopping",   category: .personal, startHour: 17, startMinute: 0,  durationMinutes: 60,  isDone: false, date: Date().normalizedToMidnight),
        DFTask(emoji: "💪", title: "Gym Session",   category: .health,   startHour: 18, startMinute: 30, durationMinutes: 60,  isDone: false, hasConflict: true, date: Date().normalizedToMidnight),
    ]
}

// MARK: - Auto-Emoji
func autoEmoji(from title: String) -> String {
    let t = title.lowercased()
    if t.contains("email") || t.contains("mail")                   { return "📧" }
    if t.contains("meet") || t.contains("call") || t.contains("standup") { return "👥" }
    if t.contains("gym")  || t.contains("workout")                 { return "💪" }
    if t.contains("run")  || t.contains("jog")                     { return "🏃" }
    if t.contains("sleep") || t.contains("nap")                    { return "😴" }
    if t.contains("eat")  || t.contains("lunch") || t.contains("dinner") { return "🍕" }
    if t.contains("coffee") || t.contains("cafe")                  { return "☕" }
    if t.contains("shop") || t.contains("grocery")                 { return "🛒" }
    if t.contains("read") || t.contains("book")                    { return "📚" }
    if t.contains("music") || t.contains("playlist")               { return "🎵" }
    if t.contains("code") || t.contains("build")                   { return "💻" }
    if t.contains("drive") || t.contains("car")                    { return "🚗" }
    if t.contains("yoga") || t.contains("meditat")                 { return "🧘" }
    if t.contains("travel") || t.contains("flight")                { return "✈️" }
    if t.contains("doctor") || t.contains("health")                { return "❤️" }
    if t.contains("movie") || t.contains("watch")                  { return "🎬" }
    if t.contains("home") || t.contains("clean")                   { return "🏠" }
    if t.contains("money") || t.contains("pay")                    { return "💰" }
    if t.contains("plan") || t.contains("report")                  { return "📊" }
    return "🎯"
}
