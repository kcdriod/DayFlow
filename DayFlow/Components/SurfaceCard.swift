import SwiftUI

struct SurfaceCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: () -> Content

    init(cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .background(Color.surface1)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
