//
//  AuthenticationManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/18/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AuthDataResultModel {
  let uid: String
  let email: String?
  var fullName: String?
//  var profileUrl: String?

  init(user: User) {
    self.uid = user.uid
    self.email = user.email
    self.fullName = user.displayName
//    self.profileUrl = user.profileUrl?.absoluteString
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
  func signIn(email: String, password: String) async throws -> AuthDataResultModel? {
    // Attempt to sign in with Firebase Authentication
    let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
    
    // Check if the email exists in the Firestore database
    let db = Firestore.firestore()
    let querySnapshot = try await db.collection("entrepreneurs")
        .whereField("email", isEqualTo: email)
        .getDocuments()
    
    // If the email exists, return the authenticated user
    if !querySnapshot.isEmpty {
        return AuthDataResultModel(user: authDataResult.user)
    } else {
        // Handle the case where the email does not exist in Firestore
        print("Email does not exist in Firestore.")
        return nil
    }
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
    
  func deleteAccount() async throws {
    print("Deleting account...")
    guard let user = Auth.auth().currentUser else {
      throw URLError(.badServerResponse)
    }
    try await user.delete()
  }
  
  func reauthenticate(email: String, password: String) async throws {
    guard let user = Auth.auth().currentUser else {
      throw URLError(.badServerResponse)
    }
    
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    try await user.reauthenticate(with: credential)
  }
}
