import Foundation

struct ReadinessRecommendation: Identifiable {
    let id = UUID()
    let verdict: Verdict
    let confidence: RecommendationConfidence
    let bestWindow: ActivityWindow
    let preferredWindow: ActivityWindow?
    let preferredWindowVerdict: Verdict?
    let headline: String
    let summary: String
    let reasons: [RecommendationReason]
}

enum RecommendationConfidence: String {
    case high = "High Confidence"
    case medium = "Medium Confidence"
    case low = "Low Confidence"
}

struct ActivityWindow: Identifiable {
    let id = UUID()
    let label: String
    let timeRange: String
}

struct RecommendationReason: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}
