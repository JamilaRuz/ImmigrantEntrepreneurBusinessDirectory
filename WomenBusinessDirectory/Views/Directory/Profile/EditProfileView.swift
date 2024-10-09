//
//  AddProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/24/24.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @State var entrepreneur: Entrepreneur
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = EditProfileViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    profileImageView
                    chooseImageButton
                }
                
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $entrepreneur.fullName.bound)
                    Text(entrepreneur.email ?? "No email provided")
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Entrepreneur's Story")) {
                    TextEditor(text: $entrepreneur.bioDescr.bound)
                        .frame(height: 200)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(trailing: saveButton)
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private var profileImageView: some View {
        Group {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else if let profileUrl = entrepreneur.profileUrl, let url = URL(string: profileUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var chooseImageButton: some View {
        Button("Choose new picture") {
            isImagePickerPresented = true
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            Task {
                do {
                    try await viewModel.saveProfile(entrepreneur: entrepreneur, newImage: selectedImage)
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print("Failed to save profile: \(error)")
                }
            }
        }
    }
}

class EditProfileViewModel: ObservableObject {
    func saveProfile(entrepreneur: Entrepreneur, newImage: UIImage?) async throws {
        var updatedEntrepreneur = entrepreneur

        if let newImage = newImage {
            let imageUrl = try await EntrepreneurManager.shared.uploadProfileImage(newImage, for: entrepreneur)
            updatedEntrepreneur.profileUrl = imageUrl
        }

        try await EntrepreneurManager.shared.updateEntrepreneur(updatedEntrepreneur)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
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
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

extension Optional where Wrapped == String {
    var bound: String {
        get { return self ?? "" }
        set { self = newValue.isEmpty ? nil : newValue }
    }
}
