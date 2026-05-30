import SwiftUI

// MARK: - Stable App Background

struct VaraTopoBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.035, green: 0.050, blue: 0.046),
                    Color(red: 0.060, green: 0.083, blue: 0.074),
                    Color(red: 0.020, green: 0.024, blue: 0.026)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            TopographicLinePattern()
                .foregroundStyle(.white.opacity(0.07))
                .blendMode(.screen)

            LinearGradient(
                colors: [
                    .black.opacity(0.28),
                    .clear,
                    .black.opacity(0.36)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

private struct TopographicLinePattern: View {
    var body: some View {
        Canvas { context, size in
            let stroke = StrokeStyle(lineWidth: 0.8, lineCap: .round, lineJoin: .round)
            let horizontalStep: CGFloat = 118
            let verticalStep: CGFloat = 96

            for column in stride(from: -horizontalStep, through: size.width + horizontalStep, by: horizontalStep) {
                for row in stride(from: -verticalStep, through: size.height + verticalStep, by: verticalStep) {
                    let phase = ((column / horizontalStep) + (row / verticalStep)).truncatingRemainder(dividingBy: 3)
                    let width = horizontalStep * (0.70 + phase * 0.10)
                    let height = verticalStep * (0.56 + phase * 0.08)

                    for ring in 0..<4 {
                        let inset = CGFloat(ring) * 13
                        let rect = CGRect(
                            x: column - width / 2 + inset,
                            y: row - height / 2 + inset,
                            width: max(18, width - inset * 2),
                            height: max(14, height - inset * 2)
                        )
                        context.stroke(Path(ellipseIn: rect), with: .color(.white.opacity(0.07)), style: stroke)
                    }
                }
            }

            for y in stride(from: CGFloat(-40), through: size.height + 80, by: 140) {
                var path = Path()
                path.move(to: CGPoint(x: -20, y: y))
                path.addCurve(
                    to: CGPoint(x: size.width + 20, y: y + 24),
                    control1: CGPoint(x: size.width * 0.25, y: y - 38),
                    control2: CGPoint(x: size.width * 0.72, y: y + 72)
                )
                context.stroke(path, with: .color(.white.opacity(0.06)), style: stroke)
            }
        }
    }
}
