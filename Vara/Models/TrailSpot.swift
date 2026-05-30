import Foundation

enum SpotKind {
    case trail, park

    var label: String { self == .trail ? "TRAIL" : "PARK" }
    /// SF Symbols — tweak per device review.
    var icon: String { self == .trail ? "mountain.2.fill" : "bicycle" }
}

struct TrailSpot: Identifiable {
    let id = UUID()
    let name: String
    let kind: SpotKind
    let detail: String          // e.g. "8.1 mi loop" or "3.2 mi away"
    let verdict: Verdict
    let insights: [InsightItem] // up to 5
}
