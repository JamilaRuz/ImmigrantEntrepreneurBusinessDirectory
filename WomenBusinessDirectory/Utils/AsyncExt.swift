//
//  AsyncExt.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/1/24.
//

import Foundation
// Extension to add asyncMap function to Array

extension Array {
    func asyncMap<T>(_ transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        var results = [T]()
        results.reserveCapacity(count)
        
        for element in self {
            try await results.append(transform(element))
        }
        
        return results
    }
}
