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
    @State private var isSaving = false
    @State private var bioText: String = ""
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = EditProfileViewModel()
    var onSave: (() -> Void)?
    
    init(entrepreneur: Entrepreneur, onSave: (() -> Void)? = nil) {
        self._entrepreneur = State(initialValue: entrepreneur)
        self._bioText = State(initialValue: entrepreneur.bioDescr ?? "")
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ZStack {
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
                    
                    Section(header: Text("Tell us about yourself")) {
                        TextEditor(text: $bioText)
                            .frame(height: 200)
                            .onChange(of: bioText) { oldValue, newValue in
                                print("Bio changed from: \(oldValue) to: \(newValue)")
                            }
                    }
                }
                .navigationTitle("Edit Profile")
                .navigationBarItems(trailing: saveButton)
                
                if isSaving {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
        .onAppear {
            print("EditProfileView appeared with bio: \(entrepreneur.bioDescr ?? "nil")")
            print("bioText initialized as: \(bioText)")
        }
    }
    
    private var profileImageView: some View {
        Group {
            VStack(alignment: .center) {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else if let profileUrl = entrepreneur.profileUrl, let url = URL(string: profileUrl) {
                    CachedAsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            DefaultProfileImage(size: 120)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        case .failure:
                            DefaultProfileImage(size: 120)
                        }
                    }
                } else {
                    DefaultProfileImage(size: 200)
                }
            }
            .frame(maxWidth: .infinity)
        } //Group
    }
    
    private var chooseImageButton: some View {
        Button(action: {
            isImagePickerPresented = true
        }) {
            Text("Choose Image")
                .foregroundColor(colorScheme == .dark ? .white : .pink1)
                .padding()
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? Color(UIColor.darkGray) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.pink1, lineWidth: 2)
                )
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            Task {
                isSaving = true
                do {
                    entrepreneur.bioDescr = bioText.isEmpty ? nil : bioText
                    
                    print("Saving entrepreneur with bio: \(entrepreneur.bioDescr ?? "nil")")
                    try await viewModel.saveProfile(entrepreneur: entrepreneur, newImage: selectedImage)
                    onSave?()
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print("Failed to save profile: \(error)")
                }
                isSaving = false
            }
        }
        .foregroundColor(colorScheme == .dark ? .white : .blue)
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

#Preview {
  EditProfileView(entrepreneur: Entrepreneur(entrepId: "id", fullName: "Name", profileUrl: nil, email: "email", bioDescr: "bio", companyIds: []))
}

