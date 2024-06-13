//
//  WomenBusinessDirectoryApp.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct WomenBusinessDirectoryApp: App {
  @StateObject var viewModel = AuthViewModel()
  
  init() {
    FirebaseApp.configure()
  }
  
  let container = try! ModelContainer(for: Company.self)
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(viewModel)
    }
    .modelContainer(container)
  }
}
