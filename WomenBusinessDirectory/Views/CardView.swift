//
//  CardView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/15/24.
//

import SwiftUI
import SwiftData

struct CardView: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Image(category.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .frame(width: 170, height: 120)
            .overlay(alignment: .bottom) {
                Text(category.name)
                    .font(.headline)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3, x: 0, y: 0)
                    .frame(maxWidth: 150)
                    .padding()
            }
        }
        .cornerRadius(10) // Add rounded corners
        .shadow(radius: 5) // Add a subtle shadow
    }
}

#Preview {
  CardView(category: createStubCompanies()[0].category)
    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
