//
//  AuthViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/10/24.
//

import Foundation
import Firebase

class AuthViewModel: ObservableObject {
  @Published var userSession: FirebaseAuth.User?
  @Published var currentUser: Entrepreneur?
  
  
  init() {
    
  }
  
  func signIn(email: String, password: String) async throws {
    print("Signing in")
//    isAuthenticating = true
//    Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
//      self?.isAuthenticating = false
//      if let error = error {
//        self?.error = error
//      }
//    }
  }
  
  func signUp(email: String, password: String, fullName: String) async throws {
    do {
      let result = try await Auth.auth().createUser(withEmail: email, password: password)
      self.userSession = result.user
      let user = Entrepreneur(id: result.user.uid, fullName: fullName, email: email, bioDescr: nil, companies: [])
    } catch {
      print("Error signing up: \(error)")
    }
//    isAuthenticating = true
//    Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
//      self?.isAuthenticating = false
//      if let error = error {
//        self?.error = error
//      }
//    }
    print("Signing up")
  }
  
  func signOut() {
    do {
      try Auth.auth().signOut()
    } catch {
      print("Error signing out: \(error)")
    }
  }
  
  func deleteAccount () {
    Auth.auth().currentUser?.delete { error in
      if let error = error {
        print("Error deleting account: \(error)")
      }
    }
  }
  
  func fetchUserData() {
    guard let uid = userSession?.uid else { return }
    Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
      if let error = error {
        print("Error fetching user data: \(error)")
        return
      }
      guard let data = snapshot?.data() else { return }
//      self.currentUser = Entrepreneur(dictionary: data)
    }
  }
}
