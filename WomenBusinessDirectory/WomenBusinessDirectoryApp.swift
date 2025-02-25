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
  
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        SplashScreen()
          .environment(\.companyManager, RealCompanyManager.shared)
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

struct CompanyManagerKey: EnvironmentKey {
  static let defaultValue: CompanyManager = RealCompanyManager.shared
}

extension EnvironmentValues {
  var companyManager: CompanyManager {
    get { self[CompanyManagerKey.self] }
    set { self[CompanyManagerKey.self] = newValue }
  }
}
