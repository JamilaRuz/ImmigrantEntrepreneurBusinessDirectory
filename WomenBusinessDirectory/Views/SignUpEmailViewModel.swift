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
  
  func singUp() async throws {
    guard !email.isEmpty, !password.isEmpty else {
      print("No email or password found!")
      return
    }
    
    print("Signing up...")
    var authDataResult = try await AuthenticationManager.shared.createUser(
      email: email, password: password
    )
    authDataResult.fullName = fullName
    
    let entrepreneur = Entrepreneur(auth: authDataResult)
    print("Before creating entrepreneur...")
    
    try await EntrepreneurManager.shared.createEntrepreneur(entrep: entrepreneur)
    print("After creating entrepreneur")
  }
  
}

  