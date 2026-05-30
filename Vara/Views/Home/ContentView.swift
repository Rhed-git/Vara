import SwiftUI

// MARK: - Root

struct ContentView: View {
    @State private var selectedDayIndex: Int = 0
    @State private var isShowingConditions: Bool = false
    @State private var selectedSpot: TrailSpot? = nil
    @State private var favoritesStore = FavoritesStore()
    @State private var activeHomeSection: HomeSection = .readiness
    @State private var homeTransitionPulse: Bool = false
    @State private var isHomeSectionTransitioning: Bool = false
    @State private var isHomeDragActive: Bool = false
    @State private var scrollOffset: CGFloat = 0

    // Floating menu state
    @State private var location: String = "Boulder, CO"
    @State private var selectedActivity: Activity = .mountainBike
    @State private var currentPage: MenuItem = .home

    private let forecast = MockData.tenDays
    private var rightNowDay: DayForecast { forecast[0] }
    private var selectedDay: DayForecast {
        forecast[min(max(selectedDayIndex, 0), forecast.count - 1)]
    }
    private var rightNowCondition: WeatherCondition { rightNowDay.weatherCondition }
    private var selectedForecastCondition: WeatherCondition { selectedDay.weatherCondition }
    private var isViewingToday: Bool { selectedDayIndex == 0 }
    private var rightNowConditionsSubtitle: String {
        "\(rightNowDay.high)°  ·  \(rightNowDay.condition)  ·  Tap for details"
    }

    var body: some View {
        ZStack {
            VaraTopoBackground()
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.35), value: currentPage)

