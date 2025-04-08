//
//  AuthenticationManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/18/24.
//

import Foundation
@preconcurrency import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit
import Combine

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

@MainActor
final class AuthenticationManager: ObservableObject, @unchecked Sendable {
  
  static let shared = AuthenticationManager()
  
  @Published var isAuthenticated = false
  @Published var isAnonymous = false
  @Published var currentUser: AuthDataResultModel?
  
  // Property to store the current nonce for Apple Sign In
  var currentNonce: String?
  
  // Store the auth state listener handle
  private var authStateHandle: AuthStateDidChangeListenerHandle?
  
  private init() {
    // Set initial authentication state
    if let user = Auth.auth().currentUser {
      self.isAuthenticated = true
      self.isAnonymous = user.isAnonymous
      self.currentUser = AuthDataResultModel(user: user)
    }
    
    // Add auth state listener and store the handle
    authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      DispatchQueue.main.async {
        self?.isAuthenticated = user != nil
        self?.isAnonymous = user?.isAnonymous ?? false
        self?.currentUser = user.map { AuthDataResultModel(user: $0) }
      }
    }
  }
  
  deinit {
    // Remove the auth state listener when the object is deallocated
    if let handle = authStateHandle {
      Auth.auth().removeStateDidChangeListener(handle)
    }
  }
  
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
    let user = authDataResult.user
    
    // Update published properties
    DispatchQueue.main.async { [weak self] in
      self?.isAuthenticated = true
      self?.isAnonymous = false
      self?.currentUser = AuthDataResultModel(user: user)
    }
    
    // Check if the email exists in the Firestore database
    let db = Firestore.firestore()
    let querySnapshot = try await db.collection("entrepreneurs")
        .whereField("email", isEqualTo: email)
        .getDocuments()
    
    // If the email doesn't exist in Firestore, create a new document
    if querySnapshot.isEmpty {
        print("Email exists in Authentication but not in Firestore. Creating new document...")
        
        // Create a new user document in Firestore with the correct field names
        let userData: [String: Any] = [
          "entrepId": user.uid,
          "email": user.email ?? "",
          "fullName": user.displayName ?? "",
          "dateCreated": Timestamp(),
          "bioDescr": "",
          "companyIds": [],
          "profileUrl": NSNull()
        ]
        
        try await db.collection("entrepreneurs").document(user.uid).setData(userData)
        print("Created new entrepreneur document in Firestore.")
    }
    
    // Check profile completion status
    DispatchQueue.main.async {
        ProfileCompletionManager.shared.checkProfileCompletion()
    }
    
    return AuthDataResultModel(user: authDataResult.user)
  }
  
  func signOut() throws {
    do {
      try Auth.auth().signOut()
      // Update published properties
      DispatchQueue.main.async { [weak self] in
        self?.isAuthenticated = false
        self?.isAnonymous = false
        self?.currentUser = nil
      }
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
    
    // Create the Firebase credential from Apple ID token and nonce
    let credential = OAuthProvider.credential(
      withProviderID: "apple.com",
      idToken: idTokenString, 
      rawNonce: nonce
    )
    
    // Sign in with Firebase using the credential
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
  }
  
  // MARK: - Google Sign In
  
  @discardableResult
  func signInWithGoogle(idToken: String, accessToken: String?) async throws -> AuthDataResultModel {
    print("AuthenticationManager: Starting signInWithGoogle with token")
    
    // Initialize a Firebase credential with the Google ID token
    let credential = GoogleAuthProvider.credential(
      withIDToken: idToken,
      accessToken: accessToken ?? ""
    )
    
    print("AuthenticationManager: Created Firebase credential with Google provider")
    
    do {
      // Authenticate with Firebase using the Google credential
      let authDataResult = try await Auth.auth().signIn(with: credential)
      let user = authDataResult.user
      print("AuthenticationManager: User signed in with Google: \(user.uid)")
      
      // Check if the user already exists in Firestore
      let db = Firestore.firestore()
      let docRef = db.collection("entrepreneurs").document(user.uid)
      let docSnapshot = try await docRef.getDocument()
      
      // If user doesn't exist in Firestore, create a new document
      if !docSnapshot.exists {
        print("AuthenticationManager: User doesn't exist in Firestore, creating new document")
        
        // Create a new user document with information from Google
        let userData: [String: Any] = [
          "entrepId": user.uid,
          "email": user.email ?? "",
          "fullName": user.displayName ?? "",
          "dateCreated": Timestamp(),
          "bioDescr": "",
          "companyIds": [],
          "profileUrl": user.photoURL?.absoluteString ?? NSNull()
        ]
        
        try await docRef.setData(userData)
        print("AuthenticationManager: Created new entrepreneur document in Firestore")
      }
      
      // Check profile completion status
      DispatchQueue.main.async {
        ProfileCompletionManager.shared.checkProfileCompletion()
      }
      
      print("AuthenticationManager: Google sign in process completed successfully")
      return AuthDataResultModel(user: authDataResult.user)
    } catch {
      print("AuthenticationManager: Error during Google sign in: \(error)")
      throw error
    }
  }
}
