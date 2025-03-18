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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Location Section
                FilterSection(
                    title: "Location",
                    items: viewModel.cities,
                    selectedItems: viewModel.selectedCities,
                    itemTitle: { $0 },
                    onToggle: viewModel.toggleCity
                )
                
                // Ownership Type Section
                FilterSection(
                    title: "Ownership Type",
                    items: viewModel.ownershipTypes,
                    selectedItems: viewModel.selectedOwnershipTypes,
                    itemTitle: { $0.rawValue },
                    onToggle: viewModel.toggleOwnershipType
                )
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
                        isChecked: selectedItems.contains(item)
                    ) {
                        onToggle(item)
                    }
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
                
                Text(title)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .font(.system(size: 14))
                
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
