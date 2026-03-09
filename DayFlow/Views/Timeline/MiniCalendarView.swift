import SwiftUI

struct MiniCalendarView: View {
    @Binding var selectedDate: Date
    let taskDates: Set<Date>

    @State private var displayMonth: Date = Calendar.current.startOfDay(for: Date())

    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            // Month header
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        displayMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayMonth) ?? displayMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textTert)
                        .frame(width: 32, height: 32)
                }

                Spacer()

                Text(displayMonth.monthYearString)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        displayMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayMonth) ?? displayMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textTert)
                        .frame(width: 32, height: 32)
                }
            }

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdaySymbols, id: \.self) { sym in
                    Text(sym)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.textQuart)
                        .frame(height: 24)
                }
            }

            // Day grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(Date.daysInMonth(for: displayMonth).enumerated()), id: \.offset) { _, date in
                    if let d = date {
                        dayCell(d)
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
        }
        .padding(16)
        .surfaceCard(radius: 20)
    }

    @ViewBuilder
    func dayCell(_ date: Date) -> some View {
        let cal = Calendar.current
        let isToday    = date.isToday()
        let isSelected = date.isSameDay(as: selectedDate)
        let isThisMonth = cal.component(.month, from: date) == cal.component(.month, from: displayMonth)
        let hasTasks   = taskDates.contains(where: { $0.isSameDay(as: date) })

        Button {
            withAnimation(.spring(response: 0.2)) {
                selectedDate = date
            }
        } label: {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.coral)
                        .coralShadow(radius: 6, y: 3)
                } else if isSelected {
                    Circle()
                        .fill(Color.coral.opacity(0.2))
                        .overlay(Circle().strokeBorder(Color.coral, lineWidth: 1.5))
                }

                VStack(spacing: 2) {
                    Text("\(date.dayNumber)")
                        .font(.system(size: 14, weight: isToday || isSelected ? .bold : .medium))
                        .foregroundStyle(
                            isToday ? .white :
                            isSelected ? Color.coral :
                            isThisMonth ? Color.white : Color.textQuart
                        )

                    if hasTasks && !isToday {
                        Circle()
                            .fill(Color.coral)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .frame(height: 36)
        }
        .buttonStyle(.plain)
        .opacity(isThisMonth ? 1 : 0.25)
    }
}
