import SwiftUI

// MARK: - Bottom Menu Pill

// MARK: - Bottom Menu Pill
//
// A single glass capsule that houses all four top-level menus. The tapped segment
// expands to reveal its title; the highlight slides between segments via
// `matchedGeometryEffect`. `.ultraThinMaterial` renders poorly in the simulator —
// test on device for the real frosted-glass effect.

struct BottomMenuPill: View {
    let selectedActivity: Activity
    @Binding var selectedItem: MenuItem

    @Namespace private var pillAnimation

    var body: some View {
        HStack(spacing: 2) {
            ForEach(MenuItem.allCases) { item in
                Button {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                        selectedItem = item
                    }
                } label: {
                    segment(for: item)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
            }
        }
        .padding(5)
        .background {
            Capsule().fill(.ultraThinMaterial)
        }
        .overlay(Capsule().stroke(.white.opacity(0.28), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 5)
    }

    @ViewBuilder
    private func segment(for item: MenuItem) -> some View {
        let isSelected = selectedItem == item
        HStack(spacing: 6) {
            Image(systemName: iconName(for: item))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.28), radius: 2, x: 0, y: 1)
                .frame(width: 20, height: 20)
                .contentTransition(.symbolEffect(.replace))

            if isSelected {
                Text(item.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .fixedSize()
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .padding(.horizontal, isSelected ? 11 : 8)
        .padding(.vertical, 9)
        .background {
            if isSelected {
                Capsule()
                    .fill(.white.opacity(0.22))
                    .overlay(Capsule().stroke(.white.opacity(0.32), lineWidth: 0.5))
                    .matchedGeometryEffect(id: "pillSelection", in: pillAnimation)
            }
        }
    }

    private func iconName(for item: MenuItem) -> String {
        switch item {
        case .activity: return selectedActivity.icon
        default: return item.icon
        }
    }
}
