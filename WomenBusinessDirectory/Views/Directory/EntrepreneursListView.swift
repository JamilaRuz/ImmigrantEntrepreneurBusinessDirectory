import SwiftUI
import FirebaseFirestore

@MainActor
final class EntrepreneursListViewModel: ObservableObject {
    @Published private(set) var entrepreneurs: [Entrepreneur] = []
    @Published var searchTerm = ""
    @Published var isLoading = true
    @Published var error: String?
    
    var filteredEntrepreneurs: [Entrepreneur] {
        if searchTerm.isEmpty {
            return entrepreneurs
        }
        return entrepreneurs.filter { entrepreneur in
            let name = entrepreneur.fullName?.lowercased() ?? ""
            let bio = entrepreneur.bioDescr?.lowercased() ?? ""
            let searchLower = searchTerm.lowercased()
            
            return name.contains(searchLower) || bio.contains(searchLower)
        }
    }
    
    func loadEntrepreneurs() {
        Task {
            do {
                isLoading = true
                error = nil
                
                self.entrepreneurs = try await EntrepreneurManager.shared.getAllEntrepreneurs()
                
                isLoading = false
            } catch {
                self.error = "Failed to load entrepreneurs: \(error.localizedDescription)"
                isLoading = false
                print("Error loading entrepreneurs: \(error)")
            }
        }
    }
}

struct EntrepreneursListView: View {
    @StateObject private var viewModel = EntrepreneursListViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $viewModel.searchTerm)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredEntrepreneurs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        if viewModel.searchTerm.isEmpty {
                            Text("No entrepreneurs found")
                        } else {
                            Text("No entrepreneurs match your search")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.filteredEntrepreneurs, id: \.entrepId) { entrepreneur in
                        NavigationLink(destination: ProfileView(showSignInView: .constant(false), isEditable: false, entrepreneur: entrepreneur)) {
                            EntrepreneurRowView(entrepreneur: entrepreneur)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Entrepreneurs")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            viewModel.loadEntrepreneurs()
        }
    }
}

struct EntrepreneurRowView: View {
    let entrepreneur: Entrepreneur
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let profileUrlString = entrepreneur.profileUrl,
               let profileUrl = URL(string: profileUrlString) {
                AsyncImage(url: profileUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entrepreneur.fullName ?? "Entrepreneur")
                    .font(.headline)
                
                if !entrepreneur.companyIds.isEmpty {
                    Text("\(entrepreneur.companyIds.count) \(entrepreneur.companyIds.count == 1 ? "Company" : "Companies")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EntrepreneursListView()
} 