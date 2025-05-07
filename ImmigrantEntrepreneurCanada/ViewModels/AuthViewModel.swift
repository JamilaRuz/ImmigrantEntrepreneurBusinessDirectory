////
////  AuthViewModel.swift
////  ImmigrantEntrepreneurCanada
////
////  Created by Jamila Ruzimetova on 6/10/24.
////
//
//import Foundation
//import Firebase
//import FirebaseFirestoreSwift
//
protocol AuthenticationFormProtocol {
  var formIsValid: Bool { get }
}
//
//@MainActor
//class AuthViewModel: ObservableObject {
//  @Published var userSession: FirebaseAuth.User?
//  @Published var currentUser: Entrepreneur?
//  
//  init() {
//    self.userSession = Auth.auth().currentUser
//    
//    Task {
//      await fetchUserData()
//    }
//  }
//  
//  func signIn(email: String, password: String) async throws {
//    do {
//      let result = try await Auth.auth().signIn(withEmail: email, password: password)
//      self.userSession = result.user
//      await fetchUserData()
//    } catch {
//      print("Failed to sign in with error \(error.localizedDescription)")
//    }
//  }
//  
//  
//  //  it's an asynchronous func that can throw an error
//  func signUp(email: String, password: String, fullName: String) async throws {
//    do {
//      //      creating a user with Firebase package and save in result
//      let result = try await Auth.auth().createUser(withEmail: email, password: password)
//      
//      //if we have successfully created a user, we can set userSession property
//      self.userSession = result.user
//      //here we are creating OUR user object
//      let user = Entrepreneur(id: result.user.uid, fullName: fullName, email: email, bioDescr: nil, companies: [])
//      //encode that object through the Codable property
//      let encodedUser = try Firestore.Encoder().encode(user)
//      //save that object in Firestore
//      try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
//      await fetchUserData()
//    } catch {
//      print("Failed to create user with error \(error.localizedDescription)")
//    }
//  }
//  
//  func signOut() {
//    do {
//      try Auth.auth().signOut()
//      self.userSession = nil
//      self.currentUser = nil
//    } catch {
//      print("Error signing out: \(error.localizedDescription)")
//    }
//  }
//  
//  func deleteAccount () {
//    Auth.auth().currentUser?.delete { error in
//      if let error = error {
//        print("Error deleting account: \(error)")
//      }
//    }
//  }
//  
//  func fetchUserData() async {
//    guard let uid = Auth.auth().currentUser?.uid else { return }
//    guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
//    self.currentUser = try! snapshot.data(as: Entrepreneur.self)
//    
//    print("Current user: \(String(describing: self.currentUser))")
//  }
//}
