//
//  GeneralStyles.swift
//  ImmigrantEntrepreneurCanada
//
//  Created by Jamila Ruzimetova on 6/6/24.
//

import Foundation
import SwiftUI

struct TextFieldStyle: ViewModifier {
  func body(content: Content) -> some View {
        content
          .padding(10)
          .background(Color(.systemGray6))
          .cornerRadius(8)
          .shadow(radius: 3)
          .padding(.horizontal)
          .frame(width: 300, height: 40)
    }
}

extension View {
  func applyTextFieldStyle() -> some View {
    self.modifier(TextFieldStyle())
  }
}
