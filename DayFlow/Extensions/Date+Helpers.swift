import Foundation

extension Date {
    var normalizedToMidnight: Date {
        Calendar.current.startOfDay(for: self)
    }

    var dayAbbreviation: String {
        formatted(.dateTime.weekday(.abbreviated))
    }

    var dayNumber: Int {
        Calendar.current.component(.day, from: self)
    }

    var monthYearString: String {
        formatted(.dateTime.month(.wide).year())
    }

    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    var formattedTime: String {
        formatted(.dateTime.hour().minute())
    }

    var formattedShortDate: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInTomorrow(self) { return "Tomorrow" }
        return formatted(.dateTime.weekday(.abbreviated).month().day())
    }

    static func next7Days() -> [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: today) }
    }

    static func daysInMonth(for date: Date) -> [Date?] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: date),
              let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: date)) else {
            return []
        }
        let weekdayOffset = (cal.component(.weekday, from: firstDay) - cal.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: weekdayOffset)
        for day in range {
            days.append(cal.date(byAdding: .day, value: day - 1, to: firstDay))
        }
        return days
    }
}
