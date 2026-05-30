import SwiftUI

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
    let recommendation: ReadinessRecommendation
    let location: String
    let activity: Activity
    let conditionsTitle: String
    let conditionsSubtitle: String
    let progress: CGFloat
    let topInset: CGFloat
    let insightLimit: Int
    let onConditionsTap: () -> Void

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
        VStack(spacing: lerp(6, 4)) {
            decisionBlock
            if !isCondensed {
                bestWindowBlock
                    .opacity(fadeOut(by: 0.5))
                    .transition(.opacity)

                reasonsBlock
                    .opacity(fadeOut(by: 0.5))
                    .transition(.opacity)

                Spacer(minLength: 0)

                conditionsBlock
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, topInset + lerp(4, 3))
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
        VStack(spacing: lerp(5, 3)) {
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
                    .fill(recommendation.verdict.color)
                    .frame(width: lerp(0, 8), height: lerp(0, 8))
                    .opacity(fadeIn(from: 0.35))

                Text(recommendation.verdict.rawValue)
                    .font(.system(size: lerp(52, 15), weight: .bold))
                    .tracking(recommendation.verdict == .noGo ? -2 : 0)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                if isCondensed {
                    Text(recommendation.headline)
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
                Text(recommendation.confidence.rawValue.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(recommendation.verdict.color.opacity(0.92), in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.28), lineWidth: 0.5))
            }
        }
    }

    // MARK: Best Window

    private var bestWindowBlock: some View {
        ActivityWindowRow(
            window: recommendation.bestWindow,
            verdict: recommendation.verdict,
            statusText: "\(recommendation.verdict.rawValue) during this window"
        )
    }

    // MARK: Reasons

    private var reasonsBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Why This Recommendation".uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.78))

            VStack(spacing: 4) {
                ForEach(recommendation.reasons.prefix(max(1, min(insightLimit, 3)))) { reason in
                    RecommendationReasonRow(reason: reason)
                }
            }
        }
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
            .padding(.horizontal, isCondensed ? 0 : 2)
            .padding(.vertical, lerp(5, 3))
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

private struct ActivityWindowRow: View {
    let window: ActivityWindow
    let verdict: Verdict?
    let statusText: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "clock.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(window.label)
                    .font(.caption.weight(.semibold))
                    .tracking(0.9)
                    .foregroundStyle(.white.opacity(0.72))
                Text(window.timeRange)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                if let verdict {
                    Text(statusText)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(verdict.color)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
    }
}

private struct RecommendationReasonRow: View {
    let reason: RecommendationReason

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: reason.icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 16, height: 16)
            Text(reason.title)
                .font(.caption)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.86)
            Spacer()
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
    }
}
