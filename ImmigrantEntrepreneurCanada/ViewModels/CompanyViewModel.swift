//
//  CompanyViewModel.swift
//  ImmigrantEntrepreneurCanada
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import Foundation

final class CompanyViewModel: ObservableObject {
  
  func getCompanies() async throws -> [Company?] {
    let companies = try await RealCompanyManager.shared.getCompanies()
    return companies
  }
}
