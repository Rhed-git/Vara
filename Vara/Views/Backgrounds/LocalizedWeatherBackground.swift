import SwiftUI

// MARK: - Localized Weather Background

struct LocalizedWeatherBackground: View {
    let condition: WeatherCondition
    let verdict: Verdict

    var body: some View {
        ZStack {
            weatherBackgroundGradient(condition: condition, verdict: verdict)
            WeatherAtmosphericOverlay(condition: condition)
            LinearGradient(
                colors: [.black.opacity(0.06), .black.opacity(0.24)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .allowsHitTesting(false)
    }

    private func weatherBackgroundGradient(condition: WeatherCondition, verdict: Verdict) -> LinearGradient {
        let pair = backgroundColors(condition: condition, verdict: verdict)
        return LinearGradient(
            colors: [pair.top, pair.bottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func backgroundColors(condition: WeatherCondition, verdict: Verdict) -> (top: Color, bottom: Color) {
        switch (verdict, condition) {
        case (_, .snow):
            return (Color(red: 0.48, green: 0.55, blue: 0.62),
                    Color(red: 0.65, green: 0.70, blue: 0.75))
        case (.go, .clear):
            return (Color(red: 0.27, green: 0.49, blue: 0.38),
                    Color(red: 0.42, green: 0.61, blue: 0.50))
        case (.go, .partlyCloudy):
            return (Color(red: 0.32, green: 0.47, blue: 0.42),
                    Color(red: 0.48, green: 0.60, blue: 0.53))
        case (.go, .cloudy), (.go, .overcast), (.go, .rain), (.go, .storm):
            return (Color(red: 0.36, green: 0.45, blue: 0.43),
                    Color(red: 0.50, green: 0.58, blue: 0.55))
        case (.caution, .clear):
            return (Color(red: 0.62, green: 0.45, blue: 0.22),
                    Color(red: 0.78, green: 0.58, blue: 0.32))
        case (.caution, .partlyCloudy), (.caution, .cloudy), (.caution, .overcast):
            return (Color(red: 0.48, green: 0.40, blue: 0.28),
                    Color(red: 0.62, green: 0.52, blue: 0.40))
        case (.caution, .rain), (.caution, .storm):
            return (Color(red: 0.38, green: 0.35, blue: 0.32),
                    Color(red: 0.55, green: 0.48, blue: 0.42))
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
}

private struct WeatherAtmosphericOverlay: View {
    let condition: WeatherCondition

    var body: some View {
        ZStack {
            primarySkyHighlight
            cloudLayer
            precipitationDarkening
        }
    }

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
        switch condition {
        case .clear:        return (0.72, 0.04, 0.55, 340)
        case .partlyCloudy: return (0.68, 0.06, 0.42, 360)
        case .cloudy:       return (0.50, 0.10, 0.24, 480)
        case .overcast:     return (0.50, 0.15, 0.14, 540)
        case .rain:         return (0.50, 0.08, 0.10, 380)
        case .storm:        return (0.50, 0.05, 0.07, 320)
        case .snow:         return (0.50, 0.08, 0.50, 600)
        }
    }

    @ViewBuilder
    private var cloudLayer: some View {
        switch condition {
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

    @ViewBuilder
    private var precipitationDarkening: some View {
        switch condition {
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
}
