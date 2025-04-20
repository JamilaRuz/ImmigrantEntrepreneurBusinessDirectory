//
//  EntrepreneurManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct Entrepreneur: Codable, Hashable {
  var entrepId: String
  var fullName: String?
  var profileUrl: String?
  var dateCreated: Date
  var email: String?
  var bioDescr: String?
  var companyIds: [String] = []
  
  init(auth: AuthDataResultModel) {
    self.entrepId = auth.uid
    self.fullName = auth.fullName
    self.email = auth.email
    self.dateCreated = Date()
    self.bioDescr = ""
    self.profileUrl = nil
  }
  
  init(entrepId: String, fullName: String, profileUrl: String?, email: String, bioDescr: String, companyIds: [String]) {
    self.entrepId = entrepId
    self.fullName = fullName
    self.profileUrl = profileUrl
    self.email = email
    self.bioDescr = bioDescr
    self.companyIds = companyIds
    self.dateCreated = Date()
  }
  
  // Add a custom decoder initializer to handle potential null values
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.entrepId = try container.decode(String.self, forKey: .entrepId)
    self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName)
    self.profileUrl = try container.decodeIfPresent(String.self, forKey: .profileUrl)
    self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    self.email = try container.decodeIfPresent(String.self, forKey: .email)
    self.bioDescr = try container.decodeIfPresent(String.self, forKey: .bioDescr)
    self.companyIds = try container.decodeIfPresent([String].self, forKey: .companyIds) ?? []
  }
}

final class EntrepreneurManager {
  
  static let shared = EntrepreneurManager()
  private init() {}
  
  private let entrepCollection = Firestore.firestore().collection("entrepreneurs")
  
  private let storageRef = Storage.storage().reference()
  
  private func entrepDocument(entrepId: String) -> DocumentReference {
    print("Creating document reference for entrepId: \(entrepId)")
    return entrepCollection.document(entrepId)
  }
  
func createEntrepreneur(fullName: String, email: String) async throws {
    guard let uid = Auth.auth().currentUser?.uid else {
        throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
    }
    print("Creating entrepreneur with uid: \(uid)")
    let entrepreneur = Entrepreneur(entrepId: uid, fullName: fullName, profileUrl: nil, email: email, bioDescr: "", companyIds: [])
    print("Entrepreneur created: \(entrepreneur)")
    
    // Create a dictionary with all the fields to ensure they're all properly set
    let data: [String: Any] = [
        "entrepId": entrepreneur.entrepId,
        "fullName": entrepreneur.fullName ?? "",
        "profileUrl": NSNull(), // Use NSNull instead of nil
        "dateCreated": entrepreneur.dateCreated,
        "email": entrepreneur.email ?? "",
        "bioDescr": entrepreneur.bioDescr ?? "",
        "companyIds": entrepreneur.companyIds
    ]
    
    try await entrepDocument(entrepId: uid).setData(data)
}

  func getEntrepreneur(entrepId: String) async throws -> Entrepreneur {
    try await entrepDocument(entrepId: entrepId).getDocument(as: Entrepreneur.self)
  }
  
  func addCompany(company: Company) async throws {
    print("Adding company \(company.companyId) to entrepreneur \(company.entrepId)")
    var entrep = try await getEntrepreneur(entrepId: company.entrepId)
    entrep.companyIds.append(company.companyId)
    try entrepDocument(entrepId: entrep.entrepId).setData(from: entrep, merge: true)
    print("Successfully added company to entrepreneur's list")
  }

  func removeCompany(companyId: String) async throws {
    guard let uid = Auth.auth().currentUser?.uid else {
        throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
    }
    
    print("Removing company \(companyId) from entrepreneur \(uid)")
    
    // Get the current entrepreneur data
    var entrep = try await getEntrepreneur(entrepId: uid)
    
    // Check if the company ID exists in the list
    guard entrep.companyIds.contains(companyId) else {
        print("Company \(companyId) not found in entrepreneur's list")
        return
    }
    
    // Remove the company ID
    entrep.companyIds.removeAll { $0 == companyId }
    
    // Update the entrepreneur document
    try entrepDocument(entrepId: entrep.entrepId).setData(from: entrep, merge: true)
    print("Successfully removed company \(companyId) from entrepreneur's list")
  }
  
  func uploadProfileImage(_ image: UIImage, for entrepreneur: Entrepreneur) async throws -> String {
    // Resize image to appropriate dimensions for profile (max 500px while preserving aspect ratio)
    let resizedImage = image.preparingForUpload(maxDimension: 500)
    
    guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
      throw NSError(domain: "EntrepreneurManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
    }

    let imageName = UUID().uuidString + ".jpg"
    let imageReference = storageRef.child("profile_images/\(imageName)")

    do {
      // Attempt to upload the image data
      _ = try await imageReference.putDataAsync(imageData)
      
      // If successful, get the download URL
      let downloadURL = try await imageReference.downloadURL()
      
      // Return the URL as a string
      return downloadURL.absoluteString
    } catch {
      // Handle any errors that occur during upload
      print("Error uploading image: \(error.localizedDescription)")
      throw error
    }
  }

  func updateEntrepreneur(_ entrepreneur: Entrepreneur) async throws {
    guard !entrepreneur.entrepId.isEmpty else {
        throw NSError(domain: "EntrepreneurManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Entrepreneur ID cannot be empty"])
    }
    print("Updating entrepreneur: \(entrepreneur.entrepId)")
    print("Bio being saved: \(entrepreneur.bioDescr ?? "nil")")
    
