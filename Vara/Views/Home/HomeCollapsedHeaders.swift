import SwiftUI

// MARK: - Home Collapsed Headers

struct ReadinessCollapsedHeader: View {
    let day: DayForecast

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(HomeSection.readiness.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))
            HStack(spacing: 8) {
                Circle()
                    .fill(day.verdict.color)
                    .frame(width: 8, height: 8)
                Text(day.verdict.rawValue)
                    .font(.headline.weight(.bold))
                    .tracking(day.verdict == .noGo ? -0.4 : 0)
                    .foregroundStyle(.white)
                Text(day.verdict.headline)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .contentShape(Rectangle())
    }
}

struct ForecastCollapsedHeader: View {
    let day: DayForecast
    let isToday: Bool

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(HomeSection.forecast.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                Text(summary)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            VerdictPill(verdict: day.verdict, emphasized: false)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .contentShape(Rectangle())
    }

    private var summary: String {
        let label = isToday ? "Today" : day.date.formatted(.dateTime.weekday(.abbreviated))
        return "\(label) · \(day.high)° / \(day.low)° · \(day.condition)"
    }
}

struct NearbyCollapsedHeader: View {
    let spots: [TrailSpot]

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(HomeSection.nearby.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                Text(summary)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            if let bestSpot {
                VerdictPill(verdict: bestSpot.verdict, emphasized: false)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .contentShape(Rectangle())
    }

    private var bestSpot: TrailSpot? {
        spots.first { $0.verdict == .go } ?? spots.first
    }

    private var summary: String {
        guard let bestSpot else { return "\(spots.count) nearby spots" }
        return "\(spots.count) spots · Best: \(bestSpot.name)"
    }
}
