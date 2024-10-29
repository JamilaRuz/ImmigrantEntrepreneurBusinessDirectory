//
//  CategoryManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Category: Codable, Hashable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.id = "" // This will be set from document.documentID
    }
}

final class CategoryManager {
  
  static let shared = CategoryManager()
  private init() {}
  
  private let categoriesCollection = Firestore.firestore().collection("categories")
  
  private func categoryDocument(categoryId: String) -> DocumentReference {
    return categoriesCollection.document(categoryId)
  }
  
  func getCategory(categoryId: String) async throws -> Category {
    try await categoryDocument(categoryId: categoryId).getDocument(as: Category.self)
  }
  
  func getCategories() async throws -> [Category] {
    let querySnapshot = try await categoriesCollection.getDocuments()
    return querySnapshot.documents.map { document in
        let data = try! document.data(as: Category.self)
        return Category(id: document.documentID, name: data.name)
    }
  }
}
