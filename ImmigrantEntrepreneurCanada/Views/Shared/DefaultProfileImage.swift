import SwiftUI

struct DefaultProfileImage: View {
    let size: CGFloat
    let opacity: Double
    
    init(size: CGFloat = 50, opacity: Double = 0.3) {
        self.size = size
        self.opacity = opacity
    }
    
    var body: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(.gray.opacity(opacity))
    }
}

#Preview {
    VStack(spacing: 20) {
        DefaultProfileImage(size: 100)
        DefaultProfileImage(size: 50)
        DefaultProfileImage(size: 30)
    }
} 