import SwiftUI

// MARK: - Page Helpers
//
// Shared building blocks so each page reads the same way on top of the gradient
// background: a large header, a translucent "glass card" grouping rows, and small
// section labels. Rows are styled white-on-glass to match the home page.

struct PageHeader: View {
    let title: String
    let subtitle: String?

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(.white)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 64)
        .padding(.bottom, 12)
    }
}

struct PageSectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.5)
            .foregroundStyle(.white.opacity(0.62))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, -4)
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
    }
}

struct GlassRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.14))
            .frame(height: 0.5)
            .padding(.leading, 56)
    }
}

struct PageScaffold<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                content()
            }
            .padding(.bottom, 120)  // breathing room above the floating menu pill
        }
        .scrollIndicators(.hidden)
    }
}
