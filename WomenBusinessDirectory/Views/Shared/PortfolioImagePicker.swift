import SwiftUI
import PhotosUI

struct PortfolioImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    let maxSelection: Int
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = maxSelection - images.count // Adjust limit based on current selection
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PortfolioImagePicker
        
        init(_ parent: PortfolioImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            if results.isEmpty {
                return
            }
            
            // If this is a replacement of all images (i.e., user is re-selecting portfolio),
            // clear the existing images first to completely replace them
            if results.count > 0 && parent.images.count + results.count > parent.maxSelection {
                // Clear existing images to make room for new ones
                parent.images.removeAll()
            }
            
            // Load each selected image
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                            return
                        }
                        
                        if let image = image as? UIImage, self.parent.images.count < self.parent.maxSelection {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}
