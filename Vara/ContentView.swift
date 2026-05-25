import SwiftUI

// MARK: - Models

enum WeatherCondition {
    case clear, partlyCloudy, cloudy, overcast, rain, snow, storm
}

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

enum Verdict: String {
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

struct DayForecast: Identifiable {
    let id = UUID()
    let date: Date
    let symbol: String
    let high: Int
    let low: Int
    let condition: String
    let weatherCondition: WeatherCondition
    let verdict: Verdict
    let weather: FactorDetail
    let terrain: FactorDetail
    let daylight: FactorDetail
    let insights: [InsightItem]
}

// MARK: - Mock Data

enum MockData {
    static let sevenDays: [DayForecast] = build()

    /// Boulder-area trail and bike-park spots surfaced under the 7-day forecast.
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

        // One distinct WeatherCondition per day so each forecast row demos a different effect.
        let weatherConditions: [WeatherCondition] = [
            .clear, .partlyCloudy, .cloudy, .overcast, .rain, .storm, .snow,
        ]
        let verdicts: [Verdict] = [.go, .go, .caution, .caution, .caution, .noGo, .noGo]
        let symbols = [
            "sun.max.fill",
            "cloud.sun.fill",
            "cloud.fill",
            "cloud.fill",
            "cloud.rain.fill",
            "cloud.bolt.rain.fill",
            "cloud.snow.fill",
        ]
        let conditions = ["Clear", "Partly Cloudy", "Cloudy", "Overcast", "Rain", "Storms", "Snow"]
        let highs = [72, 70, 65, 60, 55, 58, 32]
        let lows = [54, 52, 50, 48, 45, 46, 22]

        return (0..<7).map { i in
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

// MARK: - Root

struct ContentView: View {
    @State private var selectedDayIndex: Int = 0
    @State private var isShowingConditions: Bool = false
    @State private var selectedSpot: TrailSpot? = nil
    @State private var scrollOffset: CGFloat = 0
    /// Natural content height of the expanded hero — measured live via a hidden
    /// probe so `expandedHeroHeight` actually hugs the content instead of guessing.
    @State private var measuredHeroHeight: CGFloat = 580

    // Floating menu state
    @State private var location: String = "Boulder, CO"
    @State private var selectedActivity: Activity = .mountainBike
    @State private var currentPage: MenuItem = .home

    private let forecast = MockData.sevenDays
    private var selectedDay: DayForecast { forecast[selectedDayIndex] }
    private var currentCondition: WeatherCondition { selectedDay.weatherCondition }
    private var isViewingToday: Bool { selectedDayIndex == 0 }
    private var conditionsTitle: String { isViewingToday ? "Current Conditions" : "Expected Conditions" }
    private var conditionsSubtitle: String {
        let core = "\(selectedDay.high)°  ·  \(selectedDay.condition)  ·  Tap for details"
        if isViewingToday { return core }
        let weekday = selectedDay.date.formatted(.dateTime.weekday(.abbreviated))
        return "\(weekday)  ·  \(core)"
    }

    var body: some View {
        ZStack {
            // Background — shared across all pages so the gradient/atmosphere persists
            // when navigating between Home, Location, Activity, Preferences, Account.
            ZStack {
                backgroundGradient
                atmosphericOverlay
                WeatherEffectLayer(
                    condition: currentCondition,
                    // Fade weather effects on non-home pages by feigning a deep scroll.
                    scrollOffset: currentPage == .home ? scrollOffset : 600
                )
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.55), value: selectedDayIndex)
            .animation(.easeInOut(duration: 0.55), value: currentCondition)
            .animation(.easeInOut(duration: 0.35), value: currentPage)

            // Page content — switches based on the bottom pill selection.
            currentPageView
                .transition(.opacity)
        }
        .overlay(alignment: .bottom) {
            BottomMenuPill(
                selectedActivity: selectedActivity,
                selectedItem: $currentPage
            )
            .padding(.bottom, 18)
        }
        .overlay {
            if isShowingConditions {
                ConditionsIsland(day: selectedDay, title: conditionsTitle) {
                    isShowingConditions = false
                }
                .zIndex(10)
            }
        }
        .overlay {
            if let spot = selectedSpot {
                TrailSpotIsland(spot: spot) {
                    selectedSpot = nil
                }
                .zIndex(11)
            }
        }
        .onChange(of: currentPage) { _, _ in
            // Leaving the home page dismisses any open island.
            if isShowingConditions { isShowingConditions = false }
            if selectedSpot != nil { selectedSpot = nil }
        }
        .sensoryFeedback(.selection, trigger: selectedDayIndex)
        .sensoryFeedback(.selection, trigger: selectedActivity)
        .sensoryFeedback(.selection, trigger: currentPage)
        .sensoryFeedback(.impact(weight: .light), trigger: isShowingConditions)
        .sensoryFeedback(.impact(weight: .light), trigger: selectedSpot?.id)
        .animation(.easeInOut(duration: 0.32), value: currentPage)
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: isShowingConditions)
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: selectedSpot?.id)
    }

    @ViewBuilder
    private var currentPageView: some View {
        switch currentPage {
        case .home:
            homePage
        case .location:
            LocationPage(location: $location)
        case .activity:
            ActivityPage(selectedActivity: $selectedActivity)
        case .preferences:
            PreferencesPage()
        case .account:
            AccountPage()
        }
    }

