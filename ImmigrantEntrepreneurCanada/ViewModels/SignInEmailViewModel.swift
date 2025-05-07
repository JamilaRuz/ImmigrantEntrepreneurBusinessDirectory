//
//  SignInViewModel.swift
//  ImmigrantEntrepreneurCanada
//
//  Created by Jamila Ruzimetova on 6/20/24.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {

  @Published var email = ""
  @Published var password = ""
  
  func signIn(email: String, password: String) async throws -> Bool {
      let authResult = try await AuthenticationManager.shared.signIn(email: email, password: password)
      
      // If sign-in was successful, check if email is verified
      if authResult != nil {
          // Reload the user to get the latest verification status
          try await AuthenticationManager.shared.reloadUser()
          
          // Check if email is verified
          if !AuthenticationManager.shared.isEmailVerified() {
              // If email is not verified, sign out and throw an error
              try AuthenticationManager.shared.signOut()
              throw NSError(
                  domain: "EmailVerificationError",
                  code: 1001,
                  userInfo: [NSLocalizedDescriptionKey: "Please verify your email before signing in. Check your inbox for a verification link."]
              )
          }
          
          return true
      }
      
      return false
  }
    
  func resendVerificationEmail() async throws {
      try await AuthenticationManager.shared.sendEmailVerification()
  }
}
