//
//  AuthenticationManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/18/24.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
  let uid: String
  let email: String?
  var fullName: String?
  var photoUrl: String?

  init(user: User) {
    self.uid = user.uid
    self.email = user.email
    self.fullName = user.displayName
    self.photoUrl = user.photoURL?.absoluteString
  }
}

final class AuthenticationManager {
  
  static let shared = AuthenticationManager()
  
  private init() {}
  
  func getAuthenticatedUser() throws -> AuthDataResultModel {
    guard let user = Auth.auth().currentUser else {
      throw URLError(.badServerResponse)
    }
    return AuthDataResultModel(user: user)
  }

  @discardableResult
  func createUser(email: String, password: String) async throws -> AuthDataResultModel {
    let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
    return AuthDataResultModel(user: authDataResult.user)
  }
  
  @discardableResult
  func signIn(email: String, password: String) async throws -> AuthDataResultModel {
    let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
    return AuthDataResultModel(user: authDataResult.user)
  }
  
  func signOut() throws {
    do {
      try Auth.auth().signOut()
    } catch {
      throw error
    }
  }
  
  func resetPassword(email: String) async throws {
    try await Auth.auth().sendPasswordReset(withEmail: email)
  }
  
  func updatePassword(password: String) async throws {
    guard let user = Auth.auth().currentUser else {
      throw URLError(.badServerResponse)
    }
    try await user.updatePassword(to: password)
  }
  
  func updateEmail(email: String) async throws {
    guard let user = Auth.auth().currentUser else {
      throw URLError(.badServerResponse)
    }
    try await user.updateEmail(to: email)
  }
  
  func deleteAccount() async throws {
    print("Deleting account...")
    guard let user = Auth.auth().currentUser else {
      throw URLError(.badServerResponse)
    }
    try await user.delete()
  }
}