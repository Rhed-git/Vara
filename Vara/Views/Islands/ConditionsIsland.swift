import SwiftUI

// MARK: - Conditions Island

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
