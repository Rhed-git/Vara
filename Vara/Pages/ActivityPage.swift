import SwiftUI

// MARK: - Activity Page

struct ActivityPage: View {
    @Binding var selectedActivity: Activity

    private var available: [Activity] { Activity.allCases.filter(\.isAvailable) }
    private var comingSoon: [Activity] { Activity.allCases.filter { !$0.isAvailable } }

    var body: some View {
        PageScaffold {
            PageHeader(title: "Activity", subtitle: "Currently: \(selectedActivity.rawValue)")

            GlassCard {
                ForEach(Array(available.enumerated()), id: \.element.id) { idx, activity in
                    ActivityRow(
                        activity: activity,
                        isSelected: activity == selectedActivity,
                        isDisabled: false
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedActivity = activity
                        }
                    }
                    if idx < available.count - 1 {
                        GlassRowDivider()
                    }
                }
            }

            if !comingSoon.isEmpty {
                PageSectionHeader(title: "Coming Soon")
                GlassCard {
                    ForEach(Array(comingSoon.enumerated()), id: \.element.id) { idx, activity in
                        ActivityRow(
                            activity: activity,
                            isSelected: false,
                            isDisabled: true
                        )
                        if idx < comingSoon.count - 1 {
                            GlassRowDivider()
                        }
                    }
                }
            }
        }
    }
}

struct ActivityRow: View {
    let activity: Activity
    let isSelected: Bool
    let isDisabled: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: activity.icon)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isDisabled ? Color.white.opacity(0.4) : .white)
                .frame(width: 28)

            Text(activity.rawValue)
                .font(.body)
                .foregroundStyle(isDisabled ? Color.white.opacity(0.45) : .white)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
