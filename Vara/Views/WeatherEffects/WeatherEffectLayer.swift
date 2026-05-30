import SwiftUI

// MARK: - Weather Effect Layer

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
