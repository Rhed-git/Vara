import SwiftUI

// MARK: - Location Page

struct LocationPage: View {
    @Binding var location: String
    @State private var searchText: String = ""

    private let recent = ["Boulder, CO", "Chautauqua Park", "Mt. Sanitas Trail", "Flagstaff Mountain"]
    private let popular = [
        "Rocky Mountain National Park",
        "Eldorado Canyon State Park",
        "Indian Peaks Wilderness",
        "Lost Lake Trail",
    ]

    private var filteredRecent: [String] {
        searchText.isEmpty ? recent : recent.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private var filteredPopular: [String] {
        searchText.isEmpty ? popular : popular.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        PageScaffold {
            PageHeader(title: "Location", subtitle: "Currently: \(location)")

            // Search field
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.7))
                TextField(
                    "",
                    text: $searchText,
                    prompt: Text("Search location, trail, or park")
                        .foregroundColor(.white.opacity(0.55))
                )
                .foregroundStyle(.white)
                .tint(.white)
                .textInputAutocapitalization(.words)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5))
            .padding(.horizontal, 20)

            GlassCard {
                LocationRow(
                    name: "Use Current Location",
                    icon: "location.fill",
                    isSelected: false,
                    accent: true
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        location = "Current Location"
                    }
                }
            }

            if !filteredRecent.isEmpty {
                PageSectionHeader(title: "Recent")
                GlassCard {
                    ForEach(Array(filteredRecent.enumerated()), id: \.element) { idx, name in
                        LocationRow(
                            name: name,
                            icon: "clock.arrow.circlepath",
                            isSelected: name == location,
                            accent: false
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                location = name
                            }
                        }
                        if idx < filteredRecent.count - 1 {
                            GlassRowDivider()
                        }
                    }
                }
            }

            if !filteredPopular.isEmpty {
                PageSectionHeader(title: "Trails & Parks")
                GlassCard {
                    ForEach(Array(filteredPopular.enumerated()), id: \.element) { idx, name in
                        LocationRow(
                            name: name,
                            icon: "mountain.2.fill",
                            isSelected: name == location,
                            accent: false
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                location = name
                            }
                        }
                        if idx < filteredPopular.count - 1 {
                            GlassRowDivider()
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: location)
    }
}

private struct LocationRow: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let accent: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(accent ? Color(red: 0.62, green: 0.88, blue: 1.0) : .white)
                .frame(width: 28)

            Text(name)
                .font(.body)
                .foregroundStyle(accent ? Color(red: 0.62, green: 0.88, blue: 1.0) : .white)

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