    /// Home page architecture (Session 004 fix):
    /// - `safeAreaInset(.top)` reserves a FIXED-height strip (`pinInset`) where the
    ///   LazyVStack's pinned section headers pin. It's never tied to `scrollOffset`,
    ///   so there's no feedback loop between the scroll offset and the inset height.
    /// - A transparent spacer of `shrinkRange` sits above the LazyVStack so the
    ///   first section begins at the expanded hero's bottom edge on first render.
    /// - The collapsing hero is a plain overlay in the ZStack on top of the
    ///   scroll view (the layout that collapsed correctly pre-restructure).
    private var homePage: some View {
        GeometryReader { geo in
            let topSafe = geo.safeAreaInsets.top
            let expandedHeroHeight = min(geo.size.height * 0.92, max(360, measuredHeroHeight))
            let collapsedHeroHeight: CGFloat = topSafe + 70
            let shrinkRange = max(1, expandedHeroHeight - collapsedHeroHeight)
            let currentHeroHeight = min(
                expandedHeroHeight,
                max(collapsedHeroHeight, expandedHeroHeight - scrollOffset)
            )
            let progress: CGFloat = (expandedHeroHeight - currentHeroHeight) / shrinkRange
            // Fixed strip that marks where the pinned headers pin (just under the
            // collapsed hero). Never scroll-dependent.
            let pinInset = max(0, collapsedHeroHeight - topSafe)

            ZStack(alignment: .top) {
                // Invisible probe to measure the hero's natural content height.
                HeroZone(day: selectedDay, location: location, activity: selectedActivity,
                         conditionsTitle: conditionsTitle, conditionsSubtitle: conditionsSubtitle,
                         progress: 0, topInset: topSafe, onConditionsTap: {})
                    .background(GeometryReader { p in
                        Color.clear.preference(key: HeroContentHeightKey.self, value: p.size.height)
                    })
                    .frame(maxWidth: .infinity)
                    .opacity(0)
                    .allowsHitTesting(false)

                ScrollView {
                    VStack(spacing: 0) {
                        // Spacer covering the expanded hero above the pinned line, so the
                        // first section begins at the expanded hero's bottom edge.
                        Color.clear.frame(height: shrinkRange)

                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            Section { forecastRows } header: {
                                pinnedSectionHeader(title: "7-DAY FORECAST")
                            }
                            Section { nearbyTilesGrid } header: {
                                pinnedSectionHeader(title: "NEARBY TRAILS & PARKS")
                            }
                            Color.clear.frame(height: 120)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onScrollGeometryChange(for: CGFloat.self) { geo in
                    geo.contentOffset.y + geo.contentInsets.top
                } action: { _, newValue in
                    scrollOffset = max(0, newValue)
                }
                // FIXED inset: stable pin line, no feedback with scrollOffset.
                .safeAreaInset(edge: .top, spacing: 0) {
                    Color.clear.frame(height: pinInset)
                }

                // Collapsing hero as a plain overlay on top.
                HeroZone(day: selectedDay, location: location, activity: selectedActivity,
                         conditionsTitle: conditionsTitle, conditionsSubtitle: conditionsSubtitle,
                         progress: progress, topInset: topSafe,
                         onConditionsTap: { isShowingConditions = true })
                    .frame(height: currentHeroHeight, alignment: .top)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            .onPreferenceChange(HeroContentHeightKey.self) { newValue in
                if newValue > 0, abs(newValue - measuredHeroHeight) > 1 {
                    measuredHeroHeight = newValue
                }
            }
        }
    }

    private var backgroundGradient: LinearGradient {
        let pair = backgroundColors
        return LinearGradient(
            colors: [pair.top, pair.bottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var backgroundColors: (top: Color, bottom: Color) {
        switch (selectedDay.verdict, currentCondition) {
        // Snow overrides verdict — same wash regardless.
        case (_, .snow):
            return (Color(red: 0.48, green: 0.55, blue: 0.62),
                    Color(red: 0.65, green: 0.70, blue: 0.75))

        // GO
        case (.go, .clear):
            return (Color(red: 0.27, green: 0.49, blue: 0.38),
                    Color(red: 0.42, green: 0.61, blue: 0.50))
        case (.go, .partlyCloudy):
            return (Color(red: 0.32, green: 0.47, blue: 0.42),
                    Color(red: 0.48, green: 0.60, blue: 0.53))
        case (.go, .cloudy), (.go, .overcast), (.go, .rain), (.go, .storm):
            return (Color(red: 0.36, green: 0.45, blue: 0.43),
                    Color(red: 0.50, green: 0.58, blue: 0.55))

        // CAUTION
        case (.caution, .clear):
            return (Color(red: 0.62, green: 0.45, blue: 0.22),
                    Color(red: 0.78, green: 0.58, blue: 0.32))
        case (.caution, .partlyCloudy), (.caution, .cloudy), (.caution, .overcast):
            return (Color(red: 0.48, green: 0.40, blue: 0.28),
                    Color(red: 0.62, green: 0.52, blue: 0.40))
        case (.caution, .rain), (.caution, .storm):
            return (Color(red: 0.38, green: 0.35, blue: 0.32),
                    Color(red: 0.55, green: 0.48, blue: 0.42))

        // NO-GO
        case (.noGo, .clear):
            return (Color(red: 0.42, green: 0.28, blue: 0.30),
                    Color(red: 0.55, green: 0.40, blue: 0.42))
        case (.noGo, .partlyCloudy), (.noGo, .cloudy), (.noGo, .overcast):
            return (Color(red: 0.28, green: 0.30, blue: 0.34),
                    Color(red: 0.45, green: 0.45, blue: 0.48))
        case (.noGo, .rain), (.noGo, .storm):
            return (Color(red: 0.22, green: 0.26, blue: 0.32),
                    Color(red: 0.38, green: 0.42, blue: 0.48))
        }
    }

    // MARK: Atmosphere — condition-aware sky layers stacked over the linear gradient.

    private var atmosphericOverlay: some View {
        ZStack {
            primarySkyHighlight
            cloudLayer
            precipitationDarkening
        }
    }

    /// Primary "light source" — a sun-like spot for clear/partly cloudy, a diffuse glow for
    /// cloudy/overcast/snow, and a dim, central wash for rain/storm.
    private var primarySkyHighlight: some View {
        let cfg = skyHighlightConfig
        return RadialGradient(
            colors: [.white.opacity(cfg.opacity), .clear],
            center: UnitPoint(x: cfg.x, y: cfg.y),
            startRadius: 0,
            endRadius: cfg.radius
        )
    }

    private var skyHighlightConfig: (x: CGFloat, y: CGFloat, opacity: Double, radius: CGFloat) {
        switch currentCondition {
        case .clear:        return (0.72, 0.04, 0.55, 340)  // sun, upper-right
        case .partlyCloudy: return (0.68, 0.06, 0.42, 360)  // sun peeking through
        case .cloudy:       return (0.50, 0.10, 0.24, 480)  // diffuse, centered
        case .overcast:     return (0.50, 0.15, 0.14, 540)  // very diffuse
        case .rain:         return (0.50, 0.08, 0.10, 380)  // dim
        case .storm:        return (0.50, 0.05, 0.07, 320)  // dimmer
        case .snow:         return (0.50, 0.08, 0.50, 600)  // bright, reflective
        }
    }

    /// Soft elliptical "cloud" blobs for conditions with visible cloud cover.
    @ViewBuilder
    private var cloudLayer: some View {
        switch currentCondition {
        case .partlyCloudy:
            ZStack {
                EllipticalGradient(
                    colors: [.white.opacity(0.22), .clear],
                    center: UnitPoint(x: 0.22, y: 0.18),
                    startRadiusFraction: 0,
                    endRadiusFraction: 0.32
                )
                EllipticalGradient(
                    colors: [.white.opacity(0.16), .clear],
                    center: UnitPoint(x: 0.92, y: 0.30),
                    startRadiusFraction: 0,
                    endRadiusFraction: 0.26
                )
            }
        case .cloudy, .overcast:
            ZStack {
                EllipticalGradient(
                    colors: [.white.opacity(0.20), .clear],
                    center: UnitPoint(x: 0.25, y: 0.12),
                    startRadiusFraction: 0,
                    endRadiusFraction: 0.48
                )
                EllipticalGradient(
                    colors: [.white.opacity(0.16), .clear],
                    center: UnitPoint(x: 0.82, y: 0.22),
                    startRadiusFraction: 0,
                    endRadiusFraction: 0.42
                )
            }
        case .snow:
            EllipticalGradient(
                colors: [.white.opacity(0.18), .clear],
                center: UnitPoint(x: 0.5, y: 0.18),
                startRadiusFraction: 0,
                endRadiusFraction: 0.55
            )
        case .clear, .rain, .storm:
            EmptyView()
        }
    }

    /// Pulls the top edge down for rain/storm so the sky reads as heavy and overcast.
    @ViewBuilder
    private var precipitationDarkening: some View {
        switch currentCondition {
        case .rain:
            LinearGradient(
                colors: [.black.opacity(0.22), .clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.38)
            )
        case .storm:
            LinearGradient(
                colors: [.black.opacity(0.32), .clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.42)
            )
        default:
            EmptyView()
        }
    }

    // MARK: 7-day forecast

    // MARK: 7-day forecast rows (header lives in LazyVStack as a pinned section header)

    private var forecastRows: some View {
        VStack(spacing: 0) {
            ForEach(Array(forecast.enumerated()), id: \.element.id) { index, day in
                DayRow(
                    day: day,
                    isToday: index == 0,
                    isSelected: index == selectedDayIndex
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        selectedDayIndex = index
                    }
                }
                if index < forecast.count - 1 {
                    Rectangle()
                        .fill(.white.opacity(0.15))
                        .frame(height: 0.5)
                        .padding(.leading, 24)
                }
            }
        }
    }

    // MARK: Nearby trails grid (header lives in LazyVStack as a pinned section header)

    private var nearbyTilesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ],
            spacing: 12
        ) {
            ForEach(MockData.nearbySpots) { spot in
                TrailTile(spot: spot) {
                    selectedSpot = spot
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    /// Pinned section header rendered behind a translucent frosted bar so rows
    /// don't bleed through while it's pinned at the top of the scroll view's
    /// safe area (which itself sits just below the collapsing hero).
    private func pinnedSectionHeader(title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .tracking(1.5)
            .foregroundStyle(.white.opacity(0.88))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 10)
            .background {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    Color.black.opacity(0.18)
                }
            }
    }
}

// MARK: - Day Row

struct DayRow: View {
    let day: DayForecast
    let isToday: Bool
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            Text(isToday ? "Today" : day.date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.body.weight(isToday ? .semibold : .regular))
                .foregroundStyle(.white)
                .frame(width: 70, alignment: .leading)

            Image(systemName: day.symbol)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .frame(width: 36, alignment: .center)

            Text("\(day.high)°  \(day.low)°")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
                .monospacedDigit()

            Spacer(minLength: 0)

            VerdictPill(verdict: day.verdict, emphasized: isSelected)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            isSelected
                ? Color.white.opacity(0.08)
                : Color.clear
        )
    }
}

struct VerdictPill: View {
    let verdict: Verdict
    let emphasized: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(verdict.color)
                .frame(width: 7, height: 7)
            Text(verdict.rawValue)
                .font(.caption2.weight(.bold))
                .tracking(0.6)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(.white.opacity(emphasized ? 0.28 : 0.18))
        )
    }
}

