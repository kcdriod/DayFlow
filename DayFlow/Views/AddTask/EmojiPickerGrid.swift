import SwiftUI

let emojiList: [String] = [
    "🎯","📧","👥","💪","🏃","😴","🍕","☕","🛒","📚","🎵","💻","🚗","🧘",
    "✈️","❤️","🎬","🏠","💰","📊","🌅","🎉","🏋️","🧹","📱","🔑","🎮","🌿",
    "🍎","💊","🎨","📝","🔔","⭐","🏆","🎓","🌙","🌤️","🔧","📦"
]

struct EmojiPickerGrid: View {
    @Binding var selectedEmoji: String

    private let columns = Array(repeating: GridItem(.flexible()), count: 8)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(emojiList, id: \.self) { emoji in
                Button {
                    withAnimation(.spring(response: 0.2)) {
                        selectedEmoji = emoji
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text(emoji)
                        .font(.system(size: 22))
                        .frame(width: 40, height: 40)
                        .background(selectedEmoji == emoji ? Color.coral.opacity(0.15) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    selectedEmoji == emoji ? Color.coral : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
