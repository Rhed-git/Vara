enum Activity: String, CaseIterable, Identifiable {
    case mountainBike = "Mountain Bike"   // primary activity Vara is built around
    case roadBike = "Road Bike"
    case running = "Running"
    case hike = "Hiking"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .mountainBike: return "bicycle"
        case .roadBike: return "figure.outdoor.cycle"
        case .running: return "figure.run"
        case .hike: return "figure.hiking"
        }
    }

    /// Only Mountain Bike is wired up for now — everything else is roadmap/coming soon.
    var isAvailable: Bool { self == .mountainBike }
}
