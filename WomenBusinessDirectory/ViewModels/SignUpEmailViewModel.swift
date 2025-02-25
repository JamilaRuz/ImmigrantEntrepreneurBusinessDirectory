//
//  SignUpViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/24/24.
//

import Foundation
import SwiftUI

@MainActor
final class SignUpEmailViewModel: ObservableObject {
  @Published var fullName = ""
  @Published var email = ""
  @Published var password = ""
  
  func signUp() async throws {
    // Ensure email and password are not empty
    guard !email.isEmpty, !password.isEmpty else {
      print("No email or password found!")
      return
    }
    
    print("Signing up...")
    
    do {
      // Step 1: Create the user in Firebase Authentication
      let authDataResult = try await AuthenticationManager.shared.createUser(
        email: email, password: password
      )
      
      // Step 2: Create an Entrepreneur record in Firestore
      var entrepreneur = Entrepreneur(auth: authDataResult)
      entrepreneur.fullName = fullName // Set the full name
      
      print("Before creating entrepreneur...")
      
      try await EntrepreneurManager.shared.createEntrepreneur(
        fullName: entrepreneur.fullName ?? "",
        email: entrepreneur.email ?? ""
      )
      
      print("After creating entrepreneur")
    } catch {
      // Handle errors appropriately
      print("Error during sign-up: \(error.localizedDescription)")
      throw error
    }
  }
  
  func signIn() async throws {
    // Sign in with the same credentials used for sign up
    _ = try await AuthenticationManager.shared.signIn(email: email, password: password)
  }
}

  
