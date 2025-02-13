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
                
                // Get all entrepreneurs from Firestore
                let snapshot = try await Firestore.firestore()
                    .collection("entrepreneurs")
                    .getDocuments()
                
                self.entrepreneurs = try snapshot.documents.compactMap { document in
                    try document.data(as: Entrepreneur.self)
                }
                
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
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple1.opacity(0.1),
                        Color.pink1.opacity(0.1),
                        Color.white.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
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
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredEntrepreneurs, id: \.entrepId) { entrepreneur in
                                    EntrepreneurCardView(entrepreneur: entrepreneur)
                                }
                            }
                            .padding()
                        }
                    }
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

struct EntrepreneurCardView: View {
    let entrepreneur: Entrepreneur
    
    var body: some View {
        NavigationLink(destination: ProfileView(showSignInView: .constant(false), isEditable: false, entrepreneur: entrepreneur)) {
            VStack(alignment: .leading, spacing: 12) {
                // Profile image and name
                HStack(spacing: 12) {
                    if let profileUrlString = entrepreneur.profileUrl,
                       let profileUrl = URL(string: profileUrlString) {
                        AsyncImage(url: profileUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 60, height: 60)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entrepreneur.fullName ?? "Entrepreneur")
                            .font(.headline)
                        
                        if let email = entrepreneur.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if let bio = entrepreneur.bioDescr, !bio.isEmpty {
                    Text(bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                if !entrepreneur.companyIds.isEmpty {
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.purple1)
                        Text("\(entrepreneur.companyIds.count) \(entrepreneur.companyIds.count == 1 ? "Company" : "Companies")")
                            .font(.caption)
                            .foregroundColor(.purple1)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    EntrepreneursListView()
} 