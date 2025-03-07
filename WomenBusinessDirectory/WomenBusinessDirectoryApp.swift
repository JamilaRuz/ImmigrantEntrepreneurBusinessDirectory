//
//  WomenBusinessDirectoryApp.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import Firebase
import AuthenticationServices

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
    
    // Set up ASAuthorizationController delegate for Sign in with Apple
    ASAuthorizationAppleIDProvider().getCredentialState(forUserID: UserDefaults.standard.string(forKey: "appleUserID") ?? "") { (credentialState, error) in
      switch credentialState {
      case .authorized:
        // The Apple ID credential is valid
        print("Apple ID Credential is valid")
      case .revoked:
        // The Apple ID credential was revoked, sign the user out
        print("Apple ID Credential was revoked")
      case .notFound:
        // No Apple ID credential was found, show the sign-in UI
        print("No Apple ID Credential was found")
      default:
        break
      }
    }
    
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
