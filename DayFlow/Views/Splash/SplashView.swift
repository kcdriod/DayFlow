import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var isFloating = false
    @State private var showSubtitle = false
    @State private var dotOpacity: [Double] = [0, 0, 0]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Radial glow
            RadialGradient(
                colors: [.coral.opacity(0.15), .clear],
                center: .center, startRadius: 0, endRadius: 150
            )
            .frame(width: 300, height: 300)

            VStack(spacing: 0) {
                Spacer()

                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(LinearGradient(
                            colors: [.coral, .coralDeep],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 96, height: 96)
                    Text("🌤️").font(.system(size: 44))
                }
                .offset(y: isFloating ? -8 : 0)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isFloating)
                .coralShadow()

                Spacer().frame(height: 24)

                // Title
                Text("DayFlow")
                    .font(.system(size: 42, weight: .black))
                    .tracking(-1)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.6)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                Spacer().frame(height: 10)

                // Subtitle
                Text("Plan it. Live it.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textTert)
                    .opacity(showSubtitle ? 1 : 0)
                    .animation(.easeIn(duration: 0.6), value: showSubtitle)

                Spacer()

                // Pulsing dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Color.coral)
                            .frame(width: 6, height: 6)
                            .opacity(dotOpacity[i])
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            isFloating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                showSubtitle = true
            }
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.2)
                ) {
                    dotOpacity[i] = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}
