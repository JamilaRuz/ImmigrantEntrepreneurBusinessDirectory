//
//  InfoView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import SwiftUI

struct InfoView: View {
    let company: Company
    @StateObject private var viewModel = InfoViewModel()
    
    let backgroundColors: [Color] = [.pink1, .purple1, .blue1, .green1, .orange1, .yellow]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text("About Us")
                    .font(.headline)
                ScrollView {
                    Text(company.aboutUs)
                        .font(.body)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(minWidth: UIScreen.main.bounds.width - 20, minHeight: 150)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    AsyncImage(url: URL(string: viewModel.entrepreneur.profileUrl ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading) {
                        Text("Founder")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(viewModel.entrepreneur.fullName ?? "Unknown")
                            .font(.body)
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            Task {
                await viewModel.loadEntrepreneur(entrepId: company.entrepId)
            }
        }
    }
}

class InfoViewModel: ObservableObject {
    @Published var entrepreneur: Entrepreneur = Entrepreneur(entrepId: "", fullName: "", profileUrl: nil, email: "", bioDescr: "", companyIds: [])
    
    func loadEntrepreneur(entrepId: String) async {
        do {
            self.entrepreneur = try await EntrepreneurManager.shared.getEntrepreneur(entrepId: entrepId)
        } catch {
            print("Failed to load entrepreneur: \(error)")
            // Handle error appropriately, maybe set a default entrepreneur or show an error message
        }
    }
}


#Preview {
    InfoView(company: createStubCompanies()[0])
}