// MARK: - Trail Tile

/// One tile in the "Nearby Trails & Parks" grid below the 7-day forecast.
/// Kind label + icon at the top, name, detail, and a verdict pill at the bottom.
struct TrailTile: View {
    let spot: TrailSpot
    let onTap: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: spot.kind.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                    Text(spot.kind.label)
                        .font(.caption2.weight(.semibold))
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.75))
                    Spacer(minLength: 0)
                }

                Text(spot.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(spot.detail)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(1)

                Spacer(minLength: 0)

                VerdictPill(verdict: spot.verdict, emphasized: false)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 0.5)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel("\(spot.name), \(spot.kind.label.lowercased()), \(spot.detail), \(spot.verdict.rawValue)")
    }
}

// MARK: - Hero Zone
//
// The sticky three-section header on the home page: verdict → insights (what to
// expect / down-time prep) → current conditions row. Driven by a 0…1 `progress`
// value that comes from scroll offset: 0 = fully expanded (fills the screen),
// 1 = fully collapsed (a compact persistent bar).
//
// A single layout interpolates sizes/paddings/opacities continuously so no two
// rendered states ever overlap. A row-layout swap (vertical insights ↔ icon row,
// full conditions ↔ compact conditions) happens once past `isCondensed` and is
// animated so the discrete change still reads as continuous.

