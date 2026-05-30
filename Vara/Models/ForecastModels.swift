import Foundation

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
