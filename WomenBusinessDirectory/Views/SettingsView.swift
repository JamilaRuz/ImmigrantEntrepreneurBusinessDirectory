//
//  ProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/7/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
//  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var viewModel: AuthViewModel
  
//  var entrepreneur: Entrepreneur

    var body: some View {
      if let user = viewModel.currentUser {
        List {
          Section() {
            HStack {
              Text(user.initials)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 72, height: 72)
                .background(Color(.systemGray3))
                .clipShape(Circle())
              
              VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                  .fontWeight(.semibold)
                  .padding(.top, 4)
                Text(user.email)
                  .font(.footnote)
                  .accentColor(.gray)
              }
            }
          }
          Section("General") {
            HStack {
              SettingsRowView(imageName: "gear", title: "Version", tintColor: .gray)
              Spacer()
              Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.gray)
            }
          }
          Section("Account") {
            Button {
              viewModel.signOut()
            } label: {
              SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
            }
            Button {
              viewModel.deleteAccount()
            } label: {
              SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
            }
          }
        }
      }
    }
}

#Preview {
//  ProfileView(entrepreneur: createStubEntrepreneurs()[0])
  SettingsView()
    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
