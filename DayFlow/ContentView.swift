import SwiftUI

struct ContentView: View {
    @State private var showSplash  = true
    @State private var hasOnboarded = AppConfig.load().hasOnboarded

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showSplash: $showSplash)
                    .zIndex(1)
                    .transition(.opacity)
            } else if !hasOnboarded {
                OnboardingView(hasOnboarded: $hasOnboarded)
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.35), value: showSplash)
        .animation(.easeOut(duration: 0.35), value: hasOnboarded)
    }
}
