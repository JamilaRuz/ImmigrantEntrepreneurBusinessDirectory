import Foundation
import SwiftUI
import Alamofire
import AlamofireImage

/// A singleton class that handles image caching using Alamofire
class ImageCache {
    static let shared = ImageCache()
    
    private let imageCache = AutoPurgingImageCache(
        memoryCapacity: 100_000_000, // 100 MB
        preferredMemoryUsageAfterPurge: 60_000_000 // 60 MB
    )
    
    private let imageDownloader: ImageDownloader
    
    private init() {
        // Use the shared NetworkManager session configuration
        let configuration = NetworkManager.shared.session.sessionConfiguration
        
        // Create the image downloader with this configuration
        self.imageDownloader = ImageDownloader(
            configuration: configuration,
            downloadPrioritization: .fifo,
            maximumActiveDownloads: 4,
            imageCache: AutoPurgingImageCache()
        )
    }
    
    /// Loads an image from the given URL, using cache if available
    /// - Parameters:
    ///   - urlString: The URL string of the image
    ///   - completion: Completion handler with the UIImage result
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("🔴 Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        // Check if image is in cache
        if let cachedImage = imageCache.image(for: URLRequest(url: url)) {
            print("✅ Using cached image for: \(urlString.suffix(20))")
            completion(cachedImage)
            return
        }
        
        print("🔄 Downloading image from: \(urlString.suffix(20))")
        // Download image
        let urlRequest = URLRequest(url: url)
        imageDownloader.download(urlRequest) { [weak self] response in
            guard let self = self else { return }
            
            if case .success(let image) = response.result {
                // Store in cache
                print("✅ Downloaded and cached image for: \(urlString.suffix(20))")
                self.imageCache.add(image, for: urlRequest)
                completion(image)
            } else {
                print("❌ Failed to download image: \(urlString.suffix(20))")
                completion(nil)
            }
        }
    }
    
    /// Clears the image cache
    func clearCache() {
        print("🧹 Clearing image cache")
        imageCache.removeAllImages()
    }
    
    /// Returns cache statistics for debugging
    func getCacheStats() -> String {
        let memoryCapacity = Double(imageCache.memoryCapacity) / 1_000_000.0
        let currentMemoryUsage = Double(imageCache.memoryUsage) / 1_000_000.0
        return "Cache stats: \(currentMemoryUsage)MB used of \(memoryCapacity)MB capacity"
    }
}

// Define our own image phase enum to match SwiftUI's AsyncImagePhase
public enum CachedImagePhase {
    case empty
    case success(SwiftUI.Image)
    case failure(Error)
    
    struct ImageLoadingError: Error, LocalizedError {
        let message: String
        
        var errorDescription: String? {
            return message
        }
    }
}

/// A SwiftUI Image view that loads images with caching
struct CachedAsyncImage<Content: View>: View where Content: View {
    @State private var phase: CachedImagePhase = .empty
    
    private let url: URL?
    private let scale: CGFloat
    private let content: (CachedImagePhase) -> Content
    
    init(url: URL?, scale: CGFloat = 1.0, @ViewBuilder content: @escaping (CachedImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .onAppear(perform: loadImage)
            .onChange(of: url) { _ in loadImage() }
    }
    
    private func loadImage() {
        guard let url = url?.absoluteString else {
            phase = .empty
            return
        }
        
        ImageCache.shared.loadImage(from: url) { uiImage in
            if let uiImage = uiImage {
                phase = .success(SwiftUI.Image(uiImage: uiImage))
            } else {
                phase = .failure(CachedImagePhase.ImageLoadingError(message: "Failed to load image"))
            }
        }
    }
} 