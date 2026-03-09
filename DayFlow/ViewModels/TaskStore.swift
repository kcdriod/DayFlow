import Foundation
import Observation
import UserNotifications

struct ToastMessage: Identifiable {
    var id = UUID()
    var icon: String
    var title: String
    var message: String
}

@Observable
final class TaskStore {
    var tasks: [DFTask] = []
    var config: AppConfig = .defaultConfig
    var toast: ToastMessage? = nil

    private let tasksKey = "dayflow_tasks"

    init() {
        config = AppConfig.load()
        loadTasks()
    }

    // MARK: - CRUD

    func addTask(_ task: DFTask) {
        tasks.append(task)
        detectConflicts()
        saveTasks()
        showToast(icon: "✅", title: "Task Added", message: task.title)
        scheduleTaskNotification(task)
    }

    func toggleDone(_ id: UUID) {
        guard let idx = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[idx].isDone.toggle()
        if tasks[idx].isDone {
            showToast(icon: "🎉", title: "Task Done!", message: tasks[idx].title)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        saveTasks()
    }

    func deleteTask(_ id: UUID) {
        tasks.removeAll { $0.id == id }
        detectConflicts()
        saveTasks()
    }

    func updateConfig(_ newConfig: AppConfig) {
        config = newConfig
        config.save()
        scheduleAlarmNotifications()
    }

    // MARK: - Queries

    func tasks(for date: Date) -> [DFTask] {
        tasks
            .filter { $0.date.isSameDay(as: date) }
            .sorted { $0.startHour * 60 + $0.startMinute < $1.startHour * 60 + $1.startMinute }
    }

    func tasks(startingAt hour: Int, for date: Date) -> [DFTask] {
        tasks(for: date).filter { $0.startHour == hour }
    }

    var todayTasks: [DFTask]  { tasks(for: Date()) }
    var todayDone:  Int       { todayTasks.filter { $0.isDone }.count }
    var todayTotal: Int       { todayTasks.count }
    var todayScore: Double    { todayTotal > 0 ? Double(todayDone) / Double(todayTotal) : 0 }

    func dates(withTasks range: [Date]) -> Set<Date> {
        Set(range.filter { d in tasks.contains { $0.date.isSameDay(as: d) } })
    }

    // MARK: - Conflict Detection

    func detectConflicts() {
        for i in tasks.indices { tasks[i].hasConflict = false }
        for i in tasks.indices {
            let a = tasks[i]
            let aS = a.startHour * 60 + a.startMinute
            let aE = aS + a.durationMinutes
            for j in tasks.indices where i != j {
                let b = tasks[j]
                guard a.date.isSameDay(as: b.date) else { continue }
                let bS = b.startHour * 60 + b.startMinute
                let bE = bS + b.durationMinutes
                if aS < bE && aE > bS { tasks[i].hasConflict = true }
            }
        }
    }

    // MARK: - Persistence

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([DFTask].self, from: data) {
            tasks = decoded
        } else {
            tasks = DFTask.previewTasks
        }
        detectConflicts()
    }

    // MARK: - Toast

    func showToast(icon: String, title: String, message: String) {
        toast = ToastMessage(icon: icon, title: title, message: message)
    }

    // MARK: - Notifications

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func scheduleAlarmNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dayflow-alarm", "dayflow-winddown"])

        let wakeContent = UNMutableNotificationContent()
        wakeContent.title = "Rise & shine! 🌅"
        wakeContent.body  = "You have \(todayTotal) tasks planned today"
        wakeContent.sound = .default

        let wakeCal = Calendar.current.dateComponents([.hour, .minute], from: config.wakeTime)
        let wakeTrigger = UNCalendarNotificationTrigger(dateMatching: wakeCal, repeats: true)
        center.add(UNNotificationRequest(identifier: "dayflow-alarm", content: wakeContent, trigger: wakeTrigger))

        let windContent = UNMutableNotificationContent()
        windContent.title = "Wind down time 🌙"
        windContent.body  = "Bedtime in \(config.winddownLabel)"
        windContent.sound = .default

        let windTime = config.bedTime.addingTimeInterval(Double(-config.winddownMinutes * 60))
        let windCal  = Calendar.current.dateComponents([.hour, .minute], from: windTime)
        let windTrigger = UNCalendarNotificationTrigger(dateMatching: windCal, repeats: true)
        center.add(UNNotificationRequest(identifier: "dayflow-winddown", content: windContent, trigger: windTrigger))
    }

    private func scheduleTaskNotification(_ task: DFTask) {
        let content = UNMutableNotificationContent()
        content.title = "\(task.emoji) Time for: \(task.title)"
        content.body  = "Scheduled for \(task.durationLabel)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.startDate),
            repeats: false
        )
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "task-\(task.id)", content: content, trigger: trigger)
        )
    }
}
