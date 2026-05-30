import SwiftUI

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
