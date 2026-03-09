import SwiftUI

struct ScoreDonutView: View {
    let progress: Double  // 0.0 – 1.0
    let size: CGFloat

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 6)
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            // Center text
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                Text("score")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, new in
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                animatedProgress = new
            }
        }
    }
}