            VStack(spacing: 16) {
                // Page content — switches based on the bottom pill selection.
                currentPageView
                    .frame(maxHeight: .infinity)
                    .transition(.opacity)

                BottomMenuPill(
                    selectedActivity: selectedActivity,
                    selectedItem: $currentPage
                )
                .frame(height: 56)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .overlay {
            if isShowingConditions {
                ConditionsIsland(day: rightNowDay, title: "Current Conditions") {
                    isShowingConditions = false
                }
                .zIndex(10)
            }
        }
        .overlay {
            if let spot = selectedSpot {
                TrailSpotIsland(spot: spot, favoritesStore: favoritesStore) {
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
        .onChange(of: activeHomeSection) { _, newValue in
            scrollOffset = CGFloat(newValue.rawValue) * 320
            homeTransitionPulse = true
            Task {
                try? await Task.sleep(for: .milliseconds(520))
                await MainActor.run {
                    homeTransitionPulse = false
                }
            }
            Task {
                try? await Task.sleep(for: .milliseconds(650))
                await MainActor.run {
                    isHomeSectionTransitioning = false
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDayIndex)
        .sensoryFeedback(.selection, trigger: selectedActivity)
        .sensoryFeedback(.selection, trigger: currentPage)
        .sensoryFeedback(.selection, trigger: activeHomeSection)
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
        case .favorites:
            FavoritesPage(favoritesStore: favoritesStore) { spot in
                selectedSpot = spot
            }
        case .location:
            LocationPage(
                location: $location,
                favoritesStore: favoritesStore
            ) { spot in
                selectedSpot = spot
            }
        case .activity:
            ActivityPage(selectedActivity: $selectedActivity)
        case .preferences:
            PreferencesPage()
        case .account:
            AccountPage()
        }
    }

    /// Home page: three intentional stacked sections. Collapsed headers have
    /// fixed heights and the active section owns the remaining space.
    private var homePage: some View {
        GeometryReader { geo in
            let topDeckPadding = max(8, geo.safeAreaInsets.top * 0.35)
            let tabHeight: CGFloat = 52
            let tabSpacing: CGFloat = homeTransitionPulse ? 12 : 8
            let sections = HomeSection.allCases
            let topSections = sections.filter { $0.rawValue < activeHomeSection.rawValue }
            let bottomSections = sections.filter { $0.rawValue > activeHomeSection.rawValue }
            let collapsedCount = topSections.count + bottomSections.count
            let collapsedHeight = CGFloat(collapsedCount) * tabHeight
            let sectionSpacing = CGFloat(collapsedCount) * tabSpacing
            let activeHeight = max(0, geo.size.height - topDeckPadding - collapsedHeight - sectionSpacing)

            VStack(spacing: tabSpacing) {
                ForEach(topSections) { section in
                    homeSectionTab(for: section, isBottomCollapsed: false)
                        .frame(height: tabHeight)
                        .scaleEffect(0.995)
                        .opacity(1)
                }

                expandedHomeSection(activeHomeSection, topSafe: 0, availableHeight: activeHeight)
                    .frame(height: activeHeight, alignment: .top)
                    .scaleEffect(homeTransitionPulse ? 0.985 : 1, anchor: .top)
                    .shadow(
                        color: .black.opacity(homeTransitionPulse ? 0.20 : 0.16),
                        radius: homeTransitionPulse ? 18 : 14,
                        x: 0,
                        y: homeTransitionPulse ? 9 : 7
                    )
                    .allowsHitTesting(!isHomeSectionTransitioning && !isHomeDragActive)

                ForEach(bottomSections) { section in
                    homeSectionTab(for: section, isBottomCollapsed: true)
                        .frame(height: tabHeight)
                        .scaleEffect(0.97)
                        .opacity(0.9)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, topDeckPadding)
            .contentShape(Rectangle())
            .simultaneousGesture(homeSectionGesture)
            .animation(.spring(response: 0.72, dampingFraction: 0.88, blendDuration: 0.12), value: activeHomeSection)
            .animation(.spring(response: 0.52, dampingFraction: 0.88), value: homeTransitionPulse)
        }
    }

    private func setActiveHomeSection(_ section: HomeSection) {
        guard section != activeHomeSection else { return }
        isHomeSectionTransitioning = true
        withAnimation(.spring(response: 0.72, dampingFraction: 0.88, blendDuration: 0.12)) {
            activeHomeSection = section
        }
    }

    private var homeSectionGesture: some Gesture {
        DragGesture(minimumDistance: 36, coordinateSpace: .local)
            .onChanged { value in
                if abs(value.translation.height) > 12 {
                    isHomeDragActive = true
                }
            }
            .onEnded { value in
                let vertical = value.translation.height
                defer {
                    Task {
                        try? await Task.sleep(for: .milliseconds(120))
                        await MainActor.run {
                            isHomeDragActive = false
                        }
                    }
                }

                guard abs(vertical) > abs(value.translation.width) * 1.35, abs(vertical) > 70 else {
                    return
                }

                if vertical < 0, let next = activeHomeSection.next {
                    setActiveHomeSection(next)
                } else if vertical > 0, let previous = activeHomeSection.previous {
                    setActiveHomeSection(previous)
                }
            }
    }

    @ViewBuilder
    private func expandedHomeSection(_ section: HomeSection, topSafe: CGFloat, availableHeight: CGFloat) -> some View {
        switch section {
        case .readiness:
            activeHomeSheet(
                title: section.title,
                topSafe: topSafe,
                weatherCondition: rightNowCondition,
                verdict: rightNowDay.verdict
            ) {
                HeroZone(day: rightNowDay, location: location, activity: selectedActivity,
                         conditionsTitle: "Current Conditions", conditionsSubtitle: rightNowConditionsSubtitle,
                         progress: 0, topInset: 0,
                         insightLimit: availableHeight < 520 ? 4 : 5,
                         onConditionsTap: {
                             guard !isHomeSectionTransitioning && !isHomeDragActive else { return }
                             isShowingConditions = true
                         })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .clipped()
            }
        case .forecast:
            activeHomeSheet(
                title: section.title,
                topSafe: topSafe,
                weatherCondition: selectedForecastCondition,
                verdict: selectedDay.verdict
            ) {
                forecastRows
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .clipped()
            }
        case .nearby:
            activeHomeSheet(title: section.title, topSafe: topSafe) {
                nearbyTilesGrid
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .clipped()
            }
        }
    }

    private func activeHomeSheet<Content: View>(
        title: String,
        topSafe: CGFloat,
        weatherCondition: WeatherCondition? = nil,
        verdict: Verdict? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: homeTransitionPulse ? 10 : 6) {
            expandedSectionTitle(title, topSafe: topSafe)
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            activeHomeSheetBackground(weatherCondition: weatherCondition, verdict: verdict)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
        .padding(.horizontal, 10)
        .padding(.top, title == HomeSection.readiness.title ? 0 : 6)
        .padding(.bottom, 6)
        .clipped()
    }

    @ViewBuilder
    private func activeHomeSheetBackground(
        weatherCondition: WeatherCondition?,
        verdict: Verdict?
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)

        ZStack {
            shape.fill(Color.black.opacity(0.28))

            if let weatherCondition, let verdict {
                LocalizedWeatherBackground(condition: weatherCondition, verdict: verdict)
                    .clipShape(shape)
                    .transition(.opacity)
            } else {
                VaraTopoBackground()
                    .clipShape(shape)
                    .opacity(0.72)
            }

            shape.fill(.ultraThinMaterial)

            if let weatherCondition {
                WeatherEffectLayer(condition: weatherCondition, scrollOffset: 0)
                    .opacity(0.42)
                    .clipShape(shape)
                    .allowsHitTesting(false)
            }
        }
        .clipShape(shape)
        .animation(.easeInOut(duration: 0.45), value: weatherCondition)
    }

    private func expandedSectionTitle(_ title: String, topSafe: CGFloat) -> some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.top, topSafe + 10)
        .padding(.bottom, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func homeSectionTab(for section: HomeSection, isBottomCollapsed: Bool) -> some View {
        Button {
            setActiveHomeSection(section)
        } label: {
            switch section {
            case .readiness:
                ReadinessCollapsedHeader(day: rightNowDay)
            case .forecast:
                ForecastCollapsedHeader(day: selectedDay, isToday: isViewingToday)
            case .nearby:
                NearbyCollapsedHeader(spots: MockData.nearbySpots)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 52)
        .opacity(isBottomCollapsed ? 0.9 : 1)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(isBottomCollapsed ? 0.06 : 0.10), radius: 7, x: 0, y: 3)
        }
        .padding(.horizontal, 16)
    }

    // MARK: 10-day forecast

    // MARK: 10-day forecast rows (header lives in LazyVStack as a pinned section header)

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
                    guard !isHomeSectionTransitioning && !isHomeDragActive else { return }
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
                    guard !isHomeSectionTransitioning && !isHomeDragActive else { return }
                    selectedSpot = spot
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 2)
    }

}

// MARK: - Preview

#Preview {
    ContentView()
}
