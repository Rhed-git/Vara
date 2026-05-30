import SwiftUI

// MARK: - Trail Spot Island

// MARK: - Trail Spot Island
//
// Same frosted shell as ConditionsIsland, but the body is the spot's verdict
// summary plus the list of insights (What to Expect for go/caution, Down Time
// Prep for no-go). Capped at five insight rows.

struct TrailSpotIsland: View {
    let spot: TrailSpot
    let favoritesStore: FavoritesStore?
    let onDismiss: () -> Void

    init(spot: TrailSpot, favoritesStore: FavoritesStore? = nil, onDismiss: @escaping () -> Void) {
        self.spot = spot
        self.favoritesStore = favoritesStore
        self.onDismiss = onDismiss
    }

    private var insightsLabel: String {
        switch spot.verdict {
        case .go, .caution: return "What to Expect"
        case .noGo:         return "Down Time Prep"
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.42)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { onDismiss() }
                    .transition(.opacity)

                island(maxHeight: geo.size.height * 0.72)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func island(maxHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            verdictBlock
            favoriteAction

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
            .scrollDismissesKeyboard(.interactively)
        }
        .frame(maxWidth: 420, maxHeight: maxHeight)
        .background(islandBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.55), radius: 30, x: 0, y: 18)
        .padding(.horizontal, 22)
        .padding(.top, 48)
        .padding(.bottom, 96)
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

    @ViewBuilder
    private var favoriteAction: some View {
        if let favoritesStore {
            let isSaved = favoritesStore.isSaved(spot)

            Button {
                guard !isSaved else { return }
                withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                    favoritesStore.save(spot)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "star.fill")
                        .font(.subheadline.weight(.semibold))
                    Text(isSaved ? "Saved" : "Save to Favorites")
                        .font(.subheadline.weight(.semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(.white.opacity(isSaved ? 0.14 : 0.20), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.24), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .disabled(isSaved)
            .padding(.horizontal, 22)
            .padding(.bottom, 14)
        }
    }
}
