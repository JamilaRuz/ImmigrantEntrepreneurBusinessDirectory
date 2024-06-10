//
//  ProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/7/24.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
  @Environment(\.modelContext) var modelContext
  
  var entrepreneur: Entrepreneur

    var body: some View {
      List {
        Section() {
          HStack {
//            Text(Entrepreneur.MOCK_USER.initials)
            Text(entrepreneur.initials)
              .font(.title)
              .fontWeight(.semibold)
              .foregroundColor(.white)
              .frame(width: 72, height: 72)
              .background(Color(.systemGray3))
              .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
              Text("Michael Jordan")
                .fontWeight(.semibold)
                .padding(.top, 4)
              Text("test@gmail.com")
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
            print("Sign out button tapped")
          } label: {
            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
          }
          Button {
            print("Delete accout button tapped")
          } label: {
            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
          }
        }
      }
    }
}

#Preview {
  ProfileView(entrepreneur: createStubEntrepreneurs()[0])
    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
