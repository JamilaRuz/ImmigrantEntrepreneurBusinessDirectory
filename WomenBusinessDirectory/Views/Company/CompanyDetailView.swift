//
//  CompanyDetailView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/13/24.
//

import SwiftUI

struct CompanyDetailView: View {
  @Environment(\.dismiss) var dismiss
  var company: Company
  @State private var selectedSegment = 0
  
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ZStack {
          AsyncImage(url: URL(string: company.portfolioImages.first ?? "")) { phase in
            switch phase {
            case .empty:
              ProgressView()
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
            case .failure:
              Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
                .foregroundColor(.gray)
            @unknown default:
              EmptyView()
            }
          }
          .frame(height: 300)
          
          VStack {
            Spacer()
            HStack {
              Text(company.name)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .shadow(radius: 10)
                .padding(7)
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
              Spacer()
            }
            .padding(10)
          }
        }
        .padding()
        .frame(height: 300)
        .background(LinearGradient(gradient: Gradient(colors: [Color(.gray).opacity(0.3), Color(.gray)]), startPoint: .top, endPoint: .bottom))
       
          //segments
        VStack(spacing: 0) {
          Picker("Segments", selection: $selectedSegment) {
            Text("Info").tag(0)
            Text("Products").tag(1)
            Text("Map").tag(2)
          }
          .pickerStyle(SegmentedPickerStyle())
          .padding(.horizontal)
          .padding(.top)
          
          VStack {
            if selectedSegment == 0 {
              InfoView(company: company)
            } else if selectedSegment == 1 {
              ProductsView(services: company.services, portfolioImages: company.portfolioImages)
            } else if selectedSegment == 2 {
              MapView(company: company)
            }
          }
          .padding()
        }
        .padding(.horizontal)
          
        Spacer()
          
        HStack(spacing: 20) {
          Button(action: {
            // Action for "Open Now" button
          }) {
            Text("Open Now")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.green.opacity(0.2))
              .foregroundColor(.green)
              .cornerRadius(10)
          }
              
          Button(action: {
            // Action for "Make a Call" button
          }) {
            Text("Make a Call")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.red.opacity(0.2))
              .foregroundColor(.red)
              .cornerRadius(10)
          }
        }
        .padding(.horizontal)
        .padding(.bottom)
      }
    }
    .ignoresSafeArea(edges: .top)
  }
}

#Preview {
  CompanyDetailView(company: createStubCompanies()[0])
}
