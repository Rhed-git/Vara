import SwiftUI

struct FavoritesPage: View {
    let favoritesStore: FavoritesStore
    let onSpotTap: (TrailSpot) -> Void

    var body: some View {
        PageScaffold {
            PageHeader(
                title: "Favorites",
                subtitle: "Your saved trails and riding areas"
            )

            if favoritesStore.spots.isEmpty {
                emptyState
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ],
                    spacing: 12
                ) {
                    ForEach(favoritesStore.spots) { savedSpot in
                        favoriteTile(savedSpot)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 2)
            }
        }
    }

    private func favoriteTile(_ savedSpot: SavedSpot) -> some View {
        let spot = savedSpot.trailSpot

        return TrailTile(spot: spot) {
            onSpotTap(spot)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                    favoritesStore.remove(savedSpot)
                }
            } label: {
                Image(systemName: "trash")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.88))
                    .frame(width: 28, height: 28)
                    .background(.black.opacity(0.24), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.18), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .padding(7)
            .accessibilityLabel("Remove \(savedSpot.name) from favorites")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "star")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.78))

            Text("No Favorites Yet")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Save trails and parks from nearby spots to keep them here.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        VaraTopoBackground()
            .ignoresSafeArea()

        FavoritesPage(favoritesStore: FavoritesStore()) { _ in }
    }
}
