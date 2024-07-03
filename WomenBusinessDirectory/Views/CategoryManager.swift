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
  let categoryId: String
  let name: String
//  var imageUrl: String
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
    return try querySnapshot.documents.map { try $0.data(as: Category.self) }
  }
}
