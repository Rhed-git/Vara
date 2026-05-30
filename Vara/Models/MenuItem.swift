enum MenuItem: String, CaseIterable, Identifiable {
    case home, favorites, location, activity, preferences, account

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .favorites: return "Favorites"
        case .location: return "Location"
        case .activity: return "Activity"
        case .preferences: return "Preferences"
        case .account: return "Account"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .favorites: return "star.fill"
        case .location: return "mappin.and.ellipse"
        case .activity: return "figure.outdoor.cycle"
        case .preferences: return "slider.horizontal.3"
        case .account: return "person.crop.circle.fill"
        }
    }
}
