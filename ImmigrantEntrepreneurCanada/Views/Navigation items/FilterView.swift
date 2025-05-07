import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = FilterViewModel()
    
    // Grid layout with 2 columns of flexible width
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    FilterContentView(viewModel: viewModel)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .blue)
                }
            }
        }
        .background(colorScheme == .dark ? Color.black : Color(.systemGray6))
        .preferredColorScheme(colorScheme)
    }
}

// MARK: - Loading View
private struct LoadingView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            ProgressView()
            Text("Loading filters...")
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black : Color(.systemGray6))
    }
}

// MARK: - Filter Content View
private struct FilterContentView: View {
    @ObservedObject var viewModel: FilterViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Helper function to identify if a city is amalgamated
    private func isAmalgamatedCity(_ city: String) -> Bool {
        viewModel.isAmalgamatedCity(city)
    }
    
    // Helper to get parent city if it's an amalgamated city
    private func parentCityFor(_ city: String) -> String? {
        viewModel.parentCityFor(city)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Business Location Section
                FilterSection(
                    title: "Filter by Business Location",
                    items: viewModel.cities,
                    selectedItems: viewModel.selectedCities,
                    itemTitle: { $0 },
                    onToggle: viewModel.toggleCity,
                    itemSubtitle: { city in
                        if let parentCity = parentCityFor(city) {
                            return "Part of \(parentCity)"
                        }
                        return nil
                    }
                )
                
                // Entrepreneur's Country of Origin Section
                if !viewModel.countries.isEmpty {
                    FilterSection(
                        title: "Filter by Founder's Country of Origin",
                        items: viewModel.countries,
                        selectedItems: viewModel.selectedCountries,
                        itemTitle: { $0 },
                        onToggle: viewModel.toggleCountry
                    )
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Filter by Founder's Country of Origin")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text("No countries available yet. Countries will appear here when entrepreneurs add their country of origin.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(colorScheme == .dark ? Color.black : Color(.systemGray6))
    }
}

// MARK: - Filter Section
private struct FilterSection<T: Hashable>: View {
    let title: String
    let items: [T]
    let selectedItems: Set<T>
    let itemTitle: (T) -> String
    let onToggle: (T) -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    // Optional function to provide subtitles for items
    var itemSubtitle: ((T) -> String?)? = nil
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items, id: \.self) { item in
                    CheckboxButton(
                        title: itemTitle(item),
                        isChecked: selectedItems.contains(item),
                        action: {
                            onToggle(item)
                        },
                        subtitle: itemSubtitle?(item)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Checkbox Button
struct CheckboxButton: View {
    let title: String
    let isChecked: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    // Optional subtitle for amalgamated cities
    var subtitle: String? = nil
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(colorScheme == .dark ? Color.gray.opacity(0.6) : Color.gray, lineWidth: 1)
                        .frame(width: 20, height: 20)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("pink1"))
                    }
                }
                
                VStack(alignment: .leading, spacing: subtitle != nil ? 2 : 0) {
                    Text(title)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .font(.system(size: 14))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .foregroundColor(.gray)
                            .font(.system(size: 10))
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
        }
    }
}


#Preview {
    FilterView()
}
