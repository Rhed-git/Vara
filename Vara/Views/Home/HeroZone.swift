import SwiftUI

// MARK: - Hero Zone

// MARK: - Hero Zone
//
// Readiness content for the home page: verdict → insights (what to expect /
// down-time prep) → current conditions row. The section model now drives
// `progress` as a discrete expanded/collapsed value instead of binding it to
// raw scroll offset.
//
// A single layout interpolates sizes/paddings/opacities continuously, then
// drops the expanded-only rows once past `isCondensed` so the collapsed height
// remains realistic.

struct HeroZone: View {
    let day: DayForecast
    let location: String
    let activity: Activity
    let conditionsTitle: String
    let conditionsSubtitle: String
    let progress: CGFloat
    let topInset: CGFloat
    let insightLimit: Int
    let onConditionsTap: () -> Void

    private var insightsTitle: String {
        switch day.verdict {
        case .go, .caution: return "What to Expect"
        case .noGo:         return "Down Time Prep"
        }
    }

    /// True once we're far enough into the collapse that only the compact
    /// verdict/headline bar should remain.
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
        VStack(spacing: lerp(8, 6)) {
            decisionBlock
            if !isCondensed {
                insightsBlock
                    .opacity(fadeOut(by: 0.5))
                    .transition(.opacity)
                conditionsBlock
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, topInset + lerp(6, 4))
        .padding(.bottom, 8)
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
        VStack(spacing: lerp(8, 4)) {
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
                    .font(.system(size: lerp(56, 15), weight: .bold))
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
                .frame(maxHeight: lerp(48, 0), alignment: .top)
                .clipped()
        }
    }

    // MARK: Insights

    private var insightsBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(insightsTitle.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.78))

            VStack(spacing: 5) {
                ForEach(day.insights.prefix(max(1, insightLimit))) { insight in
                    InsightRow(item: insight)
                }
            }
        }
        .padding(.top, 2)
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
            .padding(.vertical, lerp(10, 4))
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