struct HeroZone: View {
    let day: DayForecast
    let location: String
    let activity: Activity
    let conditionsTitle: String
    let conditionsSubtitle: String
    let progress: CGFloat
    let topInset: CGFloat
    let onConditionsTap: () -> Void

    private var insightsTitle: String {
        switch day.verdict {
        case .go, .caution: return "What to Expect"
        case .noGo:         return "Down Time Prep"
        }
    }

    /// True once we're far enough into the collapse that we should swap the
    /// row layouts (insights → icon row, conditions → compact row).
    private var isCondensed: Bool { progress > 0.5 }

    /// Linearly interpolates a → b based on `progress`.
    private func lerp(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        a + (b - a) * progress
    }

    /// 1 at progress 0, fading to 0 by `endProgress`.
    private func fadeOut(by endProgress: CGFloat) -> Double {
        Double(max(0, min(1, 1 - progress / endProgress)))
    }

    /// 0 until `startProgress`, fading to 1 at progress 1.
    private func fadeIn(from startProgress: CGFloat) -> Double {
        guard progress > startProgress else { return 0 }
        return Double(min(1, (progress - startProgress) / (1 - startProgress)))
    }

    var body: some View {
        VStack(spacing: lerp(10, 8)) {
            decisionBlock
            if !isCondensed {
                insightsBlock
                    .opacity(fadeOut(by: 0.5))
                    .transition(.opacity)
            }
            conditionsBlock
        }
        .padding(.horizontal, 20)
        .padding(.top, topInset + lerp(10, 6))
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .top)
        .background {
            // Frosted backdrop fades in alongside collapse so the compact bar
            // reads clearly against the forecast scrolling underneath.
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Color.black.opacity(0.20)
            }
            .opacity(Double(progress))
            .ignoresSafeArea(edges: .top)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.white.opacity(0.20))
                .frame(height: 0.5)
                .opacity(Double(progress))
        }
        .animation(.easeInOut(duration: 0.2), value: isCondensed)
    }

    // MARK: Decision

    private var decisionBlock: some View {
        VStack(spacing: lerp(10, 4)) {
            // Caption: location · activity (collapses height + opacity together).
            Text("\(location.uppercased())  ·  \(activity.rawValue.uppercased())")
                .font(.caption.weight(.semibold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .opacity(fadeOut(by: 0.35))
                .frame(height: lerp(18, 0), alignment: .top)
                .clipped()

            // Verdict line. A small color dot fades in as we collapse; when
            // condensed, the headline sits inline to the right of the verdict
            // for a single-line "GO · Good to head out" badge style.
            HStack(spacing: 8) {
                Circle()
                    .fill(day.verdict.color)
                    .frame(width: lerp(0, 8), height: lerp(0, 8))
                    .opacity(fadeIn(from: 0.35))

                Text(day.verdict.rawValue)
                    .font(.system(size: lerp(64, 15), weight: .bold))
                    .tracking(day.verdict == .noGo ? -2 : 0)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                if isCondensed {
                    Text(day.verdict.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .transition(.opacity)
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: isCondensed ? .leading : .center)

            // Centered headline only when expanded — condensed shares the line above.
            if !isCondensed {
                Text(day.verdict.headline)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .transition(.opacity)
            }

            // Summary fades + height collapses together so no leftover gap remains.
            Text(day.verdict.summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(fadeOut(by: 0.45))
                .frame(maxHeight: lerp(60, 0), alignment: .top)
                .clipped()
        }
    }

    // MARK: Insights

    private var insightsBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(insightsTitle.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.78))

            VStack(spacing: 6) {
                ForEach(day.insights.prefix(5)) { insight in
                    InsightRow(item: insight)
                }
            }
        }
        .padding(.top, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Conditions

    private var conditionsBlock: some View {
        Button(action: onConditionsTap) {
            HStack(spacing: 12) {
                if isCondensed {
                    Image(systemName: day.symbol)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.88))
                    Text("\(day.high)°  ·  \(day.condition)")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                } else {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(conditionsTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(conditionsSubtitle)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.78))
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(isCondensed ? .caption.weight(.bold) : .subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.65))
            }
            .padding(.horizontal, isCondensed ? 0 : 4)
            .padding(.vertical, lerp(14, 4))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            // Hairline above conditions only appears in expanded state.
            if !isCondensed {
                Rectangle()
                    .fill(.white.opacity(0.18))
                    .frame(height: 0.5)
                    .padding(.horizontal, -4)
                    .transition(.opacity)
            }
        }
    }
}

private struct InsightRow: View {
    let item: InsightItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.callout)
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
            Text(item.title)
                .font(.callout)
                .foregroundStyle(.white)
                .lineLimit(2)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
    }
}

