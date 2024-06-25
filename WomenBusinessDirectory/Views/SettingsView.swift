//
//  ProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/7/24.
//

import SwiftUI
import SwiftData


struct SettingsView: View {
  
  @StateObject private var viewModel = SettingsViewModel()
  @Binding var showSignInView: Bool
  
  var body: some View {
    List {
      //      Section() {
      //        HStack {
      //          Text(user.initials)
      //            .font(.title)
      //            .fontWeight(.semibold)
      //            .foregroundColor(.white)
      //            .frame(width: 72, height: 72)
      //            .background(Color(.systemGray3))
      //            .clipShape(Circle())
      //
      //          VStack(alignment: .leading, spacing: 4) {
      //            Text(user.fullName)
      //              .fontWeight(.semibold)
      //              .padding(.top, 4)
      //            Text(user.email)
      //              .font(.footnote)
      //              .accentColor(.gray)
      //          }
      //        }
      //      } //Section Settings
      
      Section("General") {
        HStack {
          SettingsRowView(imageName: "gear", title: "Version", tintColor: .gray)
          Spacer()
          Text("Version 1.0.0")
            .font(.subheadline)
            .foregroundColor(.gray)
        }
      } // Section General
      
      Section("Account") {
        VStack(alignment: .leading, spacing: 8) {
          Button {
            Task {
              do {
                try viewModel.signOut()
                showSignInView = true
                
              } catch {
                print("Failed to log out: \(error)")
              }
            }
          } label: {
            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Log Out", tintColor: .green4)
          }
          
          Button(role: .destructive) {
            Task {
              do {
                try await viewModel.deleteAccount()
                showSignInView = true
              } catch {
                print("Failed to delete: \(error)")
              }
            }
          } label: {
            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
          }
        } //VStack
      } // Section Account
      
      emailSection
      
    }//List
    .navigationTitle("Settings")
  }
}

#Preview {
  //  ProfileView(entrepreneur: createStubEntrepreneurs()[0])
  SettingsView(showSignInView: .constant(true))
}

extension SettingsView {
  private var emailSection: some View {
    Section("Email Functions") {
      Button() {
        Task {
          do {
            try await viewModel.resetPassword()
            print("Password reset email sent")
          } catch {
            print("Failed to reset password: \(error)")
          }
        }
      } label: {
        SettingsRowView(imageName: "person.badge.key", title: "Reset password", tintColor: .green4)
      }

      Button() {
        Task {
          do {
            try await viewModel.updatePassword()
            print("Password updated")
          } catch {
            print("Failed to update password: \(error)")
          }
        }
      } label: {
        SettingsRowView(imageName: "lock.circle", title: "Update password", tintColor: .green4)
      }
      Button() {
        Task {
          do {
            try await viewModel.updateEmail()
            print("Email updated")
          } catch {
            print("Failed to update email: \(error)")
          }
        }
      } label: {
        SettingsRowView(imageName: "person.badge.key", title: "Update email", tintColor: .green4)
      }
    } //Section Email
  }
}
