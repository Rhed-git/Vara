import SwiftUI

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
