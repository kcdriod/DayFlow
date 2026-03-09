import SwiftUI

struct HourRowView: View {
    let hour: Int
    let tasks: [DFTask]
    let isCurrentHour: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Hour label
            Text(hourLabel)
                .font(.system(size: 12))
                .foregroundStyle(isCurrentHour ? Color.coral : Color.textQuart)
                .frame(width: 44, alignment: .trailing)
                .padding(.top, 8)

            ZStack(alignment: .topLeading) {
                // Hour separator line
                Rectangle()
                    .fill(Color.surface3)
                    .frame(height: 0.5)
                    .padding(.top, 8)

                // Current time indicator
                if isCurrentHour {
                    currentTimeLine
                }

                // Task blocks
                if !tasks.isEmpty {
                    VStack(spacing: 4) {
                        ForEach(tasks) { task in
                            TaskBlockView(task: task)
                        }
                    }
                    .padding(.top, 12)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minHeight: 56)
    }

    var hourLabel: String {
        if hour == 0  { return "12 AM" }
        if hour < 12  { return "\(hour) AM" }
        if hour == 12 { return "12 PM" }
        return "\(hour - 12) PM"
    }

    var currentTimeLine: some View {
        let minutes = Calendar.current.component(.minute, from: Date())
        let offset  = CGFloat(minutes) / 60.0 * 56.0

        return HStack(spacing: 0) {
            Circle()
                .fill(Color.coral)
                .frame(width: 8, height: 8)
            Rectangle()
                .fill(Color.coral)
                .frame(height: 2)
        }
        .shadow(color: .coral.opacity(0.5), radius: 4)
        .offset(y: offset)
    }
}

struct TaskBlockView: View {
    let task: DFTask
    let heightPerMinute: CGFloat = 56.0 / 60.0

    var blockHeight: CGFloat {
        max(CGFloat(task.durationMinutes) * heightPerMinute, 44)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(task.emoji)
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(task.isDone ? Color.textQuart : .white)
                    .strikethrough(task.isDone)
                    .lineLimit(1)
                Text(task.timeRangeString)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textTert)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: blockHeight, alignment: .topLeading)
        .background(task.color.opacity(0.13))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(task.color, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(task.isDone ? 0.5 : 1.0)
    }
}
