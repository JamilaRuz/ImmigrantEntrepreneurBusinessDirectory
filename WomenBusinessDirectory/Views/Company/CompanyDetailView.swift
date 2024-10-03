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
//    ScrollView {
      VStack {
        //        Image(company.logoImg)
        ZStack {
          Image("logos/company_logo5")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width, height: 300)
            .clipped()
          
          VStack {
            Spacer()
            HStack {
              Text(company.name)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .shadow(radius: 10)
//                .padding(7)
//                .background(Color.black.opacity(0.3))
//                .cornerRadius(10)
              Spacer()
            }
            .padding(10)
          }
        } //ZStack
      } //VStack
      .frame(height: 300)
      .background(LinearGradient(gradient: Gradient(colors: [Color(.gray).opacity(0.3), Color(.gray)]), startPoint: .top, endPoint: .bottom))
      
      VStack {
        Picker("Segments", selection: $selectedSegment) {
          Text("Info").tag(0)
          Text("Products").tag(1)
          Text("Map").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        
        if selectedSegment == 0 {
          InfoView(company: company)
        } else if selectedSegment == 1 {
          ProductsView()
        } else if selectedSegment == 2 {
          MapView(company: company)
        }
      }
      .padding()
//    }
//    .ignoresSafeArea(.container, edges: .top)
  }
}

#Preview {
  CompanyDetailView(company: createStubCompanies()[0])
}
