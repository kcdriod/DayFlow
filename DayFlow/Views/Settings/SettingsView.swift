import SwiftUI

struct SettingsView: View {
    @Environment(TaskStore.self) private var store

    @State private var showWakeTimePicker = false
    @State private var showBedTimePicker  = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Customize your DayFlow")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textTert)
                    }
                    Spacer()
                }
                .padding(.top, 56)

                // Schedule section
                sectionCard(title: "⏰  Schedule") {
                    VStack(spacing: 0) {
                        settingsRow(icon: "🌅", title: "Wake-up time") {
                            Button {
                                withAnimation { showWakeTimePicker.toggle() }
                            } label: {
                                Text(store.config.wakeTimeString)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.coral)
                            }
                            .buttonStyle(.plain)
                        }

                        if showWakeTimePicker {
                            DatePicker("", selection: Binding(
                                get: { store.config.wakeTime },
                                set: { v in
                                    var c = store.config
                                    c.wakeTime = v
                                    store.updateConfig(c)
                                }
                            ), displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .accentColor(.coral)
                            .padding(.vertical, 8)
                            .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                        }

                        Divider().background(Color.surface3).padding(.leading, 48)

                        settingsRow(icon: "🌙", title: "Bedtime") {
                            Button {
                                withAnimation { showBedTimePicker.toggle() }
                            } label: {
                                Text(store.config.bedTimeString)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.coral)
                            }
                            .buttonStyle(.plain)
                        }

                        if showBedTimePicker {
                            DatePicker("", selection: Binding(
                                get: { store.config.bedTime },
                                set: { v in
                                    var c = store.config
                                    c.bedTime = v
                                    store.updateConfig(c)
                                }
                            ), displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .accentColor(.coral)
                            .padding(.vertical, 8)
                            .transition(.scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                        }

                        Divider().background(Color.surface3).padding(.leading, 48)

                        settingsRow(icon: "🔔", title: "Wind-down alert") {
                            HStack(spacing: 6) {
                                ForEach([15, 30, 60], id: \.self) { mins in
                                    Button {
                                        var c = store.config
                                        c.winddownMinutes = mins
                                        store.updateConfig(c)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    } label: {
                                        Text(mins == 60 ? "1h" : "\(mins)m")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(store.config.winddownMinutes == mins ? .white : Color.textTert)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(store.config.winddownMinutes == mins ? Color.coral : Color.surface2)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                    .animation(.spring(response: 0.2), value: store.config.winddownMinutes)
                                }
                            }
                        }

                        Divider().background(Color.surface3).padding(.leading, 48)

                        settingsRow(icon: "🎵", title: "Notification sound") {
                            Text("Soft chime")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textTert)
                        }
                    }
                }

                // Pro section
                proCard

                // About section
                sectionCard(title: "ℹ️  About") {
                    VStack(spacing: 0) {
                        settingsRow(icon: "📱", title: "Version") {
                            Text("1.0.0")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textTert)
                        }
                        Divider().background(Color.surface3).padding(.leading, 48)
                        settingsRow(icon: "📊", title: "Current streak") {
                            Text("🔥 \(store.config.streakDays) days")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.coral)
                        }
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.black)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showWakeTimePicker)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showBedTimePicker)
    }

    // MARK: - Helpers

    func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.textQuart)
                .kerning(0.5)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            content()
                .surfaceCard(radius: 16)
        }
    }

    func settingsRow<V: View>(icon: String, title: String, @ViewBuilder trailing: () -> V) -> some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 18)).frame(width: 28)
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(.white)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    var proCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [.coral, .coralDeep],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("DayFlow Pro")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Unlimited tasks · AI features · Voice input")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                Button {
                    // Present RevenueCat paywall
                } label: {
                    Text("Upgrade")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.coral)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .coralShadow()
    }
}
