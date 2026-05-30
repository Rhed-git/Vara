import Foundation

struct SavedSpot: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let kind: SpotKind
    let detail: String
    let verdict: Verdict
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        kind: SpotKind,
        detail: String,
        verdict: Verdict,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.detail = detail
        self.verdict = verdict
        self.createdAt = createdAt
    }

    init(spot: TrailSpot) {
        self.init(
            name: spot.name,
            kind: spot.kind,
            detail: spot.detail,
            verdict: spot.verdict
        )
    }

    var trailSpot: TrailSpot {
        TrailSpot(
            name: name,
            kind: kind,
            detail: detail,
            verdict: verdict,
            insights: MockData.spotInsights(for: verdict)
        )
    }

    func matches(_ spot: TrailSpot) -> Bool {
        name == spot.name && kind == spot.kind
    }
}
