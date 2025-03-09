//
//  SettingsViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/20/24.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
  @Published var showReauthDialog = false
  @Published var reauthEmail = ""
  @Published var reauthPassword = ""
  
  func signOut() throws {
    try AuthenticationManager.shared.signOut()
    
    // Reset the skipped authentication state when user signs out
    UserDefaults.standard.set(false, forKey: "hasSkippedAuthentication")
  }
  
  func deleteAccount() async throws {
    do {
      // Get current user's entrepreneur data
      let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
      let entrepreneur = try await EntrepreneurManager.shared.getEntrepreneur(entrepId: authUser.uid)
      
      // Delete all companies associated with the entrepreneur
      for companyId in entrepreneur.companyIds {
        do {
          try await RealCompanyManager.shared.deleteCompany(companyId: companyId)
        } catch {
          print("Error deleting company \(companyId): \(error)")
        }
      }
      
      // Delete entrepreneur document from Firestore
      try await EntrepreneurManager.shared.deleteEntrepreneur(entrepId: authUser.uid)
      
      // Finally, delete the Firebase Auth account
      try await AuthenticationManager.shared.deleteAccount()
      
      // Reset the skipped authentication state when account is deleted
      UserDefaults.standard.set(false, forKey: "hasSkippedAuthentication")
    } catch let error as NSError {
      if error.domain == "FIRAuthErrorDomain" && error.code == 17014 {
        // Need re-authentication
        throw NSError(
          domain: "SettingsViewModel",
          code: 17014,
          userInfo: [NSLocalizedDescriptionKey: "For security reasons, please enter your password to delete your account."]
        )
      } else {
        throw error
      }
    }
  }
  
  func reauthenticateAndDelete(email: String, password: String) async throws {
    try await AuthenticationManager.shared.reauthenticate(email: email, password: password)
    try await deleteAccount()
  }
}