// MARK: - Conditions Island
//
// A centered floating panel ("island") that overlays the home page instead of
// sliding up as a sheet. Backed by `.regularMaterial` over a dim base so the
// frosted look is noticeably more opaque than the rest of the app's glass cards,
// giving this surface the focus it earns when a user drills into a forecast.

struct ConditionsIsland: View {
    let day: DayForecast
    let title: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Dim backdrop; tap anywhere outside the card to dismiss.
            Color.black.opacity(0.42)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onDismiss() }
                .transition(.opacity)

            island
                .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private var island: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            verdictBlock

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FactorSection(type: .weather, detail: day.weather)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 16)
                    sectionDivider
                    FactorSection(type: .terrain, detail: day.terrain)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 16)
                    sectionDivider
                    FactorSection(type: .daylight, detail: day.daylight)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 16)
                }
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: 420)
        .background(islandBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.55), radius: 30, x: 0, y: 18)
        .padding(.horizontal, 22)
        // Top padding clears the status bar; bottom padding clears the floating
        // menu pill so the island never overlaps it.
        .padding(.top, 60)
        .padding(.bottom, 120)
    }

    /// Renders a deeply opaque frosted surface: a `.thickMaterial` backdrop blur
    /// with a heavy dark overlay on top so white text reads clearly against any
    /// underlying gradient or weather effect.
    private var islandBackground: some View {
        ZStack {
            Rectangle().fill(.thickMaterial)
            Color.black.opacity(0.55)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption2.weight(.semibold))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.88))
                Text(day.date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.96))
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(.white.opacity(0.20), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.30), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 14)
    }

    private var verdictBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(day.verdict.rawValue)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                Text(day.verdict.headline)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            Text(day.verdict.summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 12)
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.12))
            .frame(height: 0.5)
            .padding(.horizontal, 22)
    }
}

// MARK: - Trail Spot Island
//
// Same frosted shell as ConditionsIsland, but the body is the spot's verdict
// summary plus the list of insights (What to Expect for go/caution, Down Time
// Prep for no-go). Capped at five insight rows.

struct TrailSpotIsland: View {
    let spot: TrailSpot
    let onDismiss: () -> Void

    private var insightsLabel: String {
        switch spot.verdict {
        case .go, .caution: return "What to Expect"
        case .noGo:         return "Down Time Prep"
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onDismiss() }
                .transition(.opacity)

            island
                .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private var island: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            verdictBlock

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(insightsLabel.uppercased())
                        .font(.caption.weight(.semibold))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.82))

                    VStack(spacing: 8) {
                        ForEach(spot.insights.prefix(5)) { insight in
                            InsightRow(item: insight)
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 4)
                .padding(.bottom, 22)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: 420)
        .background(islandBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.55), radius: 30, x: 0, y: 18)
        .padding(.horizontal, 22)
        // Same top/bottom padding as ConditionsIsland so it never covers the pill.
        .padding(.top, 60)
        .padding(.bottom, 120)
    }

    private var islandBackground: some View {
        ZStack {
            Rectangle().fill(.thickMaterial)
            Color.black.opacity(0.55)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: spot.kind.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(spot.kind.label)
                        .font(.caption2.weight(.semibold))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Text(spot.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(spot.detail)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
            }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(.white.opacity(0.20), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.30), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 14)
    }

    private var verdictBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(spot.verdict.rawValue)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                Text(spot.verdict.headline)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            Text(spot.verdict.summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 14)
    }
}

struct FactorSection: View {
    let type: FactorType
    let detail: FactorDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundStyle(detail.verdict.color)
                    .frame(width: 24)
                Text(type.title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(detail.verdict.color)
                        .frame(width: 7, height: 7)
                    Text(detail.verdict.rawValue)
                        .font(.caption.weight(.semibold))
                        .tracking(0.5)
                        .foregroundStyle(detail.verdict.color)
                }
            }

            Text(detail.summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                ForEach(Array(detail.metrics.enumerated()), id: \.element.id) { index, metric in
                    HStack(spacing: 12) {
                        Image(systemName: metric.icon)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(width: 22)
                        Text(metric.label)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(metric.value)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                    }
                    .padding(.vertical, 10)
                    if index < detail.metrics.count - 1 {
                        Rectangle()
                            .fill(.white.opacity(0.14))
                            .frame(height: 0.5)
                    }
                }
            }
        }
    }
}

// MARK: - Scroll Offset Plumbing

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Published by the invisible expanded-hero probe so the home page can size
/// `expandedHeroHeight` to the natural content height.
struct HeroContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Weather Effect Layer
//
// Sits in the background ZStack between the gradient and the content. Renders animated
// atmospherics keyed off `condition`. Total opacity fades from 1 → 0 as the user scrolls
// the first 300pt (Apple Weather behavior). Hit testing is disabled so it can never block
// taps on the verdict / row / forecast above.

struct WeatherEffectLayer: View {
    let condition: WeatherCondition
    let scrollOffset: CGFloat

    var body: some View {
        ZStack {
            switch condition {
            case .clear:
                SunGlow()
            case .partlyCloudy:
                SunGlow()
                DriftingClouds(count: 3, baseOpacity: 0.32, sizeScale: 1.0)
            case .cloudy, .overcast:
                DriftingClouds(count: 5, baseOpacity: 0.45, sizeScale: 1.15)
            case .rain:
                RainEffect()
            case .snow:
                SnowEffect()
            case .storm:
                RainEffect()
                LightningFlash()
            }
        }
        .opacity(max(0, 1 - scrollOffset / 300))
        .allowsHitTesting(false)
    }
}

// MARK: Sun Glow

struct SunGlow: View {
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.55),
                            Color(red: 1.0, green: 0.92, blue: 0.70).opacity(0.30),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .scaleEffect(pulse)
                .position(x: geo.size.width * 0.82, y: 130)
                .onAppear {
                    // 2s ease + 2s reverse = 4s repeatForever cycle.
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        pulse = 1.18
                    }
                }
        }
    }
}

