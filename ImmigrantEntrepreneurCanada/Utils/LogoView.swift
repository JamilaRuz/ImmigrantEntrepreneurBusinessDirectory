import SwiftUI

struct LogoView: View {
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat = 10
    
    init(width: CGFloat = 100, height: CGFloat = 100, cornerRadius: CGFloat = 10) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Image("main_logo")
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.gray.opacity(0.2), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 20) {
        LogoView(width: 150, height: 150)
        LogoView(width: 100, height: 100)
        LogoView(width: 50, height: 50, cornerRadius: 5)
    }
    .padding()
} 