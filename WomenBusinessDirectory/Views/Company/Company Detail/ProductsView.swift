//
//  ProductsView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import SwiftUI

struct ProductsView: View {
    let services: [String]
    let portfolioImages: [PortfolioImage]
    @Environment(\.colorScheme) private var colorScheme
    
    // Convenience initializer that converts string URLs to PortfolioImage objects
    init(services: [String], portfolioImages: [String]) {
        self.services = services
        self.portfolioImages = portfolioImages.map { PortfolioImage(url: $0) }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5)
    ]
    
    @State private var selectedImage: PortfolioImage?
    @State private var hasAppeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Services we provide")
                .font(.headline)
                .padding(.top, 10)
            
            if services.isEmpty {
                Text("No services available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(colorScheme == .dark ? Color(UIColor.darkGray).opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                ForEach(Array(services.enumerated()), id: \.offset) { index, service in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .padding(.top, 7)
                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                        Text(service)
                            .foregroundColor(colorScheme == .dark ? .gray.opacity(0.9) : .gray)
                    }
                }
            }
            
            // Always show the Business portfolio section
            Text("Business portfolio")
                .font(.headline)
                .padding(.top, 10)
            
            if portfolioImages.isEmpty {
                // Show a consistent "no images" message
                Text("No portfolio images available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(colorScheme == .dark ? Color(UIColor.darkGray).opacity(0.3) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(portfolioImages) { image in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.clear)
                            
                            CachedAsyncImage(url: URL(string: image.url)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : .gray)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            selectedImage = image
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(item: $selectedImage) { image in
            ZoomableImageView(imageURL: image.url, colorScheme: colorScheme) {
                selectedImage = nil
            }
        }
        .onAppear {
            if !hasAppeared {
                print("ProductsView appeared for the first time")
                hasAppeared = true
            } else {
                print("ProductsView reappeared - not triggering reload")
            }
        }
    }
}

struct ZoomableImageView: View {
    let imageURL: String
    let colorScheme: ColorScheme
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                (colorScheme == .dark ? Color.black : Color.white)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    CachedAsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            scale = min(max(scale * delta, 1.0), 5.0)
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                            if scale < 1.0 {
                                                withAnimation {
                                                    scale = 1.0
                                                }
                                            }
                                            if scale > 5.0 {
                                                scale = 5.0
                                            }
                                        }
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if scale > 1.0 {
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                            if scale <= 1.0 {
                                                withAnimation {
                                                    offset = .zero
                                                    lastOffset = .zero
                                                }
                                            }
                                        }
                                )
                                .onTapGesture(count: 2) {
                                    withAnimation {
                                        if scale > 1.0 {
                                            scale = 1.0
                                            offset = .zero
                                            lastOffset = .zero
                                        } else {
                                            scale = 2.0
                                        }
                                    }
                                }
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : .gray)
                        }
                    }
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height * 0.9)
                    
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Replace String extension with a proper model type
struct PortfolioImage: Identifiable, Hashable {
    let url: String
    var id: String { url }
    
    // Required for Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PortfolioImage, rhs: PortfolioImage) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    ProductsView(services: ["Web Design", "Mobile App Development"], portfolioImages: ["https://example.com/image1.jpg", "https://example.com/image2.jpg"])
}