// MARK: Drifting Clouds

private struct Cloud: Identifiable {
    let id = UUID()
    let yFraction: CGFloat       // vertical position as fraction of canvas height
    let widthScale: CGFloat
    let opacity: Double
    let crossSeconds: Double     // 60–120s
    let phase: Double            // 0…1 starting offset
}

struct DriftingClouds: View {
    let count: Int
    let baseOpacity: Double
    let sizeScale: CGFloat

    @State private var clouds: [Cloud] = []

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                ZStack {
                    ForEach(clouds) { cloud in
                        let cyclePos = ((t / cloud.crossSeconds) + cloud.phase)
                            .truncatingRemainder(dividingBy: 1.0)
                        let span = geo.size.width + 400
                        let x = -200 + span * cyclePos
                        let y = cloud.yFraction * min(geo.size.height, 500)
                        Ellipse()
                            .fill(Color.white.opacity(cloud.opacity))
                            .frame(
                                width: 240 * cloud.widthScale * sizeScale,
                                height: 90 * sizeScale
                            )
                            .blur(radius: 22)
                            .position(x: x, y: y)
                    }
                }
            }
            .onAppear {
                if clouds.isEmpty { clouds = makeClouds() }
            }
        }
    }

    private func makeClouds() -> [Cloud] {
        (0..<count).map { i in
            let progress = count > 1 ? Double(i) / Double(count - 1) : 0.5
            return Cloud(
                yFraction: CGFloat(0.10 + progress * 0.55),
                widthScale: CGFloat.random(in: 0.85...1.25),
                opacity: baseOpacity * Double.random(in: 0.7...1.0),
                crossSeconds: 60 + progress * 60,  // spread 60→120s
                phase: Double.random(in: 0...1)
            )
        }
    }
}

// MARK: Rain

private struct RainStreak: Identifiable {
    let id = UUID()
    var x: CGFloat
    var phaseStart: TimeInterval
    let duration: Double           // 0.8–1.4s
}

struct RainEffect: View {
    @State private var streaks: [RainStreak] = []

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
                let now = context.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    for streak in streaks {
                        let elapsed = now - streak.phaseStart
                        let progress = max(0, min(1, elapsed / streak.duration))
                        let y = -12 + (size.height + 24) * progress
                        let rect = CGRect(x: streak.x - 0.75, y: y, width: 1.5, height: 12)
                        ctx.fill(Capsule().path(in: rect), with: .color(.white.opacity(0.4)))
                    }
                }
            }
            .task(id: geo.size) {
                if streaks.isEmpty {
                    streaks = (0..<40).map { _ in makeStreak(in: geo.size, fresh: false) }
                }
                // Recycle finished streaks with new random x, slightly off the 60fps render path.
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 50_000_000)  // 20Hz
                    let now = Date().timeIntervalSinceReferenceDate
                    for i in streaks.indices where now - streaks[i].phaseStart >= streaks[i].duration {
                        streaks[i] = makeStreak(in: geo.size, fresh: true)
                    }
                }
            }
        }
    }

    private func makeStreak(in size: CGSize, fresh: Bool) -> RainStreak {
        let duration = Double.random(in: 0.8...1.4)
        let now = Date().timeIntervalSinceReferenceDate
        // Stagger initial seeding so the first frame already has streaks at every height.
        let phaseStart = fresh ? now : now - Double.random(in: 0...duration)
        return RainStreak(
            x: CGFloat.random(in: 0...max(size.width, 1)),
            phaseStart: phaseStart,
            duration: duration
        )
    }
}

// MARK: Snow

private struct Snowflake: Identifiable {
    let id = UUID()
    var baseX: CGFloat
    var phaseStart: TimeInterval
    let duration: Double           // 3–5s
    let size: CGFloat
    let swayAmp: CGFloat
    let swayFreq: Double
    let swayPhase: Double
}

struct SnowEffect: View {
    @State private var flakes: [Snowflake] = []

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
                let now = context.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    for flake in flakes {
                        let elapsed = now - flake.phaseStart
                        let progress = max(0, min(1, elapsed / flake.duration))
                        let y = -8 + (size.height + 16) * progress
                        let sway = sin(elapsed * flake.swayFreq + flake.swayPhase) * flake.swayAmp
                        let x = flake.baseX + sway
                        let r = flake.size / 2
                        let rect = CGRect(x: x - r, y: y - r, width: flake.size, height: flake.size)
                        ctx.fill(Circle().path(in: rect), with: .color(.white.opacity(0.75)))
                    }
                }
            }
            .task(id: geo.size) {
                if flakes.isEmpty {
                    flakes = (0..<40).map { _ in makeFlake(in: geo.size, fresh: false) }
                }
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 100_000_000)  // 10Hz
                    let now = Date().timeIntervalSinceReferenceDate
                    for i in flakes.indices where now - flakes[i].phaseStart >= flakes[i].duration {
                        flakes[i] = makeFlake(in: geo.size, fresh: true)
                    }
                }
            }
        }
    }

    private func makeFlake(in size: CGSize, fresh: Bool) -> Snowflake {
        let duration = Double.random(in: 3.0...5.0)
        let now = Date().timeIntervalSinceReferenceDate
        let phaseStart = fresh ? now : now - Double.random(in: 0...duration)
        return Snowflake(
            baseX: CGFloat.random(in: 0...max(size.width, 1)),
            phaseStart: phaseStart,
            duration: duration,
            size: CGFloat.random(in: 3...6),
            swayAmp: CGFloat.random(in: 10...26),
            swayFreq: Double.random(in: 0.5...1.2),
            swayPhase: Double.random(in: 0...(2 * .pi))
        )
    }
}

