//
//  WomenBusinessDirectoryApp.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import Firebase

@main
struct WomenBusinessDirectoryApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
//  init() {
//    FirebaseApp.configure()
//  }
  
  var body: some Scene {
    WindowGroup {
      NavigationStack {
//        RootView()
        ContentView()
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
