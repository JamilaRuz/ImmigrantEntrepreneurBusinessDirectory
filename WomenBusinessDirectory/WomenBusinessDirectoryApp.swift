//
//  WomenBusinessDirectoryApp.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import SwiftData
import FirebaseCore

//from Firebase tutorial

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main

@MainActor
struct WomenBusinessDirectoryApp: App {
  @StateObject var viewModel = AuthViewModel()
  
  let container = try! ModelContainer(for: Company.self)
  
  //from Firebase tutorial
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(viewModel)
    }
    .modelContainer(container)
  }
}
