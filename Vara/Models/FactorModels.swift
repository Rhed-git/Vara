import Foundation

enum FactorType: String, CaseIterable {
    case weather, terrain, daylight

    var title: String {
        switch self {
        case .weather: return "Weather"
        case .terrain: return "Terrain"
        case .daylight: return "Daylight"
        }
    }

    var icon: String {
        switch self {
        case .weather: return "cloud.sun.fill"
        case .terrain: return "mountain.2.fill"
        case .daylight: return "sun.horizon.fill"
        }
    }
}

struct Metric: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String
}

struct FactorDetail {
    let verdict: Verdict
    let summary: String
    let metrics: [Metric]
}

/// A single bullet shown in the new "What to Expect" / "Down Time Prep" panel that
/// sits between the verdict and the current-conditions row. Capped at 5 per day.
struct InsightItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}
