import SwiftUI

struct TimelineView: View {
    @Environment(TaskStore.self) private var store

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var showCalendar  = false

    private let days = Date.next7Days()
    private let hours = Array(6...23)

    var currentHour: Int { Calendar.current.component(.hour, from: Date()) }

    var selectedDateSubtitle: String {
        if selectedDate.isToday() { return "Today" }
        return selectedDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    var taskDatesThisWeek: Set<Date> {
        store.dates(withTasks: days)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 16)

            if showCalendar {
                MiniCalendarView(selectedDate: $selectedDate, taskDates: taskDatesThisWeek)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
            }

            DateStripView(selectedDate: $selectedDate, days: days)
                .padding(.vertical, 12)

            Divider().background(Color.surface3)

            scrollArea
        }
        .background(Color.black)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showCalendar)
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Timeline")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                Text(selectedDateSubtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTert)
            }
            Spacer()
            Button {
                withAnimation { showCalendar.toggle() }
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(showCalendar ? Color.coral : Color.textSec)
                    .frame(width: 36, height: 36)
                    .background(showCalendar ? Color.coral.opacity(0.15) : Color.surface1)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    var scrollArea: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(hours, id: \.self) { hour in
                    HourRowView(
                        hour: hour,
                        tasks: store.tasks(startingAt: hour, for: selectedDate),
                        isCurrentHour: hour == currentHour && selectedDate.isToday()
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .padding(.bottom, 20)
        }
    }
}
