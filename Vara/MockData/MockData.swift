import Foundation

enum MockData {
    static let tenDays: [DayForecast] = build()

    /// Boulder-area trail and bike-park spots surfaced under the 10-day forecast.
    /// Mixed verdicts so all three island variants are reachable from the home page.
    static let nearbySpots: [TrailSpot] = [
        TrailSpot(name: "Valmont Bike Park", kind: .park,  detail: "3.2 mi away",
                  verdict: .go,      insights: spotInsights(for: .go)),
        TrailSpot(name: "Marshall Mesa",     kind: .trail, detail: "8.1 mi loop",
                  verdict: .go,      insights: spotInsights(for: .go)),
        TrailSpot(name: "Betasso Preserve",  kind: .trail, detail: "6.5 mi loop",
                  verdict: .caution, insights: spotInsights(for: .caution)),
        TrailSpot(name: "Heil Valley Ranch", kind: .trail, detail: "7.8 mi out-and-back",
                  verdict: .caution, insights: spotInsights(for: .caution)),
        TrailSpot(name: "Hall Ranch",        kind: .trail, detail: "12 mi loop",
                  verdict: .noGo,    insights: spotInsights(for: .noGo)),
        TrailSpot(name: "White Ranch",       kind: .park,  detail: "18 mi network",
                  verdict: .noGo,    insights: spotInsights(for: .noGo)),
    ]

    private static func spotInsights(for v: Verdict) -> [InsightItem] {
        switch v {
        case .go:
            return [
                InsightItem(title: "Hardpack is dry and fast", icon: "leaf.fill"),
                InsightItem(title: "Carry 2L, the climb is exposed", icon: "drop.fill"),
                InsightItem(title: "Berms and jumps holding well", icon: "flag.fill"),
                InsightItem(title: "Light breeze on the descents", icon: "wind"),
                InsightItem(title: "Daylight margin until 8:10 PM", icon: "sun.horizon.fill"),
            ]
        case .caution:
            return [
                InsightItem(title: "North-facing sections still tacky", icon: "leaf.fill"),
                InsightItem(title: "One creek crossing running high", icon: "drop.fill"),
                InsightItem(title: "Pack a shell for afternoon cells", icon: "cloud.rain.fill"),
                InsightItem(title: "Loose over hardpack on descents", icon: "wind"),
                InsightItem(title: "A shorter bail-out loop exists", icon: "map.fill"),
            ]
        case .noGo:
            return [
                InsightItem(title: "Trail likely closed, wet clay tears up tread", icon: "flag.fill"),
                InsightItem(title: "Tune chain and brake pads", icon: "wrench.adjustable.fill"),
                InsightItem(title: "Wash and inspect the drivetrain", icon: "sparkles"),
                InsightItem(title: "Scout the next route on Trailforks", icon: "map.fill"),
                InsightItem(title: "Mobility and stretch session", icon: "figure.cooldown"),
            ]
        }
    }

    private static func build() -> [DayForecast] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let weatherConditions: [WeatherCondition] = [
            .clear, .partlyCloudy, .cloudy, .overcast, .rain,
            .storm, .snow, .clear, .partlyCloudy, .rain,
        ]
        let verdicts: [Verdict] = [
            .go, .go, .caution, .caution, .caution,
            .noGo, .noGo, .go, .caution, .caution,
        ]
        let symbols = [
            "sun.max.fill",
            "cloud.sun.fill",
            "cloud.fill",
            "cloud.fill",
            "cloud.rain.fill",
            "cloud.bolt.rain.fill",
            "cloud.snow.fill",
            "sun.max.fill",
            "cloud.sun.fill",
            "cloud.rain.fill",
        ]
        let conditions = [
            "Clear", "Partly Cloudy", "Cloudy", "Overcast", "Rain",
            "Storms", "Snow", "Clear", "Partly Cloudy", "Rain",
        ]
        let highs = [72, 70, 65, 60, 55, 58, 32, 68, 66, 57]
        let lows = [54, 52, 50, 48, 45, 46, 22, 49, 47, 44]

