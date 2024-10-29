//
//  EmptyCompaniesListView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 10/29/24.
//

import SwiftUI

struct EmptyCompaniesListView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Companies Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Companies in this category will appear here once they are added.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    EmptyCompaniesListView()
}
