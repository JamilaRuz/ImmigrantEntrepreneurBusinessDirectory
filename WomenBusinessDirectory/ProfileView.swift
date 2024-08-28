//
//  ProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/24/24.
//

import SwiftUI
import FirebaseFirestoreSwift

@MainActor
final class ProfileViewModel: ObservableObject {
  
  @Published private(set) var entrepreneur: Entrepreneur? = nil
  @Published private(set) var companies: [Company] = []
  
  func loadCurrentEntrepreneur() async throws {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    self.entrepreneur = try await EntrepreneurManager.shared.getEntrepreneur(entrepId: authDataResult.uid)
  }
  
  func loadCompaniesOfEntrepreneur() async throws {
    self.companies = try await entrepreneur?.companyIds.asyncMap { companyId in
      print("Loading company with id: \(companyId)")
      return try await RealCompanyManager.shared.getCompany(companyId: companyId)
    } ?? []
  }
}
  
struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()
  @State var image: Image? = nil
  @Binding var showSignInView: Bool
  
  var body: some View {
    NavigationStack {
      if var entrepreneur = viewModel.entrepreneur {
        VStack {
          VStack(alignment: .center) {
            if let image = image {
              image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 150, height: 150)
            } else {
              Circle()
                .frame(width: 150, height: 150)
                .foregroundColor(.green1)
                .background(Circle().strokeBorder(Color.green4, lineWidth: 2))
            }
            
            Text(entrepreneur.fullName ?? "Sans nom")
              .font(.title)
            
            TextField("Please enter your bio", text:
                        Binding(
                          get: { entrepreneur.bioDescr ?? "" },
                          set: { entrepreneur.bioDescr = $0 }
                        )
            )
            .padding()
            .frame(width: UIScreen.main.bounds.width - 40, height: 70)
            .border(Color.green4, width: 1)
            .cornerRadius(10)
            .onSubmit() {
              print("Save data to Firestore")
            }
            
            if viewModel.companies.isEmpty {
              Text("No companies to show")
                .padding()
                .foregroundColor(.gray)
                .font(.subheadline)
            } else {
              List() {
                ForEach(viewModel.companies, id: \.self) { company in
                  NavigationLink(destination: CompanyDetailView(company: company)) {
                    HStack(spacing: 10) {
                      Image("logos/comp_logo5")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 120)
                        .clipped()
                      VStack(alignment: .leading, spacing: 5) {
                        Text(company.name)
                          .font(.headline)
                        Text(company.aboutUs)
                          .font(.body)
                          .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Text(company.address)
                          .font(.subheadline)
                          .foregroundColor(.gray)
                      }
                      .frame(maxHeight: .infinity, alignment: .top)
                    }
                  }
                }
              }
              .listStyle(.grouped)
            }
        } //VStack top
        .padding()
        
        Spacer()
          
        // Add company button
        VStack(alignment: .trailing) {
          NavigationLink(destination: AddCompanyView(viewModel: AddCompanyViewModel(), entrepreneur: entrepreneur)) {
            Text("")
              .frame(width: 50, height: 50)
              .background(Circle().fill(Color.green4))
              .overlay(
                Image(systemName: "plus")
                  .foregroundColor(.white)
                  .font(.system(size: 24))
              )
          } //NavigationLink
        } //VStack bottom
        .padding()
      } //VStack main
    }
    else {
      Text("Please sign in to add a company")
        .padding()
        .foregroundColor(.gray)
        .font(.subheadline)
    } //if let entrepreneur
    
  }//NavigationStack
    .navigationTitle("Profile View")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        NavigationLink {
          SettingsView(showSignInView: $showSignInView)
        } label: {
          Image(systemName: "gear") // gearshape.fill
            .font(.headline)
        }
      }
    } // toolbar
    .task {
      do {
        try await viewModel.loadCurrentEntrepreneur()
        try await viewModel.loadCompaniesOfEntrepreneur()
      } catch {
        print("Failed to load entrepreneur data: \(error)")
      }
    }
}
}

#Preview {
  NavigationStack {
    ProfileView(showSignInView: .constant(false))
  }
}
