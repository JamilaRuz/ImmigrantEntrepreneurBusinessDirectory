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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("About Us")
                    .font(.headline)
                    .padding(.top, 15)
                
                ScrollView {
                    Text(company.aboutUs)
                        .font(.body)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading entrepreneur info...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else if let error = viewModel.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                } else {
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
    @Published var isLoading = false
    @Published var error: String?
    
    @MainActor
    func loadEntrepreneur(entrepId: String) async {
        isLoading = true
        error = nil
        
        do {
            self.entrepreneur = try await EntrepreneurManager.shared.getEntrepreneur(entrepId: entrepId)
        } catch {
            print("Failed to load entrepreneur: \(error)")
            self.error = "Failed to load entrepreneur information. Please try again later."
        }
        
        isLoading = false
    }
}


#Preview {
    InfoView(company: createStubCompanies()[0])
}