// MARK: Lightning Flash

struct LightningFlash: View {
    @State private var flashOpacity: Double = 0

    var body: some View {
        Rectangle()
            .fill(Color.white)
            .opacity(flashOpacity)
            .ignoresSafeArea()
            .task {
                // Loop forever: wait 4–10s, jump opacity to 0.3, fade to 0 over 0.2s.
                while !Task.isCancelled {
                    let delay = Double.random(in: 4...10)
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    guard !Task.isCancelled else { break }
                    withAnimation(.easeIn(duration: 0.04)) {
                        flashOpacity = 0.3
                    }
                    try? await Task.sleep(nanoseconds: 40_000_000)
                    withAnimation(.easeOut(duration: 0.2)) {
                        flashOpacity = 0
                    }
                }
            }
    }
}

// MARK: - Bottom Menu Pill
//
// A single glass capsule that houses all four top-level menus. The tapped segment
// expands to reveal its title; the highlight slides between segments via
// `matchedGeometryEffect`. `.ultraThinMaterial` renders poorly in the simulator —
// test on device for the real frosted-glass effect.

struct BottomMenuPill: View {
    let selectedActivity: Activity
    @Binding var selectedItem: MenuItem

    @Namespace private var pillAnimation

    var body: some View {
        HStack(spacing: 2) {
            ForEach(MenuItem.allCases) { item in
                Button {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                        selectedItem = item
                    }
                } label: {
                    segment(for: item)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
            }
        }
        .padding(5)
        .background {
            Capsule().fill(.ultraThinMaterial)
        }
        .overlay(Capsule().stroke(.white.opacity(0.28), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 5)
    }

    @ViewBuilder
    private func segment(for item: MenuItem) -> some View {
        let isSelected = selectedItem == item
        HStack(spacing: 6) {
            Image(systemName: iconName(for: item))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.28), radius: 2, x: 0, y: 1)
                .frame(width: 20, height: 20)
                .contentTransition(.symbolEffect(.replace))

            if isSelected {
                Text(item.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .fixedSize()
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .padding(.horizontal, isSelected ? 11 : 8)
        .padding(.vertical, 9)
        .background {
            if isSelected {
                Capsule()
                    .fill(.white.opacity(0.22))
                    .overlay(Capsule().stroke(.white.opacity(0.32), lineWidth: 0.5))
                    .matchedGeometryEffect(id: "pillSelection", in: pillAnimation)
            }
        }
    }

    private func iconName(for item: MenuItem) -> String {
        switch item {
        case .activity: return selectedActivity.icon
        default: return item.icon
        }
    }
}

// MARK: - Page Helpers
//
// Shared building blocks so each page reads the same way on top of the gradient
// background: a large header, a translucent "glass card" grouping rows, and small
// section labels. Rows are styled white-on-glass to match the home page.

private struct PageHeader: View {
    let title: String
    let subtitle: String?

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(.white)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 64)
        .padding(.bottom, 12)
    }
}

private struct PageSectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.5)
            .foregroundStyle(.white.opacity(0.62))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, -4)
    }
}

private struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
    }
}

private struct GlassRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.14))
            .frame(height: 0.5)
            .padding(.leading, 56)
    }
}

private struct PageScaffold<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                content()
            }
            .padding(.bottom, 120)  // breathing room above the floating menu pill
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Location Page

struct LocationPage: View {
    @Binding var location: String
    @State private var searchText: String = ""

    private let recent = ["Boulder, CO", "Chautauqua Park", "Mt. Sanitas Trail", "Flagstaff Mountain"]
    private let popular = [
        "Rocky Mountain National Park",
        "Eldorado Canyon State Park",
        "Indian Peaks Wilderness",
        "Lost Lake Trail",
    ]

    private var filteredRecent: [String] {
        searchText.isEmpty ? recent : recent.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private var filteredPopular: [String] {
        searchText.isEmpty ? popular : popular.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        PageScaffold {
            PageHeader(title: "Location", subtitle: "Currently: \(location)")

            // Search field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.7))
                TextField(
                    "",
                    text: $searchText,
                    prompt: Text("Search location, trail, or park")
                        .foregroundColor(.white.opacity(0.55))
                )
                .foregroundStyle(.white)
                .tint(.white)
                .textInputAutocapitalization(.words)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5))
            .padding(.horizontal, 20)

            GlassCard {
                LocationRow(
                    name: "Use Current Location",
                    icon: "location.fill",
                    isSelected: false,
                    accent: true
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        location = "Current Location"
                    }
                }
            }

            if !filteredRecent.isEmpty {
                PageSectionHeader(title: "Recent")
                GlassCard {
                    ForEach(Array(filteredRecent.enumerated()), id: \.element) { idx, name in
                        LocationRow(
                            name: name,
                            icon: "clock.arrow.circlepath",
                            isSelected: name == location,
                            accent: false
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                location = name
                            }
                        }
                        if idx < filteredRecent.count - 1 {
                            GlassRowDivider()
                        }
                    }
                }
            }

            if !filteredPopular.isEmpty {
                PageSectionHeader(title: "Trails & Parks")
                GlassCard {
                    ForEach(Array(filteredPopular.enumerated()), id: \.element) { idx, name in
                        LocationRow(
                            name: name,
                            icon: "mountain.2.fill",
                            isSelected: name == location,
                            accent: false
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                location = name
                            }
                        }
                        if idx < filteredPopular.count - 1 {
                            GlassRowDivider()
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: location)
    }
}

private struct LocationRow: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let accent: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(accent ? Color(red: 0.62, green: 0.88, blue: 1.0) : .white)
                .frame(width: 28)

            Text(name)
                .font(.body)
                .foregroundStyle(accent ? Color(red: 0.62, green: 0.88, blue: 1.0) : .white)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Activity Page

