//
//  AddProfileView.swift
//  ImmigrantEntrepreneurCanada
//
//  Created by Jamila Ruzimetova on 5/24/24.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

struct EditProfileView: View {
    @State var entrepreneur: Entrepreneur
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isSaving = false
    @State private var bioText: String = ""
    @State private var selectedCountry: String?
    @State private var showCountryPicker = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = EditProfileViewModel()
    var onSave: (() -> Void)?
    
    init(entrepreneur: Entrepreneur, onSave: (() -> Void)? = nil) {
        self._entrepreneur = State(initialValue: entrepreneur)
        self._bioText = State(initialValue: entrepreneur.bioDescr ?? "")
        self._selectedCountry = State(initialValue: entrepreneur.countryOfOrigin)
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
                            
                        // Country of Origin picker
                        HStack {
                            Text("Country of Origin")
                            Spacer()
                            Button(action: {
                                showCountryPicker = true
                            }) {
                                HStack {
                                    Text(selectedCountry ?? "Select Country")
                                        .foregroundColor(selectedCountry == nil ? .gray : .primary)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
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
                
                // Display verification message if present
                if !viewModel.verificationMessage.isEmpty {
                    VStack {
                        Spacer()
                        Text(viewModel.verificationMessage)
                            .padding()
                            .background(Color.gray.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding()
                            .onAppear {
                                // Auto-dismiss after 3 seconds using Task instead of DispatchQueue
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                                    viewModel.verificationMessage = ""
                                }
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
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
                    entrepreneur.countryOfOrigin = selectedCountry
                    
                    print("Saving entrepreneur with bio: \(entrepreneur.bioDescr ?? "nil")")
                    print("Saving entrepreneur with country: \(entrepreneur.countryOfOrigin ?? "nil")")
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

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var verificationMessage: String = ""
    
    func saveProfile(entrepreneur: Entrepreneur, newImage: UIImage?) async throws {
        var updatedEntrepreneur = entrepreneur

        if let newImage = newImage {
            // Upload the new image first - this is safer as we only delete the old one if upload succeeds
            let imageUrl: String
            do {
                imageUrl = try await EntrepreneurManager.shared.uploadProfileImage(newImage, for: entrepreneur)
                print("Successfully uploaded new profile image: \(imageUrl)")
                
                // Set the new URL
                updatedEntrepreneur.profileUrl = imageUrl
                
                // Only try to delete old image if one exists and it's in Firebase Storage
                if let existingProfileUrl = entrepreneur.profileUrl {
                    // Handle the case where the user authenticated with Google but has no actual image
                    // or has a Google profile URL that might not exist as an actual image
                    if existingProfileUrl.isEmpty || 
                       !existingProfileUrl.contains("firebasestorage.googleapis.com") {
                        print("Previous profile image was not in Firebase Storage: \(existingProfileUrl)")
                        // No deletion needed - just update with the new image
                    } else {
                        // Only delete Firebase Storage URLs
                        Task.detached {
                            do {
                                print("Attempting to delete previous Firebase Storage image: \(existingProfileUrl)")
                                try await EntrepreneurManager.shared.deleteProfileImage(imageUrl: existingProfileUrl)
                                print("Successfully deleted old profile image in background")
                            } catch {
                                print("Non-critical error deleting old profile image: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    print("No previous profile image to delete - this is the user's first custom image")
                }
            } catch {
                print("Error uploading new image: \(error.localizedDescription)")
                // Keep the existing profile URL since upload failed
                throw error
            }
        }

        // Update the entrepreneur document
        try await EntrepreneurManager.shared.updateEntrepreneur(updatedEntrepreneur)
    }
    
    /// Verifies if an image exists in storage
    // This method is not marked with @MainActor so it will run on a background thread
    nonisolated private func verifyImageExists(imageUrl: String) async -> Bool {
        // Skip verification for invalid URLs
        guard !imageUrl.isEmpty, 
              imageUrl.hasPrefix("https://") || imageUrl.hasPrefix("http://"),
              let _ = URL(string: imageUrl) else {
            print("⚠️ Cannot verify invalid URL: \(imageUrl)")
            return false
        }
        
        // Special handling for Google profile images and other external URLs
        if imageUrl.contains("googleusercontent.com") || 
           !imageUrl.contains("firebasestorage.googleapis.com") {
            // Assume external URLs exist (we can't check them via Firebase Storage)
            print("ℹ️ External URL detected (not Firebase Storage): \(imageUrl)")
            return true
        }
        
        // Only try to verify Firebase Storage URLs
        do {
            // Using try? to prevent fatal errors
            let storageRef = Storage.storage().reference(forURL: imageUrl)
            _ = try await storageRef.getMetadata()
            print("✓ Verified image exists in storage: \(imageUrl)")
            return true
        } catch {
            print("✗ Image does not exist in storage: \(imageUrl)")
            print("  Error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Verifies that an image was deleted from storage
    // This method is not marked with @MainActor so it will run on a background thread
    nonisolated private func verifyImageDeleted(imageUrl: String, wasExisting: Bool) async {
        // Only meaningful if the image existed before
        guard wasExisting else {
            print("⚠️ Cannot verify deletion - image didn't exist before")
            return
        }
        
        // Skip verification for invalid URLs
        guard !imageUrl.isEmpty, 
              imageUrl.hasPrefix("https://") || imageUrl.hasPrefix("http://"),
              let _ = URL(string: imageUrl) else {
            print("⚠️ Cannot verify invalid URL: \(imageUrl)")
            await MainActor.run {
                self.verificationMessage = "Could not verify image deletion (invalid URL)"
            }
            return
        }
        
        // Handle external URLs like Google profile images
        if imageUrl.contains("googleusercontent.com") || 
           !imageUrl.contains("firebasestorage.googleapis.com") {
            print("ℹ️ External URL detected - no deletion verification needed")
            await MainActor.run {
                self.verificationMessage = "Profile updated successfully"
            }
            return
        }
        
        // Check if the image still exists but with error handling
        let stillExists = await verifyImageExists(imageUrl: imageUrl)
        
        // Update UI on main thread
        await MainActor.run {
            if stillExists {
                print("❌ DELETION VERIFICATION FAILED: Image still exists in storage: \(imageUrl)")
                self.verificationMessage = "Warning: Old image may not have been deleted"
            } else {
                print("✅ DELETION VERIFIED: Image was successfully deleted from storage")
                self.verificationMessage = "Profile updated successfully"
            }
        }
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

