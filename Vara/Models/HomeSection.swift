enum HomeSection: Int, CaseIterable, Identifiable {
    case readiness, forecast, nearby

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .readiness: return "Right Now"
        case .forecast: return "10-Day Forecast"
        case .nearby: return "Nearby"
        }
    }

    var previous: HomeSection? {
        HomeSection(rawValue: rawValue - 1)
    }

    var next: HomeSection? {
        HomeSection(rawValue: rawValue + 1)
    }
}
