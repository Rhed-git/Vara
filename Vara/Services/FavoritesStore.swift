import Foundation
import Observation

@Observable
@MainActor
final class FavoritesStore {
    private let storageKey = "vara.savedSpots"
    private let defaults: UserDefaults

    private(set) var spots: [SavedSpot]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: storageKey),
           let savedSpots = try? JSONDecoder().decode([SavedSpot].self, from: data) {
            spots = savedSpots
        } else {
            spots = MockData.savedSpots.map(SavedSpot.init(spot:))
            persist()
        }
    }

    func isSaved(_ spot: TrailSpot) -> Bool {
        spots.contains { $0.matches(spot) }
    }

    func save(_ spot: TrailSpot) {
        guard !isSaved(spot) else { return }
        spots.insert(SavedSpot(spot: spot), at: 0)
        persist()
    }

    func remove(_ spot: TrailSpot) {
        spots.removeAll { $0.matches(spot) }
        persist()
    }

    func remove(_ savedSpot: SavedSpot) {
        spots.removeAll { $0.id == savedSpot.id }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(spots) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
