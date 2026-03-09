import SwiftUI

struct OnboardingView: View {
    @Environment(TaskStore.self) private var store
    @Binding var hasOnboarded: Bool

    @State private var step = 0
    @State private var wakeTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var bedTime  = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var winddown = 30

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Color.coral : Color.surface3)
                            .frame(width: i == step ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: step)
                    }
                }
                .padding(.top, 20)

                Spacer()

                if step == 0 {
                    stepOne
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    stepTwo
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Step 1

    var stepOne: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text("When do you wake up?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("We'll set your alarm and plan your morning")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textTert)
                    .multilineTextAlignment(.center)
            }

            // Wake time card
            VStack(spacing: 16) {
                Text("🌅").font(.system(size: 56))
                Text("Wake-up time")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textTert)
                DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .accentColor(.coral)
                    .scaleEffect(1.3)
                    .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .surfaceCard(radius: 24)

            // CTA
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    step = 1
                }
            } label: {
                Text("Next →")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.coral)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .coralShadow()
            }
        }
    }

    // MARK: - Step 2

    var stepTwo: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("When do you sleep?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("We'll remind you to wind down before bed")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textTert)
                    .multilineTextAlignment(.center)
            }

            // Bedtime card
            VStack(spacing: 16) {
                Text("🌙").font(.system(size: 56))
                Text("Bedtime")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textTert)
                DatePicker("", selection: $bedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .accentColor(.coral)
                    .scaleEffect(1.3)
                    .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .surfaceCard(radius: 24)

            // Wind-down card
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wind-down alert")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Before bedtime")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textTert)
                }
                HStack(spacing: 8) {
                    ForEach([15, 30, 60], id: \.self) { mins in
                        Button {
                            winddown = mins
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Text(mins == 60 ? "1h" : "\(mins)m")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(winddown == mins ? .white : Color.textTert)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(winddown == mins ? Color.coral : Color.surface2)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: winddown == mins ? .coral.opacity(0.4) : .clear, radius: 8, y: 4)
                        }
                        .animation(.spring(response: 0.2), value: winddown)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .surfaceCard(radius: 20)

            // CTA
            Button {
                completeOnboarding()
            } label: {
                Text("Let's go 🚀")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.coral)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .coralShadow()
            }
        }
    }

    private func completeOnboarding() {
        var config = AppConfig(wakeTime: wakeTime, bedTime: bedTime, winddownMinutes: winddown)
        config.hasOnboarded = true
        store.updateConfig(config)
        store.requestNotificationPermission()
        withAnimation(.easeOut(duration: 0.4)) {
            hasOnboarded = true
        }
    }
}
