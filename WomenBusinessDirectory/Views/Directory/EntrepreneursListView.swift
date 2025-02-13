import SwiftUI
import FirebaseFirestore

@MainActor
final class EntrepreneursListViewModel: ObservableObject {
    @Published private(set) var entrepreneurs: [Entrepreneur] = []
    @Published private(set) var entrepreneurCompanies: [String: [Company]] = [:]
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
            let companies = entrepreneurCompanies[entrepreneur.entrepId]?.map { $0.name.lowercased() } ?? []
            let searchLower = searchTerm.lowercased()
            
            return name.contains(searchLower) || 
                   bio.contains(searchLower) ||
                   companies.contains { $0.contains(searchLower) }
        }
    }
    
    func loadEntrepreneurs() {
        Task {
            do {
                isLoading = true
                error = nil
                
                self.entrepreneurs = try await EntrepreneurManager.shared.getAllEntrepreneurs()
                
                // Load companies for each entrepreneur
                for entrepreneur in entrepreneurs {
                    let companies = try await entrepreneur.companyIds.asyncMap { companyId in
                        try await RealCompanyManager.shared.getCompany(companyId: companyId)
                    }
                    entrepreneurCompanies[entrepreneur.entrepId] = companies
                }
                
                isLoading = false
            } catch {
                self.error = "Failed to load entrepreneurs: \(error.localizedDescription)"
                isLoading = false
                print("Error loading entrepreneurs: \(error)")
            }
        }
    }
    
    func getCompanies(for entrepreneur: Entrepreneur) -> [Company] {
        return entrepreneurCompanies[entrepreneur.entrepId] ?? []
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
                            .foregroundColor(Color.orange1)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredEntrepreneurs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 70))
                            .foregroundColor(Color.orange1)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.orange1.opacity(0.1))
                                    .frame(width: 120, height: 120)
                            )
                        if viewModel.searchTerm.isEmpty {
                            Text("No entrepreneurs found")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.orange1)
                        } else {
                            Text("No entrepreneurs match your search")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.orange1)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange1.opacity(0.1),
                                Color.white
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                } else {
                    List(viewModel.filteredEntrepreneurs, id: \.entrepId) { entrepreneur in
                        NavigationLink(destination: ProfileView(showSignInView: .constant(false), isEditable: false, entrepreneur: entrepreneur)) {
                            EntrepreneurRowView(entrepreneur: entrepreneur, viewModel: viewModel)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Entrepreneurs")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Color.orange1)
        .task {
            viewModel.loadEntrepreneurs()
        }
    }
}

struct EntrepreneurRowView: View {
    let entrepreneur: Entrepreneur
    @ObservedObject var viewModel: EntrepreneursListViewModel
    
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
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange1, lineWidth: 2)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange1, lineWidth: 2)
                            )
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange1, lineWidth: 2)
                            )
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
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange1, lineWidth: 2)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Name and email
                VStack(alignment: .leading, spacing: 2) {
                    Text(entrepreneur.fullName ?? "Entrepreneur")
                        .font(.headline)
                        .foregroundColor(Color.orange1)
                    
                    if let email = entrepreneur.email {
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Bio preview if available
                if let bio = entrepreneur.bioDescr, !bio.isEmpty {
                    Text(bio)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Company names
                let companies = viewModel.getCompanies(for: entrepreneur)
                if !companies.isEmpty {
                    HStack(spacing: 4) {
                        Text("Companies:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(companies.map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(Color.orange1)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    EntrepreneursListView()
} 