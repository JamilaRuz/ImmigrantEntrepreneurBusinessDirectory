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
      
      // Now delete the Firebase Auth account - this is critical
      do {
        try await AuthenticationManager.shared.deleteAccount()
      } catch let error as NSError {
        // Firebase requires recent authentication to delete an account
        if error.domain == "FIRAuthErrorDomain" && error.code == 17014 {
          print("Unable to delete Firebase Auth account: requires recent authentication")
          // We'll at least sign out the user
          try? AuthenticationManager.shared.signOut()
          
          // Throw a specialized error that tells the user they need to sign out and sign back in first
          throw NSError(
            domain: "SettingsViewModel",
            code: 1001,
            userInfo: [NSLocalizedDescriptionKey: "For security reasons, please sign out and sign in again before deleting your account."]
          )
        } else {
          print("Could not delete auth account, but removed all user data: \(error.localizedDescription)")
          // Force sign out to ensure the user session is cleared
          try? AuthenticationManager.shared.signOut()
          throw error
        }
      }
      
      // Reset the skipped authentication state when account is deleted
      UserDefaults.standard.set(false, forKey: "hasSkippedAuthentication")
    } catch {
      print("Error deleting account: \(error.localizedDescription)")
      throw error
    }
  }
  
  func reauthenticateAndDelete(email: String, password: String) async throws {
    try await AuthenticationManager.shared.reauthenticate(email: email, password: password)
    try await deleteAccount()
  }
}
