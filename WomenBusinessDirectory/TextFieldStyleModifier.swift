//
//  TextFieldStyleModifier.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 6/7/24.
//

import SwiftUI

struct TextFieldStyleModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding(5)
      .background(.white)
      .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .cornerRadius(8)
      .shadow(radius: 8)
  }
}
