//
//  ImmigrantEntrepreneurCanadaApp.swift
//  ImmigrantEntrepreneurCanada
//
//  Created by Jamila Ruzimetova on 4/12/24.
//

import SwiftUI
import Firebase
import AuthenticationServices
import Alamofire
import AlamofireImage
import GoogleSignIn
import FirebaseCore
import FirebaseCrashlytics

// Create a shared session that can be accessed throughout the app
class NetworkManager {
    static let shared = NetworkManager()
    
    let session: Session
    
    private init() {
        // Configure Alamofire for image caching
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // 30 seconds timeout
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        // Set up a custom cache configuration
        URLCache.shared = URLCache(
            memoryCapacity: 100_000_000, // 100 MB memory cache
            diskCapacity: 500_000_000,   // 500 MB disk cache
            diskPath: nil
        )
        
        configuration.urlCache = URLCache.shared
        
        // Create the session with standard Alamofire (not AlamofireDynamic)
        self.session = Session(configuration: configuration)
        
        // Print session info for debugging
        print("Alamofire Session initialized with configuration: \(configuration)")
    }
}

@main
struct ImmigrantEntrepreneurCanadaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage(UserDefaultsKeys.hasSeenOnboarding) private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                SplashScreen()
                    .environment(\.companyManager, RealCompanyManager.shared)
                    .onAppear {
                        // Show onboarding only if user hasn't seen it before
                        if !hasSeenOnboarding {
                            showOnboarding = true
                        }
                    }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(showOnboarding: $showOnboarding)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    // Initialize NetworkManager to set up caching
    print("Setting up image caching with Alamofire...")
    _ = NetworkManager.shared
    print("URLCache configured with \(URLCache.shared.memoryCapacity / 1_000_000) MB memory capacity")
    
    // Configure Crashlytics
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    
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
  
  // Handle URL schemes for authentication services
  func application(_ app: UIApplication,
                  open url: URL,
                  options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    // Handle Google Sign-in callback
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    
    // If not handled by Google Sign-In, could handle other URL schemes here
    
    return false
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
