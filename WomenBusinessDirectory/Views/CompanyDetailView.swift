//
//  CompanyDetailView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/13/24.
//

import SwiftUI
import SwiftData

struct CompanyDetailView: View {
    @Query private var companies: [Company]
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    var company: Company
    
    var body: some View {
        ScrollView {
            VStack {
                Image(company.logoImg)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: 300)
                    .clipped()
            } //image
            .frame(height: 300)
            .background(LinearGradient(gradient: Gradient(colors: [Color(.gray).opacity(0.3), Color(.gray)]), startPoint: .top, endPoint: .bottom))
            
            VStack(spacing: 15) {
                Text(company.name)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("About us")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            company.isFavorite.toggle()
                        }) {
                            Image(systemName: company.isFavorite ? "heart.fill" : "heart")
                                .resizable()
                                .tint(Color.red)
                                .frame(width: 30, height: 30)
                        }
                    }
                    Text(company.aboutUs)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                    VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Address")
                            .font(.headline)
                        Spacer()
                    }
                    Text(company.address)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 10)
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    
}

#Preview {
    CompanyDetailView(
        company: Company(
            name: "Company name", logoImg: "logoImg", aboutUs: "Description of the company", dateFounded: "12.22.2024", entrepreneur: Entrepreneur(firstName: "John", lastName: "Smith", image: "placeholder", bioDescr: "some detail go here"), address: "Address line goes here", phoneNum: "1233243435", email: "kfjg@gmail.com", workHours: "working hours", directions: "Description of the directions go here", category: Category(name: "Retail", image: "retail"), isFavorite: true)
        )
        .modelContainer(for: Company.self, inMemory: true)
 
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true) // Store the container in memory since we don't actually want to save the preview data
//        let container = try ModelContainer(for: Recipe.self, configurations: config)
//
//        return RecipeDetails(recipe: recipes[0])
//            .modelContainer(container)
//    } catch {
//        return Text("Failed to create preview: \(error.localizedDescription)")
//    }
}
