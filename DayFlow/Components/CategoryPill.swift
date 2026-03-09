import SwiftUI

struct CategoryPill: View {
    let category: TaskCategory
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Circle()
                    .fill(category.color)
                    .frame(width: 6, height: 6)
                Text(category.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isActive ? .white : Color.textTert)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isActive ? category.color : Color.surface2)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2), value: isActive)
    }
}
