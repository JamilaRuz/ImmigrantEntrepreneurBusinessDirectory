import SwiftUI

struct ProfileCompletionBanner: View {
    let message: String
    var action: (() -> Void)? = nil
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if action != nil {
                    Button(action: {
                        action?()
                    }) {
                        Text("Complete")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? Color(.darkGray) : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(colorScheme == .dark ? Color(.lightGray) : Color.white.opacity(0.3))
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(colorScheme == .dark ? Color(UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)) : Color("pink1"))
            
            Rectangle()
                .fill(colorScheme == .dark ? Color(UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 0.8)) : Color("pink1").opacity(0.8))
                .frame(height: 1)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct ProfileCompletionBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProfileCompletionBanner(message: "Complete your profile to showcase your business") {
                print("Action tapped")
            }
            
            Spacer()
        }
        .preferredColorScheme(.dark)
    }
} 