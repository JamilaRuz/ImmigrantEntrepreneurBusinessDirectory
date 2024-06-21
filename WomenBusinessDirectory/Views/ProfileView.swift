//
//  ProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/24/24.
//

import SwiftUI
import SwiftData
import FirebaseFirestoreSwift

@MainActor
final class ProfileViewModel: ObservableObject {
  @Published private(set) var user: AuthDataResultModel? = nil
  
  func loadCurrentUser() throws {
    self.user = try AuthenticationManager.shared.getAuthenticatedUser()
  }
}


struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()
  @State private var isSheetPresented = false
  @Binding var showSignInView: Bool
  
  var entrepreneur: Entrepreneur? {
//    viewModel.user
    nil
  }
  
  var bioDescr: String {
    entrepreneur?.bioDescr ?? ""
  }
  
//  var profileImage: String {
//    entrepreneur?.profileImage
//  }
  
  var image: Image? {
    Image("person")
  }
  
  var body: some View {
    VStack {
      List() {
        if let user = viewModel.user {
          Text(user.uid)
        }
      }
      if let entrepreneur = entrepreneur {
        VStack(alignment: .center) {
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
        }
        Text(entrepreneur.fullName)
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
        
        let companies = entrepreneur.companies
        if companies.isEmpty {
          Text("No companies to show")
            .padding()
            .foregroundColor(.gray)
            .font(.subheadline)
        } else {
          List(companies, id: \.self) { company in
            Text(company.name)
          }
        }
      }
      
      Button("Add Company") {
        isSheetPresented.toggle()
      }
      .sheet(isPresented: $isSheetPresented) {
        FavoritesListView()
      }
      
      Spacer()
    }
    .onAppear {
      Task {
        try viewModel.loadCurrentUser()
      }
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
