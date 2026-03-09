import SwiftUI

struct DurationSelector: View {
    @Binding var duration: Int

    private let presets = [15, 30, 45, 60, 90, 120]
    private var durationDouble: Binding<Double> {
        Binding(
            get: { Double(duration) },
            set: { duration = Int($0) }
        )
    }

    var durationLabel: String {
        if duration < 60 { return "\(duration) min" }
        let h = duration / 60; let m = duration % 60
        return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Preset pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { mins in
                        Button {
                            withAnimation(.spring(response: 0.2)) { duration = mins }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Text(mins < 60 ? "\(mins)m" : "\(mins / 60)h")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(duration == mins ? .white : Color.textTert)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(duration == mins ? Color.coral : Color.surface2)
                                .clipShape(Capsule())
                                .shadow(
                                    color: duration == mins ? .coral.opacity(0.35) : .clear,
                                    radius: 6, y: 3
                                )
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.2), value: duration)
                    }
                }
                .padding(.horizontal, 2)
            }

            // Fine-grained slider
            HStack(spacing: 12) {
                Slider(value: durationDouble, in: 5...180, step: 5)
                    .tint(.coral)
                Text(durationLabel)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.coral)
                    .frame(width: 56, alignment: .trailing)
                    .monospacedDigit()
            }
        }
    }
}
