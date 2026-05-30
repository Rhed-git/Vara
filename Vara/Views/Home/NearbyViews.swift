import SwiftUI

// MARK: - Trail Tile

// MARK: - Trail Tile

/// One tile in the "Nearby Trails & Parks" grid below the 10-day forecast.
/// Kind label + icon at the top, name, detail, and a verdict pill at the bottom.
struct TrailTile: View {
    let spot: TrailSpot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: spot.kind.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                    Text(spot.kind.label)
                        .font(.caption2.weight(.semibold))
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.75))
                    Spacer(minLength: 0)
                }

                Text(spot.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(spot.detail)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(1)

                Spacer(minLength: 0)

                VerdictPill(verdict: spot.verdict, emphasized: false)
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 94, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 0.5)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("\(spot.name), \(spot.kind.label.lowercased()), \(spot.detail), \(spot.verdict.rawValue)")
    }
}
