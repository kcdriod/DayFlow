import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAddTask = false

    private let tabs: [(label: String, icon: String)] = [
        ("Today", "🏠"),
        ("Timeline", "📅"),
        ("AI", "✦"),
        ("Settings", "⚙️")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0: TodayView()
                case 1: TimelineView()
                case 2: AIView()
                case 3: SettingsView()
                default: TodayView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }

            // Custom tab bar + FAB
            VStack(spacing: 0) {
                tabBar
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet()
        }
    }

    var tabBar: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(.ultraThinMaterial)
                .colorScheme(.dark)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.surface3)
                        .frame(height: 0.5)
                }

            HStack(spacing: 0) {
                // Left tabs: Today, Timeline
                tabButton(index: 0)
                tabButton(index: 1)
                // Center FAB placeholder (52pt circle + padding)
                Color.clear.frame(width: 72)
                // Right tabs: AI, Settings
                tabButton(index: 2)
                tabButton(index: 3)
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .padding(.bottom, max(safeAreaBottom, 12))

            // FAB center
            FABButton {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showAddTask = true
            }
            .offset(y: -8)
        }
        .frame(height: 80 + max(safeAreaBottom, 12))
    }

    private func tabButton(index: Int) -> some View {
        let isActive = selectedTab == index
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Text(tabs[index].icon)
                    .font(.system(size: 21))
                Text(tabs[index].label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isActive ? Color.coral : Color.white)
            }
            .frame(maxWidth: .infinity)
            .opacity(isActive ? 1.0 : 0.35)
        }
        .buttonStyle(.plain)
    }

    private var safeAreaBottom: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.bottom ?? 0
    }
}