struct ActivityPage: View {
    @Binding var selectedActivity: Activity

    private var available: [Activity] { Activity.allCases.filter(\.isAvailable) }
    private var comingSoon: [Activity] { Activity.allCases.filter { !$0.isAvailable } }

    var body: some View {
        PageScaffold {
            PageHeader(title: "Activity", subtitle: "Currently: \(selectedActivity.rawValue)")

            GlassCard {
                ForEach(Array(available.enumerated()), id: \.element.id) { idx, activity in
                    ActivityRow(
                        activity: activity,
                        isSelected: activity == selectedActivity,
                        isDisabled: false
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedActivity = activity
                        }
                    }
                    if idx < available.count - 1 {
                        GlassRowDivider()
                    }
                }
            }

            if !comingSoon.isEmpty {
                PageSectionHeader(title: "Coming Soon")
                GlassCard {
                    ForEach(Array(comingSoon.enumerated()), id: \.element.id) { idx, activity in
                        ActivityRow(
                            activity: activity,
                            isSelected: false,
                            isDisabled: true
                        )
                        if idx < comingSoon.count - 1 {
                            GlassRowDivider()
                        }
                    }
                }
            }
        }
    }
}

struct ActivityRow: View {
    let activity: Activity
    let isSelected: Bool
    let isDisabled: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: activity.icon)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isDisabled ? Color.white.opacity(0.4) : .white)
                .frame(width: 28)

            Text(activity.rawValue)
                .font(.body)
                .foregroundStyle(isDisabled ? Color.white.opacity(0.45) : .white)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Preferences Page

struct PreferencesPage: View {
    @State private var units: String = "Imperial"
    @State private var minTemp: Double = 40
    @State private var maxTemp: Double = 85
    @State private var maxWind: Double = 20
    @State private var maxPrecip: Double = 40
    @State private var minDaylight: Double = 4

    var body: some View {
        PageScaffold {
            PageHeader(
                title: "Preferences",
                subtitle: "Tune the limits that decide Go, Caution, and No-Go for you."
            )

            PageSectionHeader(title: "Units")
            GlassCard {
                HStack(spacing: 14) {
                    Image(systemName: "ruler")
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(width: 28)
                    Text("System")
                        .font(.body)
                        .foregroundStyle(.white)
                    Spacer()
                    Picker("Units", selection: $units) {
                        Text("Imperial").tag("Imperial")
                        Text("Metric").tag("Metric")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }

            PageSectionHeader(title: "Temperature")
            GlassCard {
                LimitRow(label: "Lower limit", value: $minTemp, range: 0...60, step: 1, unit: "°F")
                GlassRowDivider()
                LimitRow(label: "Upper limit", value: $maxTemp, range: 60...110, step: 1, unit: "°F")
            }

            PageSectionHeader(title: "Wind")
            GlassCard {
                LimitRow(label: "Upper limit", value: $maxWind, range: 0...50, step: 1, unit: "mph")
            }

            PageSectionHeader(title: "Precipitation")
            GlassCard {
                LimitRow(label: "Upper limit", value: $maxPrecip, range: 0...100, step: 5, unit: "%")
            }

            PageSectionHeader(title: "Daylight Cushion")
            GlassCard {
                LimitRow(label: "Lower limit", value: $minDaylight, range: 1...8, step: 0.5, unit: "h")
            }

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    minTemp = 40
                    maxTemp = 85
                    maxWind = 20
                    maxPrecip = 40
                    minDaylight = 4
                }
            } label: {
                Text("Reset to Defaults")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}

struct LimitRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(formatted(value)) \(unit)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            Slider(value: $value, in: range, step: step)
                .tint(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func formatted(_ v: Double) -> String {
        if step.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(v.rounded()))
        }
        return String(format: "%.1f", v)
    }
}

// MARK: - Account Page

struct AccountPage: View {
    @State private var notificationsEnabled: Bool = true
    @State private var lowLightAlerts: Bool = true
    @State private var weeklySummary: Bool = false

    var body: some View {
        PageScaffold {
            PageHeader(title: "Account")

            GlassCard {
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Jake Jones")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("jake@vara.app")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    Spacer()
                }
                .padding(16)
            }

            PageSectionHeader(title: "Account")
            GlassCard {
                AccountLinkRow(title: "Account Details", icon: "person.text.rectangle")
                GlassRowDivider()
                AccountLinkRow(title: "Subscription", icon: "creditcard")
                GlassRowDivider()
                AccountLinkRow(title: "Connected Apps", icon: "link")
            }

            PageSectionHeader(title: "Notifications")
            GlassCard {
                AccountToggleRow(title: "Push Notifications", icon: "bell.fill", isOn: $notificationsEnabled)
                GlassRowDivider()
                AccountToggleRow(title: "Low-Light Warnings", icon: "sun.horizon.fill", isOn: $lowLightAlerts)
                GlassRowDivider()
                AccountToggleRow(title: "Weekly Summary", icon: "calendar", isOn: $weeklySummary)
            }

            PageSectionHeader(title: "App")
            GlassCard {
                AccountLinkRow(title: "About", icon: "info.circle")
                GlassRowDivider()
                AccountLinkRow(title: "Privacy", icon: "hand.raised.fill")
                GlassRowDivider()
                AccountLinkRow(title: "Help & Support", icon: "questionmark.circle")
            }

            Button(role: .destructive) {} label: {
                Text("Sign Out")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.62, blue: 0.62))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Text("Vara 1.0.0 (mock)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
    }
}

private struct AccountLinkRow: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 28)
            Text(title)
                .font(.body)
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

private struct AccountToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(width: 28)
                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)
            }
        }
        .tint(.white.opacity(0.85))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
