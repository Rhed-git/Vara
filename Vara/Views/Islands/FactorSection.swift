import SwiftUI

struct FactorSection: View {
    let type: FactorType
    let detail: FactorDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundStyle(detail.verdict.color)
                    .frame(width: 24)
                Text(type.title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(detail.verdict.color)
                        .frame(width: 7, height: 7)
                    Text(detail.verdict.rawValue)
                        .font(.caption.weight(.semibold))
                        .tracking(0.5)
                        .foregroundStyle(detail.verdict.color)
                }
            }

            Text(detail.summary)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                ForEach(Array(detail.metrics.enumerated()), id: \.element.id) { index, metric in
                    HStack(spacing: 12) {
                        Image(systemName: metric.icon)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(width: 22)
                        Text(metric.label)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(metric.value)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                    }
                    .padding(.vertical, 10)
                    if index < detail.metrics.count - 1 {
                        Rectangle()
                            .fill(.white.opacity(0.14))
                            .frame(height: 0.5)
                    }
                }
            }
        }
    }
}
