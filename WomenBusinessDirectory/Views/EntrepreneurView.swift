//
//  ProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/24/24.
//

import SwiftUI
import SwiftData

struct EntrepreneurView: View {
  @Environment(\.modelContext) var modelContext
  
  var entrepreneur: Entrepreneur
  
  var body: some View {
    NavigationStack {
      if entrepreneur.fullName.isEmpty && entrepreneur.bioDescr.isEmpty && entrepreneur.companies.isEmpty {
        Text("Fill out Profile first")
          .foregroundColor(.red)
          .font(.headline)
//        NavigationLink("Edit Profile", destination: EditProfileView(entrepreneur: entrepreneur))
      } else {
        Text(entrepreneur.fullName)
        Text(entrepreneur.bioDescr)
        List(entrepreneur.companies, id: \.self) { company in
          Text(company.name)
        }
      }
    }
    .navigationTitle("Profile View")
  }
}

#Preview {
  EntrepreneurView(entrepreneur: createStubEntrepreneurs()[0])
    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
