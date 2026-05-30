import SwiftUI

struct InsightRow: View {
    let item: InsightItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.callout)
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
            Text(item.title)
                .font(.callout)
                .foregroundStyle(.white)
                .lineLimit(2)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
    }
}
