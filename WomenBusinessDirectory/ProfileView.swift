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
  
  func loadCurrentEntrepreneur() async throws {
    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
    self.entrepreneur = try await EntrepreneurManager.shared.getEntrepreneur(entrepId: authDataResult.uid)
  }
}


struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()
  
  @State var image: Image? = nil
  @State private var isSheetPresented = false
  @Binding var showSignInView: Bool
  
  var body: some View {
    VStack {
      VStack(alignment: .center) {
        
        if var entrepreneur = viewModel.entrepreneur {
          if let image = image {
            image
              .resizable()
              .scaledToFill()
              .clipShape(Circle())
              .frame(width: 150, height: 150)
              .padding(.top)
          } else {
            Circle()
              .frame(width: 150, height: 150)
              .foregroundColor(.green1)
              .background(Circle().strokeBorder(Color.green4, lineWidth: 2))
              .padding(.top)
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
          .frame(width: UIScreen.main.bounds.width - 40, height: 100)
          .border(Color.green4, width: 2)
          .onSubmit() {
            print("Save data to Firestore")
          }
          
          
          //        let companies = entrepreneur.companies
          //        if companies.isEmpty {
          //          Text("No companies to show")
          //            .padding()
          //            .foregroundColor(.gray)
          //            .font(.subheadline)
          //        } else {
          //          List(companies, id: \.self) { company in
          //            Text(company.name)
          //          }
          //        }
          //      }

        } //if
      } //VStack 2
      .task {
        try? await viewModel.loadCurrentEntrepreneur()
      }
      Button("Add Company") {
        isSheetPresented.toggle()
      }
      .sheet(isPresented: $isSheetPresented) {
        AddCompanyView(entrepreneur: viewModel.entrepreneur!)
      }
      Spacer()
    }
    .padding()
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
  }
}

#Preview {
  NavigationStack {
    ProfileView(showSignInView: .constant(true))
  }
}
