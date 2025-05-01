//
//  SettingsViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/20/24.
//

import Foundation
import FirebaseAuth

@MainActor
final class SettingsViewModel: ObservableObject {
  @Published var showDeleteReauthDialog = false
  @Published var reauthEmail = ""
  @Published var reauthPassword = ""
  
  func signOut() throws {
    try AuthenticationManager.shared.signOut()
    
    // Reset the skipped authentication state when user signs out
    UserDefaults.standard.set(false, forKey: "hasSkippedAuthentication")
  }
  
  func deleteAccount() async throws {
    do {
      guard Auth.auth().currentUser != nil else {
        throw NSError(domain: "SettingsViewModel", code: 1000, userInfo: [NSLocalizedDescriptionKey: "User not found"])
      }
      
      try await performDeletion()
    } catch {
      print("Error in delete account flow: \(error.localizedDescription)")
      throw error
    }
  }
  
  // This function handles the actual deletion process after authentication
  private func performDeletion() async throws {
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
      try await AuthenticationManager.shared.deleteAccount()
      
      // Reset the skipped authentication state when account is deleted
      UserDefaults.standard.set(false, forKey: "hasSkippedAuthentication")
  }
}
