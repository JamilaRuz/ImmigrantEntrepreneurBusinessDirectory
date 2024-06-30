//
//  SignInViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/20/24.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""
  
  func singIn() async throws {
    guard !email.isEmpty, !password.isEmpty else {
      print("No email or password found!")
      return
    }
    
    print("Signing in...")
    
    try await AuthenticationManager.shared.signIn(email: email, password: password)
  }
}