        return (0..<10).map { i in
            let date = calendar.date(byAdding: .day, value: i, to: today) ?? today
            return DayForecast(
                date: date,
                symbol: symbols[i],
                high: highs[i],
                low: lows[i],
                condition: conditions[i],
                weatherCondition: weatherConditions[i],
                verdict: verdicts[i],
                weather: weather(for: verdicts[i]),
                terrain: terrain(for: verdicts[i]),
                daylight: daylight(for: verdicts[i]),
                insights: insights(for: verdicts[i])
            )
        }
    }

    /// Five short bullets per verdict. Go/Caution describe what to expect on the
    /// ride; No-Go offers prep ideas for the downtime before the next Go window.
    private static func insights(for v: Verdict) -> [InsightItem] {
        switch v {
        case .go:
            return [
                InsightItem(title: "Bring 2L of water", icon: "drop.fill"),
                InsightItem(title: "Trails are dry and grippy", icon: "leaf.fill"),
                InsightItem(title: "UV moderate — wear sunscreen", icon: "sun.max.fill"),
                InsightItem(title: "Light breeze on the descents", icon: "wind"),
                InsightItem(title: "Plenty of daylight margin", icon: "sun.horizon.fill"),
            ]
        case .caution:
            return [
                InsightItem(title: "Pack a light rain shell", icon: "cloud.rain.fill"),
                InsightItem(title: "Mud likely on north aspects", icon: "leaf.fill"),
                InsightItem(title: "Finish climbs before noon wind", icon: "wind"),
                InsightItem(title: "Carry an extra layer", icon: "thermometer.medium"),
                InsightItem(title: "Plan a shorter loop option", icon: "map.fill"),
            ]
        case .noGo:
            return [
                InsightItem(title: "Tune chain & brake pads", icon: "wrench.adjustable.fill"),
                InsightItem(title: "Wash and inspect drivetrain", icon: "sparkles"),
                InsightItem(title: "Plan the next route on Trailforks", icon: "map.fill"),
                InsightItem(title: "Review last ride's stats", icon: "chart.line.uptrend.xyaxis"),
                InsightItem(title: "Stretch & mobility work", icon: "figure.cooldown"),
            ]
        }
    }

    private static func weather(for v: Verdict) -> FactorDetail {
        switch v {
        case .go:
            return FactorDetail(
                verdict: .go,
                summary: "Clear skies with light winds. Comfortable temperatures throughout the day.",
                metrics: [
                    Metric(label: "Wind", value: "6 mph", icon: "wind"),
                    Metric(label: "Precipitation", value: "0%", icon: "drop.fill"),
                    Metric(label: "Humidity", value: "42%", icon: "humidity.fill"),
                    Metric(label: "UV Index", value: "5 · Moderate", icon: "sun.max"),
                ]
            )
        case .caution:
            return FactorDetail(
                verdict: .caution,
                summary: "Variable conditions. Wind picks up midday with a chance of showers in the afternoon.",
                metrics: [
                    Metric(label: "Wind", value: "18 mph", icon: "wind"),
                    Metric(label: "Precipitation", value: "40%", icon: "drop.fill"),
                    Metric(label: "Humidity", value: "68%", icon: "humidity.fill"),
                    Metric(label: "UV Index", value: "3 · Low", icon: "sun.max"),
                ]
            )
        case .noGo:
            return FactorDetail(
                verdict: .noGo,
                summary: "Thunderstorms and strong winds expected. Lightning risk through the afternoon.",
                metrics: [
                    Metric(label: "Wind", value: "32 mph", icon: "wind"),
                    Metric(label: "Precipitation", value: "95%", icon: "drop.fill"),
                    Metric(label: "Humidity", value: "88%", icon: "humidity.fill"),
                    Metric(label: "UV Index", value: "1 · Low", icon: "sun.max"),
                ]
            )
        }
    }

    private static func terrain(for v: Verdict) -> FactorDetail {
        switch v {
        case .go:
            return FactorDetail(
                verdict: .go,
                summary: "Trails are dry and stable. No active closures or wildlife alerts in the area.",
                metrics: [
                    Metric(label: "Trail surface", value: "Dry", icon: "leaf.fill"),
                    Metric(label: "Closures", value: "None", icon: "checkmark.seal.fill"),
                    Metric(label: "Wildlife", value: "Low risk", icon: "pawprint.fill"),
                ]
            )
        case .caution:
            return FactorDetail(
                verdict: .caution,
                summary: "Some sections may be muddy after recent rain. Slick rock possible on exposed ledges.",
                metrics: [
                    Metric(label: "Trail surface", value: "Muddy", icon: "leaf.fill"),
                    Metric(label: "Closures", value: "1 minor", icon: "exclamationmark.triangle.fill"),
                    Metric(label: "Wildlife", value: "Moderate", icon: "pawprint.fill"),
                ]
            )
        case .noGo:
            return FactorDetail(
                verdict: .noGo,
                summary: "Multiple trail closures in effect. Flash flood risk in low-lying drainages.",
                metrics: [
                    Metric(label: "Trail surface", value: "Flooded", icon: "leaf.fill"),
                    Metric(label: "Closures", value: "3 active", icon: "xmark.octagon.fill"),
                    Metric(label: "Wildlife", value: "Elevated", icon: "pawprint.fill"),
                ]
            )
        }
    }

    private static func daylight(for v: Verdict) -> FactorDetail {
        switch v {
        case .go:
            return FactorDetail(
                verdict: .go,
                summary: "Long daylight window with comfortable margin for a full outing and return.",
                metrics: [
                    Metric(label: "Sunrise", value: "5:48 AM", icon: "sunrise.fill"),
                    Metric(label: "Sunset", value: "8:12 PM", icon: "sunset.fill"),
                    Metric(label: "Daylight", value: "14h 24m", icon: "clock.fill"),
                ]
            )
        case .caution:
            return FactorDetail(
                verdict: .caution,
                summary: "Cloud cover trims usable light. Plan a conservative turnaround time.",
                metrics: [
                    Metric(label: "Sunrise", value: "6:02 AM", icon: "sunrise.fill"),
                    Metric(label: "Sunset", value: "7:45 PM", icon: "sunset.fill"),
                    Metric(label: "Daylight", value: "13h 43m", icon: "clock.fill"),
                ]
            )
        case .noGo:
            return FactorDetail(
                verdict: .noGo,
                summary: "Heavy overcast reduces effective visibility throughout the day.",
                metrics: [
                    Metric(label: "Sunrise", value: "6:10 AM", icon: "sunrise.fill"),
                    Metric(label: "Sunset", value: "7:32 PM", icon: "sunset.fill"),
                    Metric(label: "Daylight", value: "13h 22m", icon: "clock.fill"),
                ]
            )
        }
    }
}
