import Foundation

struct AppConfig: Codable {
    var wakeTime: Date
    var bedTime: Date
    var winddownMinutes: Int
    var hasOnboarded: Bool = false
    var streakDays: Int = 0

    static let storageKey = "dayflow_config"

    static func load() -> AppConfig {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let config = try? JSONDecoder().decode(AppConfig.self, from: data) {
            return config
        }
        return AppConfig.defaultConfig
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: AppConfig.storageKey)
        }
    }

    static var defaultConfig: AppConfig {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let wake = cal.date(bySettingHour: 7, minute: 0, second: 0, of: today) ?? today
        let bed  = cal.date(bySettingHour: 22, minute: 0, second: 0, of: today) ?? today
        return AppConfig(wakeTime: wake, bedTime: bed, winddownMinutes: 30)
    }

    var wakeTimeString: String {
        wakeTime.formatted(.dateTime.hour().minute())
    }

    var bedTimeString: String {
        bedTime.formatted(.dateTime.hour().minute())
    }

    var winddownLabel: String {
        winddownMinutes >= 60 ? "\(winddownMinutes / 60)h" : "\(winddownMinutes)m"
    }
}
