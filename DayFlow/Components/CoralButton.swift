import SwiftUI

struct CoralButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(isEnabled ? .white : Color.textQuart)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(isEnabled ? Color.coral : Color.surface2)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: isEnabled ? .coral.opacity(0.4) : .clear,
                radius: 14, y: 6
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Convenience wrapper
struct CoralButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(CoralButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}
