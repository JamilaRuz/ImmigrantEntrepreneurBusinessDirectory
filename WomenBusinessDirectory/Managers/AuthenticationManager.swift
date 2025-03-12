//
//  AuthenticationManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/18/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

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
  
  // Property to store the current nonce for Apple Sign In
  var currentNonce: String?
  
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
    
    // Send email verification
    try await sendEmailVerification()
    
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
        // Check profile completion status
        DispatchQueue.main.async {
            ProfileCompletionManager.shared.checkProfileCompletion()
        }
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
  
  func sendEmailVerification() async throws {
    guard let user = Auth.auth().currentUser else {
      throw URLError(.badServerResponse)
    }
    try await user.sendEmailVerification()
  }
  
  func isEmailVerified() -> Bool {
    guard let user = Auth.auth().currentUser else {
      return false
    }
    return user.isEmailVerified
  }
  
  func reloadUser() async throws {
    guard let user = Auth.auth().currentUser else {
      throw URLError(.badServerResponse)
    }
    try await user.reload()
  }
  
  // MARK: - Apple Sign In
  
  // Generate a random nonce for Apple Sign In
  func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }
      
      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }
        
        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    
    return result
  }
  
  // Compute the SHA256 hash of the nonce
  func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()
    
    return hashString
  }
  
  // Start the Apple Sign In process
  func startSignInWithAppleFlow() -> String {
    let nonce = randomNonceString()
    currentNonce = nonce
    return nonce
  }
  
  // Complete the Apple Sign In process with the authorization result
  @discardableResult
  func signInWithApple(idTokenString: String, nonce: String) async throws -> AuthDataResultModel {
    print("AuthenticationManager: Starting signInWithApple with token and nonce")
    
    // Initialize a Firebase credential with the Apple ID token
    let credential = OAuthProvider.credential(
      withProviderID: "apple.com",
      idToken: idTokenString,
      rawNonce: nonce
    )
    
    print("AuthenticationManager: Created Firebase credential with Apple provider")
    
    do {
      // Sign in with Firebase using the Apple credential
      print("AuthenticationManager: Attempting to sign in with Firebase")
      let authDataResult = try await Auth.auth().signIn(with: credential)
      print("AuthenticationManager: Firebase sign in successful: \(authDataResult.user.uid)")
      
      // Check if user exists in Firestore, if not, create a new entry
      let user = authDataResult.user
      let db = Firestore.firestore()
      
      print("AuthenticationManager: Checking if user exists in Firestore")
      
      // Check if user exists in Firestore
      let querySnapshot = try await db.collection("entrepreneurs")
        .whereField("email", isEqualTo: user.email ?? "")
        .getDocuments()
      
      print("AuthenticationManager: Firestore query completed. Documents found: \(querySnapshot.documents.count)")
      
      // If user doesn't exist in Firestore, create a new entry
      if querySnapshot.isEmpty {
        print("AuthenticationManager: User not found in Firestore, creating new entry")
        
        // Create a new user document in Firestore with the correct field names
        let userData: [String: Any] = [
          "entrepId": user.uid, // Use entrepId instead of uid to match the model
          "email": user.email ?? "",
          "fullName": user.displayName ?? "",
          "dateCreated": Timestamp(), // Use dateCreated instead of createdAt to match the model
          "bioDescr": "", // Add empty bioDescr field
          "companyIds": [], // Add empty companyIds array
          "profileUrl": NSNull() // Use NSNull instead of nil for Firestore
        ]
        
        print("AuthenticationManager: Setting user data in Firestore")
        try await db.collection("entrepreneurs").document(user.uid).setData(userData)
        print("AuthenticationManager: User data saved to Firestore")
      } else {
        print("AuthenticationManager: User already exists in Firestore")
      }
      
      // Check profile completion status
      DispatchQueue.main.async {
        ProfileCompletionManager.shared.checkProfileCompletion()
      }
      
      print("AuthenticationManager: Apple sign in process completed successfully")
      return AuthDataResultModel(user: authDataResult.user)
    } catch {
      print("AuthenticationManager: Error during Apple sign in: \(error)")
      throw error
    }
  }
}
