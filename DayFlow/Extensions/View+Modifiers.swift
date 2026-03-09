import SwiftUI

// MARK: - TaskStore Environment Key

private struct TaskStoreKey: EnvironmentKey {
    static let defaultValue: TaskStore = TaskStore()
}

extension EnvironmentValues {
    var taskStore: TaskStore {
        get { self[TaskStoreKey.self] }
        set { self[TaskStoreKey.self] = newValue }
    }
}

// MARK: - View Extensions

extension View {
    func coralShadow(radius: CGFloat = 12, y: CGFloat = 6) -> some View {
        shadow(color: .coral.opacity(0.4), radius: radius, y: y)
    }

    func surfaceCard(radius: CGFloat = 20) -> some View {
        self
            .background(Color.surface1)
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