    // Create a dictionary with all the fields to ensure they're all updated
    var data: [String: Any] = [
        "entrepId": entrepreneur.entrepId,
        "dateCreated": entrepreneur.dateCreated,
        "companyIds": entrepreneur.companyIds
    ]
    
    // Add optional fields, using NSNull for nil values
    if let fullName = entrepreneur.fullName {
        data["fullName"] = fullName
    } else {
        data["fullName"] = ""
    }
    
    if let profileUrl = entrepreneur.profileUrl {
        data["profileUrl"] = profileUrl
    } else {
        data["profileUrl"] = NSNull()
    }
    
    if let email = entrepreneur.email {
        data["email"] = email
    } else {
        data["email"] = ""
    }
    
    if let bioDescr = entrepreneur.bioDescr {
        data["bioDescr"] = bioDescr
    } else {
        data["bioDescr"] = ""
    }
    
    try await entrepDocument(entrepId: entrepreneur.entrepId).setData(data, merge: false)
    print("Entrepreneur updated successfully")
  }

  func getAllEntrepreneurs() async throws -> [Entrepreneur] {
    print("Fetching all entrepreneurs...")
    let snapshot = try await entrepCollection.getDocuments()
    
    var entrepreneurs: [Entrepreneur] = []
    
    for document in snapshot.documents {
        do {
            // Try to decode the document as an Entrepreneur
            let entrepreneur = try document.data(as: Entrepreneur.self)
            entrepreneurs.append(entrepreneur)
        } catch let error as DecodingError {
            // If there's a decoding error, try to migrate the document
            print("Error decoding entrepreneur document: \(error)")
            if let migratedEntrepreneur = try? await migrateEntrepreneurDocument(document) {
                entrepreneurs.append(migratedEntrepreneur)
            }
        } catch {
            print("Unknown error processing entrepreneur document: \(error)")
        }
    }
    
    print("Successfully fetched \(entrepreneurs.count) entrepreneurs")
    return entrepreneurs
  }
  
  // Function to migrate entrepreneur documents with wrong field names
  private func migrateEntrepreneurDocument(_ document: QueryDocumentSnapshot) async throws -> Entrepreneur {
    print("Attempting to migrate entrepreneur document: \(document.documentID)")
    
    let data = document.data()
    
    // Check if this is a document with the old schema (uid instead of entrepId)
    if let uid = data["uid"] as? String {
        print("Found document with old schema (uid instead of entrepId)")
        
        // Create a new document with the correct field names
        let updatedData: [String: Any] = [
            "entrepId": uid,
            "email": data["email"] as? String ?? "",
            "fullName": data["fullName"] as? String ?? "",
            "dateCreated": data["createdAt"] as? Timestamp ?? Timestamp(),
            "bioDescr": data["bioDescr"] as? String ?? "",
            "companyIds": data["companyIds"] as? [String] ?? [],
            "profileUrl": data["profileUrl"] as? String ?? NSNull()
        ]
        
        // Update the document with the correct field names
        try await entrepCollection.document(document.documentID).setData(updatedData)
        print("Successfully migrated entrepreneur document: \(document.documentID)")
        
        // Create and return an Entrepreneur object
        return Entrepreneur(
            entrepId: uid,
            fullName: updatedData["fullName"] as? String ?? "",
            profileUrl: updatedData["profileUrl"] as? String,
            email: updatedData["email"] as? String ?? "",
            bioDescr: updatedData["bioDescr"] as? String ?? "",
            companyIds: updatedData["companyIds"] as? [String] ?? []
        )
    } else {
        throw NSError(domain: "EntrepreneurManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Document does not have expected fields for migration"])
    }
  }

  func deleteEntrepreneur(entrepId: String) async throws {
    print("Deleting entrepreneur with ID: \(entrepId)")
    
    // Get the entrepreneur data first
    let entrepreneur = try await getEntrepreneur(entrepId: entrepId)
    
    // Delete profile image if it exists
    if let profileUrl = entrepreneur.profileUrl {
      let storageRef = Storage.storage().reference(forURL: profileUrl)
      try? await storageRef.delete()
    }
    
    // Delete the entrepreneur document
    try await entrepDocument(entrepId: entrepId).delete()
    print("Successfully deleted entrepreneur and related data")
  }
  
  func deleteProfileImage(imageUrl: String) async throws {
    do {
      print("Starting to delete profile image from storage: \(imageUrl)")
      
      // Extract filename from URL for better logging
      let filename = URL(string: imageUrl)?.lastPathComponent ?? "unknown"
      
      let storageRef = Storage.storage().reference(forURL: imageUrl)
      try await storageRef.delete()
      
      // After successfully deleting, verify the image no longer exists
      print("✅ Successfully deleted profile image \(filename) from storage")
      
      // You could add analytics event here if needed
      // Analytics.logEvent("profile_image_deleted", parameters: ["status": "success"])
    } catch let error as NSError {
      // Check if it's an object not found error (the file doesn't exist)
      if error.code == StorageErrorCode.objectNotFound.rawValue {
        // The file didn't exist - might have been already deleted
        print("⚠️ Profile image was already deleted or doesn't exist: \(imageUrl)")
        return // Don't throw an error in this case
      }
      
      print("❌ Error deleting profile image from storage: \(error.localizedDescription)")
      // Analytics.logEvent("profile_image_deleted", parameters: ["status": "error", "error": error.localizedDescription])
      
      throw NSError(
        domain: "EntrepreneurManager",
        code: error.code,
        userInfo: [NSLocalizedDescriptionKey: "Error deleting profile image from storage: \(error.localizedDescription)"]
      )
    }
  }
}
