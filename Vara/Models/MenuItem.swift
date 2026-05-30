enum MenuItem: String, CaseIterable, Identifiable {
    case home, location, activity, preferences, account

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .location: return "Location"
        case .activity: return "Activity"
        case .preferences: return "Preferences"
        case .account: return "Account"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .location: return "location.fill"
        case .activity: return "figure.outdoor.cycle"
        case .preferences: return "slider.horizontal.3"
        case .account: return "person.crop.circle.fill"
        }
    }
}
