//
//  ProductsView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import SwiftUI

struct ProductsView: View {
    let services: [String]
    let portfolioImages: [String]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var selectedImage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Services we provide")
                    .font(.headline)
                    .padding(.top, 15)
                
                ForEach(services, id: \.self) { service in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .padding(.top, 7)
                        Text(service)
                            .foregroundColor(.gray)
                    }
                }
                
                Text("Business portfolio")
                    .font(.headline)
                    .padding(.top, 10)
                
                LazyVGrid(columns: columns, spacing: 15) {
                    if portfolioImages.isEmpty {
                        // Show 3 placeholder rectangles when no images
                        ForEach(0..<3) { _ in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                Text("No image")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        ForEach(portfolioImages, id: \.self) { imageUrl in
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.yellow)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                selectedImage = imageUrl
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .sheet(item: $selectedImage) { imageUrl in
            ZoomableScrollView {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
        
        let hostedView = UIHostingController(rootView: content)
        hostedView.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostedView.view)
        
        NSLayoutConstraint.activate([
            hostedView.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            hostedView.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            hostedView.view.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            hostedView.view.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
        
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(hostingController: UIHostingController(rootView: content))
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>

        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

#Preview {
    ProductsView(services: ["Web Design", "Mobile App Development"], portfolioImages: ["https://example.com/image1.jpg", "https://example.com/image2.jpg"])
}
