//
//  CategoryViewModel.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class AddCompanyViewModel: ObservableObject {
  @Published private(set) var categories: [Category] = []

  init() {
    Task {
      do {
        try await loadCategories()
      } catch {
        // TODO handle error
        print("Failed to load categories: \(error)")
      }
    }
  }
  
  func createCompany(company: Company) async throws {
    try await RealCompanyManager.shared.createCompany(company: company)
    try await EntrepreneurManager.shared.addCompany(company: company)
  }

  private func loadCategories() async throws {
    self.categories = try await CategoryManager.shared.getCategories()
  }
}
