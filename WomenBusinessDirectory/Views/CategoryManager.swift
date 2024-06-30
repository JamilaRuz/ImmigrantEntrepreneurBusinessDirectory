//
//  CategoryManager.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Category: Codable {
  let categoryId: String
  let name: String
  var imageUrl: String
}

final class CategoryManager {
  
  static let shared = CategoryManager()
  private init() {}
  
  private let categoriesCollection = Firestore.firestore().collection("categories")
  
  private func categoryDocument(categoryId: String) -> DocumentReference {
    return categoriesCollection.document(categoryId)
  }
  
  func createCategory(category: Category) async throws {
    print("Creating category...")
    try categoryDocument(categoryId: category.categoryId).setData(from: category, merge: false)
    print("Category created!")
  }

  func getCategory(categoryId: String) async throws -> Category {
    try await categoryDocument(categoryId: categoryId).getDocument(as: Category.self)
  }
}
