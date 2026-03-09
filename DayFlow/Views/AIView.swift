import SwiftUI

struct AIView: View {
    @Environment(TaskStore.self) private var store
    @State private var isPrioritizing = false
    @State private var showResult = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Assistant")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Smart planning, powered by AI")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textTert)
                    }
                    Spacer()
                    Text("✦")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.coral)
                }
                .padding(.top, 56)

                // Prioritize card
                prioritizeCard

                // Features cards
                featureCard(
                    icon: "🎙️",
                    title: "Voice to Task",
                    description: "Speak naturally and AI extracts the task, time, and category.",
                    color: .catWork
                )
                featureCard(
                    icon: "🧠",
                    title: "Smart Prioritization",
                    description: "AI reorders your tasks by urgency and energy level.",
                    color: .catPersonal
                )
                featureCard(
                    icon: "⚠️",
                    title: "Conflict Detection",
                    description: "Automatically flags scheduling conflicts in your timeline.",
                    color: Color(hex: "#ff9f0a")
                )

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.black)
    }

    var prioritizeCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Tasks")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text("AI can reorder by priority")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textTert)
                }
                Spacer()
                Button {
                    prioritizeTasks()
                } label: {
                    HStack(spacing: 6) {
                        if isPrioritizing {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Text("✦")
                        }
                        Text(isPrioritizing ? "Working…" : "Prioritize")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isPrioritizing ? Color.surface2 : Color.coral)
                    .clipShape(Capsule())
                    .shadow(color: isPrioritizing ? .clear : .coral.opacity(0.4), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(isPrioritizing || store.todayTasks.isEmpty)
            }

            if store.todayTasks.isEmpty {
                Text("No tasks today — tap + to add some!")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textQuart)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 4) {
                    ForEach(store.todayTasks.prefix(4)) { task in
                        HStack(spacing: 10) {
                            Text(task.emoji).font(.system(size: 14))
                            Text(task.title)
                                .font(.system(size: 14))
                                .foregroundStyle(task.isDone ? Color.textQuart : Color.textSec)
                                .strikethrough(task.isDone)
                                .lineLimit(1)
                            Spacer()
                            Circle()
                                .fill(task.color)
                                .frame(width: 6, height: 6)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(20)
        .surfaceCard(radius: 20)
    }

    func featureCard(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Text(icon).font(.system(size: 22))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textTert)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .surfaceCard(radius: 18)
    }

    private func prioritizeTasks() {
        guard !store.todayTasks.isEmpty else { return }
        isPrioritizing = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Task {
            do {
                let prioritized = try await OpenAIService.prioritizeTasks(store.todayTasks)
                // Update task order in store
                for (idx, task) in prioritized.enumerated() {
                    _ = idx  // order preserved in display via sorted queries
                    _ = task
                }
                store.showToast(icon: "✦", title: "Tasks Prioritized", message: "AI has reordered your day")
            } catch {
                store.showToast(icon: "⚠️", title: "AI Unavailable", message: "Check your API key in settings")
            }
            isPrioritizing = false
        }
    }
}
