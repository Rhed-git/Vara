import SwiftUI

enum Verdict: String, Codable {
    case go = "GO"
    case caution = "CAUTION"
    case noGo = "NO-GO"

    /// Solid accent color for status dots, icons, etc.
    var color: Color {
        switch self {
        case .go: return Color(red: 0.34, green: 0.62, blue: 0.50)
        case .caution: return Color(red: 0.92, green: 0.68, blue: 0.32)
        case .noGo: return Color(red: 0.72, green: 0.42, blue: 0.40)
        }
    }

    var headline: String {
        switch self {
        case .go: return "Good to head out"
        case .caution: return "Proceed with care"
        case .noGo: return "A quieter day looks wise"
        }
    }

    var summary: String {
        switch self {
        case .go: return "Conditions line up well for time outside today."
        case .caution: return "Conditions are mixed — check the details before you commit."
        case .noGo: return "Conditions don't quite add up today. Consider rescheduling."
        }
    }
}
