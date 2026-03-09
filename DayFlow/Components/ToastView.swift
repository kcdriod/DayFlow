import SwiftUI

struct ToastView: View {
    let message: ToastMessage

    var body: some View {
        HStack(spacing: 12) {
            Text(message.icon)
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 2) {
                Text(message.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text(message.message)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textTert)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.surface1)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.surface3, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.6), radius: 16)
    }
}

// MARK: - Toast Overlay Modifier

struct ToastModifier: ViewModifier {
    @Environment(\.taskStore) private var store

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let msg = store.toast {
                    ToastView(message: msg)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                withAnimation(.spring(response: 0.4)) {
                                    store.toast = nil
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation { store.toast = nil }
                        }
                }
            }
            .animation(.spring(response: 0.42, dampingFraction: 0.9), value: store.toast?.id)
    }
}

extension View {
    func toastOverlay() -> some View {
        modifier(ToastModifier())
    }
}
