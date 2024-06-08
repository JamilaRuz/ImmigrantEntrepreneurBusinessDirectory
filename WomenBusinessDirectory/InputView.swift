//
//  InputView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/7/24.
//

import SwiftUI

struct InputView: View {
  @Binding var text: String
  let title: String
  let placeholder: String
  var isSecuredField = false
  
    var body: some View {
      VStack(alignment: .leading, spacing: 12) {
        Text(title)
          .foregroundColor(.gray)
          .fontWeight(.semibold)
          .font(.footnote)
        
        if isSecuredField {
          SecureField(placeholder, text: $text)
            .font(.system(size: 14))
        } else {
          TextField(placeholder, text: $text)
            .font(.system(size: 14))
        }
        Divider()
      }
    }
}

#Preview {
  InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
}
