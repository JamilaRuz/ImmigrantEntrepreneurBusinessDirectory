//
//  CompanyDetailView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/13/24.
//

import SwiftUI
import SwiftData

struct CompanyDetailView: View {
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
  CompanyDetailView(company: createStubCompanies()[0])
    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
