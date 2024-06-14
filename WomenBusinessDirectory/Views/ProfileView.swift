//
//  ProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/24/24.
//

import SwiftUI
import SwiftData
import FirebaseFirestoreSwift

struct ProfileView: View {
  //  @Environment(\.modelContext) var modelContext
  @StateObject var viewModel: AuthViewModel
  @State private var isSheetPresented = false
  
  var entrepreneur: Entrepreneur? {
    viewModel.currentUser
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
    .padding()
    .navigationTitle("Profile View")
    .onAppear {
      Task {
        await viewModel.currentUser?.id
      }
    }
  }
}

#Preview {
  ProfileView(viewModel: AuthViewModel())
    .environmentObject(AuthViewModel())
  //  ProfileView(entrepreneur: createStubEntrepreneurs()[0])
  //    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
