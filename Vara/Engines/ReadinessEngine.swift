import Foundation

struct ReadinessEngine {
    static func recommendation(
        for day: DayForecast,
        preferredWindow: ActivityWindow? = nil
    ) -> ReadinessRecommendation {
        let confidence: RecommendationConfidence
        let bestWindow: ActivityWindow
        let preferredWindowVerdict: Verdict

        switch day.verdict {
        case .go:
            confidence = .high
            bestWindow = ActivityWindow(label: "Best Window", timeRange: "5:00 PM - 7:30 PM")
            preferredWindowVerdict = .go
        case .caution:
            confidence = .medium
            bestWindow = ActivityWindow(label: "Best Window", timeRange: "9:00 AM - 11:00 AM")
            preferredWindowVerdict = .caution
        case .noGo:
            confidence = .low
            bestWindow = ActivityWindow(label: "Next Best Window", timeRange: "Tomorrow after 4:00 PM")
            preferredWindowVerdict = .noGo
        }

        return ReadinessRecommendation(
            verdict: day.verdict,
            confidence: confidence,
            bestWindow: bestWindow,
            preferredWindow: preferredWindow,
            preferredWindowVerdict: preferredWindowVerdict,
            headline: day.verdict.headline,
            summary: day.verdict.summary,
            reasons: day.insights.map { insight in
                RecommendationReason(title: insight.title, icon: insight.icon)
            }
        )
    }
}
