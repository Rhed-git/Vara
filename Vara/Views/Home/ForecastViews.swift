import SwiftUI

// MARK: - Day Row

struct DayRow: View {
    let day: DayForecast
    let isToday: Bool
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            Text(isToday ? "Today" : day.date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.body.weight(isToday ? .semibold : .regular))
                .foregroundStyle(.white)
                .frame(width: 70, alignment: .leading)

            Image(systemName: day.symbol)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .frame(width: 36, alignment: .center)

            Text("\(day.high)°  \(day.low)°")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
                .monospacedDigit()

            Spacer(minLength: 0)

            VerdictPill(verdict: day.verdict, emphasized: isSelected)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(
            isSelected
                ? Color.white.opacity(0.08)
                : Color.clear
        )
    }
}
