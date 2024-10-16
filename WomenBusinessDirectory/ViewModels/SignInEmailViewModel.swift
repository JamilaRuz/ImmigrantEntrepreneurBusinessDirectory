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
  
  func signIn(email: String, password: String) async throws -> Bool {
      return ((try await AuthenticationManager.shared.signIn(email: email, password: password)) != nil)
  }
    
}
