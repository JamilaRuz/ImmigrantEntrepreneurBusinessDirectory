//
//  InfoView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import SwiftUI

struct InfoView: View {
  let company: Company
  
    var body: some View {
      VStack(spacing: 15) {
        VStack(alignment: .leading, spacing: 5) {
          HStack {
            Text("About us")
              .font(.headline)
            Spacer()
            //            Button(action: {
            //              company.isFavorite.toggle()
            //            }) {
            //              Image(systemName: company.isFavorite ? "heart.fill" : "heart")
            //                .resizable()
            //                .tint(Color.red)
            //                .frame(width: 30, height: 30)
            //            }
          }
          Text(company.aboutUs)
            .font(.body)
            .foregroundColor(.gray)
          Text(company.dateFounded)
          Text("Address")
            .font(.headline)
          Text(company.address)
            .font(.body)
            .foregroundColor(.gray)
          Text("(\(company.directions))")
          Text("Contact information")
            .font(.headline)
            .padding(.top)
          Text(company.email)
          Text(company.phoneNum)
          Text(company.socialMediaFacebook)
          Text(company.socialMediaInsta)
          Text(company.workHours)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
      }
      .padding(.horizontal, 10)

    }
}

#Preview {
    InfoView(company: createStubCompanies()[0])
}
