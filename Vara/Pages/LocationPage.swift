import SwiftUI

// MARK: - Location Page

struct LocationPage: View {
    @Binding var location: String

    let favoritesStore: FavoritesStore
    let onSpotTap: (TrailSpot) -> Void

    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var suggestedSpots: ArraySlice<TrailSpot> {
        MockData.searchableSpots.prefix(6)
    }

    private var searchResults: [TrailSpot] {
        guard !trimmedSearchText.isEmpty else { return [] }

        return MockData.searchableSpots.filter { spot in
            spot.name.localizedCaseInsensitiveContains(trimmedSearchText) ||
            spot.kind.label.localizedCaseInsensitiveContains(trimmedSearchText) ||
            spot.detail.localizedCaseInsensitiveContains(trimmedSearchText)
        }
    }

    var body: some View {
        PageScaffold {
            PageHeader(title: "Location", subtitle: "Find trails, parks, and riding areas")

            searchField

            currentLocationAction

            if trimmedSearchText.isEmpty {
                PageSectionHeader(title: "Suggested places")
                spotCards(suggestedSpots)
            } else if searchResults.isEmpty {
                noResultsState
            } else {
                PageSectionHeader(title: "Results")
                spotCards(searchResults)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .onTapGesture {
            isSearchFocused = false
        }
        .sensoryFeedback(.selection, trigger: location)
        .sensoryFeedback(.selection, trigger: favoritesStore.spots.count)
    }

    private func spotCards<S: RandomAccessCollection>(_ spots: S) -> some View where S.Element == TrailSpot {
        VStack(spacing: 10) {
            ForEach(Array(spots)) { spot in
                LocationResultCard(
                    spot: spot,
                    isSaved: favoritesStore.isSaved(spot),
                    onTap: {
                        openSpot(spot)
                    },
                    onSave: {
                        saveSpot(spot)
                    }
                )
            }
        }
        .padding(.horizontal, 20)
    }

    private func openSpot(_ spot: TrailSpot) {
        isSearchFocused = false
        location = spot.name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            onSpotTap(spot)
        }
    }

    private func saveSpot(_ spot: TrailSpot) {
        isSearchFocused = false
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            favoritesStore.save(spot)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search trail, park, or riding area")
                    .foregroundColor(.white.opacity(0.55))
            )
            .foregroundStyle(.white)
            .tint(.white)
            .textInputAutocapitalization(.words)
            .submitLabel(.search)
            .focused($isSearchFocused)
            .onSubmit {
                isSearchFocused = false
            }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    isSearchFocused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(isSearchFocused ? 0.34 : 0.2), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 6)
        .padding(.horizontal, 20)
    }

    private var currentLocationAction: some View {
        Button {
            isSearchFocused = false
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                location = "Current Location"
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "location.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.62, green: 0.88, blue: 1.0))

                Text("Use Current Location")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.62, green: 0.88, blue: 1.0))

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.46))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 0.5)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
        .padding(.horizontal, 20)
    }

    private var noResultsState: some View {
        LocationMessageCard(
            icon: "exclamationmark.magnifyingglass",
            title: "No matching locations found."
        )
    }
}

private struct LocationResultCard: View {
    let spot: TrailSpot
    let isSaved: Bool
    let onTap: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: spot.kind.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white.opacity(0.84))
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(spot.kind.label)
                        .font(.caption2.weight(.semibold))
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.66))

                    VerdictPill(verdict: spot.verdict, emphasized: false)
                }

                Text(spot.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(spot.detail)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Button {
                if !isSaved {
                    onSave()
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "star.fill")
                        .font(.caption.weight(.semibold))
                    Text(isSaved ? "Saved" : "Save")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(.white.opacity(isSaved ? 0.14 : 0.22), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.22), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .disabled(isSaved)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .accessibilityLabel("\(spot.name), \(spot.kind.label.lowercased()), \(spot.detail)")
    }
}

private struct LocationMessageCard: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.74))

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        VaraTopoBackground()
            .ignoresSafeArea()

        LocationPage(
            location: .constant("Boulder, CO"),
            favoritesStore: FavoritesStore()
        ) { _ in }
    }
}
