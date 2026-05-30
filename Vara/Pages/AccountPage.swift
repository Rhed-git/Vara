import SwiftUI

// MARK: - Account Page

struct AccountPage: View {
    @State private var notificationsEnabled: Bool = true
    @State private var lowLightAlerts: Bool = true
    @State private var weeklySummary: Bool = false

    var body: some View {
        PageScaffold {
            PageHeader(title: "Account")

            GlassCard {
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Jake Jones")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("jake@vara.app")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    Spacer()
                }
                .padding(16)
            }

            PageSectionHeader(title: "Account")
            GlassCard {
                AccountLinkRow(title: "Account Details", icon: "person.text.rectangle")
                GlassRowDivider()
                AccountLinkRow(title: "Subscription", icon: "creditcard")
                GlassRowDivider()
                AccountLinkRow(title: "Connected Apps", icon: "link")
            }

            PageSectionHeader(title: "Notifications")
            GlassCard {
                AccountToggleRow(title: "Push Notifications", icon: "bell.fill", isOn: $notificationsEnabled)
                GlassRowDivider()
                AccountToggleRow(title: "Low-Light Warnings", icon: "sun.horizon.fill", isOn: $lowLightAlerts)
                GlassRowDivider()
                AccountToggleRow(title: "Weekly Summary", icon: "calendar", isOn: $weeklySummary)
            }

            PageSectionHeader(title: "App")
            GlassCard {
                AccountLinkRow(title: "About", icon: "info.circle")
                GlassRowDivider()
                AccountLinkRow(title: "Privacy", icon: "hand.raised.fill")
                GlassRowDivider()
                AccountLinkRow(title: "Help & Support", icon: "questionmark.circle")
            }

            Button(role: .destructive) {} label: {
                Text("Sign Out")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.62, blue: 0.62))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Text("Vara 1.0.0 (mock)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
    }
}

private struct AccountLinkRow: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 28)
            Text(title)
                .font(.body)
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

private struct AccountToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(width: 28)
                Text(title)
                    .font(.body)
                    .foregroundStyle(.white)
            }
        }
        .tint(.white.opacity(0.85))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
