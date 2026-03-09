import SwiftUI

struct TaskRowView: View {
    let task: DFTask
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Emoji badge
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(task.color.opacity(0.15))
                    .frame(width: 46, height: 46)
                Text(task.emoji)
                    .font(.system(size: 22))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(task.color.opacity(0.3), lineWidth: 1)
            )

            // Title + time
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(task.isDone ? Color.textQuart : .white)
                    .strikethrough(task.isDone, color: .textQuart)
                HStack(spacing: 6) {
                    Text(task.timeRangeString)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textTert)
                    if task.hasConflict {
                        Text("⚠️")
                            .font(.system(size: 10))
                    }
                }
            }

            Spacer()

            // Toggle button
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(task.isDone ? Color.catHealth : Color.surface3, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if task.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.catHealth)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .opacity(task.isDone ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: task.isDone)
    }
}
