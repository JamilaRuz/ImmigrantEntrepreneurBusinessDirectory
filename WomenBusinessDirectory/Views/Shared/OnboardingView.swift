import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome",
            description: "Discover and connect with immigrant entrepreneurs from around the world. Support diverse businesses and be part of a growing community.",
            imageName: "globe",
            accentColor: .purple1
        ),
        OnboardingPage(
            title: "Find Businesses",
            description: "Browse through various categories, search by location, or discover featured businesses in your area.",
            imageName: "magnifyingglass",
            accentColor: .blue
        ),
        OnboardingPage(
            title: "Connect & Support",
            description: "Follow your favorite businesses, leave reviews, and directly message business owners through the app.",
            imageName: "message.and.waveform",
            accentColor: .green
        ),
        OnboardingPage(
            title: "Join Our Community",
            description: "Create an account to unlock all features and become part of our growing community of entrepreneurs.",
            imageName: "person.2.wave.2",
            accentColor: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page control and buttons
                VStack(spacing: 20) {
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? pages[index].accentColor : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Next/Get Started button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            // Save that user has seen onboarding
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenOnboarding)
                            showOnboarding = false
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(pages[currentPage].accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let accentColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // System image with circle background
            Image(systemName: page.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(page.accentColor)
                .padding()
                .background(
                    Circle()
                        .fill(page.accentColor.opacity(0.1))
                        .frame(width: 200, height: 200)
                )
            
            VStack(spacing: 8) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(page.accentColor)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
} 
