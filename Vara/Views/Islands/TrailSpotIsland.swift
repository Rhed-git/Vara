import SwiftUI

// MARK: - Trail Spot Island

// MARK: - Trail Spot Island
//
// Same frosted shell as ConditionsIsland, but the body is the spot's verdict
// summary plus the list of insights (What to Expect for go/caution, Down Time
// Prep for no-go). Capped at five insight rows.

struct TrailSpotIsland: View {
    let spot: TrailSpot
    let onDismiss: () -> Void

    private var insightsLabel: String {
        switch spot.verdict {
        case .go, .caution: return "What to Expect"
        case .noGo:         return "Down Time Prep"
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onDismiss() }
                .transition(.opacity)

            island
                .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private var island: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            verdictBlock

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(insightsLabel.uppercased())
                        .font(.caption.weight(.semibold))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.82))

                    VStack(spacing: 8) {
                        ForEach(spot.insights.prefix(5)) { insight in
                            InsightRow(item: insight)
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 4)
                .padding(.bottom, 22)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: 420)
        .background(islandBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.55), radius: 30, x: 0, y: 18)
        .padding(.horizontal, 22)
        // Same top/bottom padding as ConditionsIsland so it never covers the pill.
        .padding(.top, 60)
        .padding(.bottom, 120)
    }

    private var islandBackground: some View {
        ZStack {
            Rectangle().fill(.thickMaterial)
            Color.black.opacity(0.55)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: spot.kind.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(spot.kind.label)
                        .font(.caption2.weight(.semibold))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Text(spot.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(spot.detail)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(.white.opacity(0.20), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.30), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 14)
    }

    private var verdictBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(spot.verdict.rawValue)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                Text(spot.verdict.headline)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            Text(spot.verdict.summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 14)
    }
}
