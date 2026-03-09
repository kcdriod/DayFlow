import SwiftUI

struct TodayView: View {
    @Environment(TaskStore.self) private var store

    var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good morning ☀️" }
        if h < 17 { return "Good afternoon 🌤️" }
        return "Good evening 🌙"
    }

    var motivationalLabel: String {
        let pct = store.todayScore
        if pct >= 0.8 { return "Crushing it 🚀" }
        if pct >= 0.5 { return "On track ✨" }
        if pct > 0    { return "Keep going 💪" }
        return "Let's go 🌅"
    }

    var hasConflicts: Bool {
        store.todayTasks.contains { $0.hasConflict }
    }

    var nextTask: DFTask? {
        store.todayTasks.first { !$0.isDone }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                if hasConflicts { conflictBanner }
                scoreCard
                progressBar
                if let next = nextTask { nextUpCard(next) }
                allTasksList
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
            .padding(.bottom, 20)
        }
        .background(Color.black)
    }

    // MARK: - Header

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.coral)
                Text(greeting)
                    .font(.system(size: 28, weight: .bold))
                    .tracking(-0.5)
                    .foregroundStyle(.white)
            }
            Spacer()
        }
    }

    // MARK: - Conflict Banner

    var conflictBanner: some View {
        HStack(spacing: 10) {
            Text("⚠️")
            Text("Scheduling conflict detected")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(14)
        .background(Color(hex: "#ff9f0a").opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(hex: "#ff9f0a").opacity(0.5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Score Card

    var scoreCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(
                    colors: [.coral, .coralDeep],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))

            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 120)
                    .offset(x: geo.size.width - 40, y: -30)
                Circle()
                    .fill(.white.opacity(0.04))
                    .frame(width: 80)
                    .offset(x: geo.size.width - 20, y: geo.size.height - 20)
            }

            HStack(spacing: 20) {
                ScoreDonutView(progress: store.todayScore, size: 76)
                    .padding(.leading, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("TODAY'S PROGRESS")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))
                        .kerning(0.5)

                    Text(motivationalLabel)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    // Streak badge
                    HStack(spacing: 4) {
                        Text("🔥 \(store.config.streakDays) day streak")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                }

                Spacer()
            }
            .padding(.vertical, 20)
        }
        .frame(height: 120)
        .coralShadow()
    }

    // MARK: - Progress Bar

    var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(store.todayDone) of \(store.todayTotal) tasks complete")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textTert)
                Spacer()
                Text("\(Int(store.todayScore * 100))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.coral)
            }
            ProgressView(value: store.todayScore)
                .tint(.coral)
                .scaleEffect(x: 1, y: 1.5)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Next Up

    func nextUpCard(_ task: DFTask) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NEXT UP")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.textQuart)
                .kerning(1)

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(task.color.opacity(0.15))
                        .frame(width: 46, height: 46)
                    Text(task.emoji).font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(task.timeRangeString + " · " + task.durationLabel)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textTert)
                }

                Spacer()

                Button {
                    store.toggleDone(task.id)
                } label: {
                    Circle()
                        .stroke(Color.surface3, lineWidth: 2)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .surfaceCard(radius: 20)
    }

    // MARK: - All Tasks

    var allTasksList: some View {
        VStack(spacing: 0) {
            if store.todayTasks.isEmpty {
                emptyState
            } else {
                ForEach(Array(store.todayTasks.enumerated()), id: \.element.id) { idx, task in
                    TaskRowView(task: task) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        store.toggleDone(task.id)
                    }
                    if idx < store.todayTasks.count - 1 {
                        Divider()
                            .background(Color.surface3)
                            .padding(.leading, 74)
                    }
                }
            }
        }
        .surfaceCard(radius: 20)
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Text("🌅")
                .font(.system(size: 40))
            Text("No tasks today")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Text("Tap + to add your first task")
                .font(.system(size: 14))
                .foregroundStyle(Color.textTert)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}
