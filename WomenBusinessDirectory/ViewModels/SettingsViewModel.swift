//
//  SettingsViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/20/24.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
  
  func signOut() throws {
    try AuthenticationManager.shared.signOut()
  }
  
  func deleteAccount() async throws {
    try await AuthenticationManager.shared.deleteAccount()
  }
  
  func resetPassword() async throws {
    let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
    guard let email = authUser.email else {
      throw URLError(.badServerResponse)
    }
    try await AuthenticationManager.shared.resetPassword(email: email)
  }
  
  func updatePassword() async throws {
    let password = "hello123"
    try await AuthenticationManager.shared.updateEmail(email: password)
  }
  
}
