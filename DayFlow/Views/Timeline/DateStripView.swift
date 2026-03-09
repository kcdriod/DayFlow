import SwiftUI

struct DateStripView: View {
    @Binding var selectedDate: Date
    let days: [Date]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(days, id: \.self) { day in
                    DateChipView(date: day, isSelected: day.isSameDay(as: selectedDate)) {
                        withAnimation(.spring(response: 0.25)) {
                            selectedDate = day
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct DateChipView: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(date.dayAbbreviation.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color.textTert)
                Text("\(date.dayNumber)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? .white : Color.textSec)
            }
            .frame(width: 52, height: 72)
            .background(isSelected ? Color.coral : Color.surface1)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: isSelected ? .coral.opacity(0.4) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}
