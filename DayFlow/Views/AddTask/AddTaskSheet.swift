import SwiftUI

struct AddTaskSheet: View {
    @Environment(TaskStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var emoji = "🎯"
    @State private var category: TaskCategory = .personal
    @State private var taskDate = Calendar.current.startOfDay(for: Date())
    @State private var startTime = Date()
    @State private var duration = 30
    @State private var showEmojiPicker = false
    @State private var showInlineCalendar = false

    @State private var voice = VoiceRecognizer()
    @State private var isProcessingVoice = false

    var startHour:   Int { Calendar.current.component(.hour, from: startTime) }
    var startMinute: Int { Calendar.current.component(.minute, from: startTime) }

    var endTime: Date {
        startTime.addingTimeInterval(Double(duration * 60))
    }

    var timePreviewString: String {
        let start = startTime.formatted(.dateTime.hour().minute())
        let end   = endTime.formatted(.dateTime.hour().minute())
        return "\(start) – \(end) · \(duration < 60 ? "\(duration)m" : "\(duration/60)h\(duration%60 > 0 ? " \(duration%60)m" : "")")"
    }

    var dateLabel: String { taskDate.formattedShortDate }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag indicator
                Capsule()
                    .fill(Color.surface3)
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // Header
                coralHeader

                // Emoji picker (conditional)
                if showEmojiPicker {
                    EmojiPickerGrid(selectedEmoji: $emoji)
                        .background(Color.surface1)
                        .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                }

                // Form
                ScrollView {
                    VStack(spacing: 0) {
                        formRow {
                            VoiceButton(recognizer: voice) { transcript in
                                handleVoiceTranscript(transcript)
                            }
                        }

                        Divider().background(Color.surface3)

                        formRow {
                            dateRow
                        }

                        if showInlineCalendar {
                            MiniCalendarView(selectedDate: $taskDate, taskDates: [])
                                .padding(.horizontal, 20)
                                .padding(.bottom, 12)
                                .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                        }

                        Divider().background(Color.surface3)

                        formRow {
                            timeRow
                        }

                        Divider().background(Color.surface3)

                        formRow {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("⏱️").font(.system(size: 16))
                                    Text("Duration")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                DurationSelector(duration: $duration)
                            }
                        }

                        Divider().background(Color.surface3)

                        formRow {
                            categoryRow
                        }
                    }
                    .padding(.bottom, 100)
                }

                // Create button
                createButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, max(safeAreaBottom + 8, 20))
                    .padding(.top, 12)
                    .background(Color.black)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showEmojiPicker)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showInlineCalendar)
    }

    // MARK: - Coral Header

    var coralHeader: some View {
        ZStack {
            LinearGradient(
                colors: [.coral, .coralDeep],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            HStack(spacing: 14) {
                // Emoji button
                Button {
                    withAnimation { showEmojiPicker.toggle() }
                } label: {
                    Text(emoji)
                        .font(.system(size: 28))
                        .frame(width: 58, height: 58)
                        .background(Color.black.opacity(0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 17)
                                .strokeBorder(Color.coral, lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 6) {
                    TextField("What's the task?", text: $title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .tint(.white)
                        .autocorrectionDisabled()
                        .onChange(of: title) { _, new in
                            if emoji == "🎯" || emojiList.contains(emoji) {
                                let auto = autoEmoji(from: new)
                                if auto != "🎯" { emoji = auto }
                            }
                        }

                    Rectangle()
                        .fill(.white.opacity(0.25))
                        .frame(height: 1.5)

                    Text(title.isEmpty ? "Select time below" : timePreviewString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 30, height: 30)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
    }

    // MARK: - Form Rows

    func formRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
    }

    var dateRow: some View {
        Button {
            withAnimation { showInlineCalendar.toggle() }
            hideKeyboard()
        } label: {
            HStack(spacing: 10) {
                Text("📅").font(.system(size: 16))
                Text("Date").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                Spacer()
                Text(dateLabel)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTert)
                Image(systemName: showInlineCalendar ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textQuart)
            }
        }
        .buttonStyle(.plain)
    }

    var timeRow: some View {
        HStack(spacing: 10) {
            Text("⏰").font(.system(size: 16))
            Text("Start Time").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
            Spacer()
            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
                .accentColor(.coral)
            Text("→ \(endTime.formatted(.dateTime.hour().minute()))")
                .font(.system(size: 13))
                .foregroundStyle(Color.textTert)
        }
    }

    var categoryRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("🏷️").font(.system(size: 16))
                Text("Category").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
            }
            HStack(spacing: 8) {
                ForEach(TaskCategory.allCases) { cat in
                    Button {
                        withAnimation(.spring(response: 0.2)) { category = cat }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Text(cat.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(category == cat ? .white : Color.textTert)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(category == cat ? cat.color.opacity(0.9) : Color.surface2)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.2), value: category)
                }
            }
        }
    }

    // MARK: - Create Button

    var createButton: some View {
        Button {
            createTask()
        } label: {
            Text("Create Task ✓")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(title.isEmpty ? Color.textQuart : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(title.isEmpty ? Color.surface2 : Color.coral)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(
                    color: title.isEmpty ? .clear : .coral.opacity(0.4),
                    radius: 14, y: 6
                )
        }
        .buttonStyle(.plain)
        .disabled(title.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: title.isEmpty)
    }

    // MARK: - Actions

    private func createTask() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let task = DFTask(
            emoji: emoji,
            title: title,
            category: category,
            startHour: startHour,
            startMinute: startMinute,
            durationMinutes: duration,
            date: taskDate
        )
        store.addTask(task)
        dismiss()
    }

    private func handleVoiceTranscript(_ transcript: String) {
        isProcessingVoice = true
        Task {
            do {
                let parsed = try await OpenAIService.parseVoiceTask(transcript)
                title    = parsed.title
                emoji    = parsed.emoji
                category = TaskCategory(rawValue: parsed.category) ?? .other
                let cal  = Calendar.current
                startTime = cal.date(
                    bySettingHour: parsed.startHour,
                    minute: parsed.startMinute,
                    second: 0,
                    of: startTime
                ) ?? startTime
                duration = parsed.durationMinutes
            } catch {
                // Fallback: use transcript as title
                title = transcript
            }
            isProcessingVoice = false
            voice.state = .idle
        }
    }

    private var safeAreaBottom: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.bottom ?? 0
    }
}
