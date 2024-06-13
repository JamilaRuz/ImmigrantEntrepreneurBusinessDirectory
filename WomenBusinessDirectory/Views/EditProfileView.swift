//
//  AddProfileView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/24/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditProfileView: View {
  @Environment(\.dismiss) private var dismiss
  
  @State var entrepreneurFullName: String
  @State var bioDescription: String
  
  @State private var selectedImage: PhotosPickerItem?
  @State private var selectedImageData: Data?
  let entrepreneur: Entrepreneur
  
  init(entrepreneur: Entrepreneur) {
    self.entrepreneur = entrepreneur
    _entrepreneurFullName = State(initialValue: entrepreneur.fullName)
    _bioDescription = State(initialValue: entrepreneur.bioDescr ?? "")
  }
  
  enum sourceType {
    case camera
    case photoLibrary
  }
  
  var changed: Bool {
    entrepreneurFullName != entrepreneur.fullName || selectedImageData != entrepreneur.profileImage
  }
  
  
  var body: some View {
    VStack {
      // profile image photo picker
      VStack() {
        PhotosPicker(
          selection: $selectedImage,
          matching: .images,
          photoLibrary: .shared()
        ) {
          VStack {
            if let selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
              Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
            } else {
              Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .tint(.green4)
            }
          }
          .frame(width: 100, height: 100)
          .clipShape(Circle())
          .overlay(
            Circle()
              .stroke(Color.primary, lineWidth: 1)
          )
          .overlay(alignment: .bottomTrailing) {
            if selectedImage != nil {
              Button {
                selectedImage = nil
                selectedImageData = nil
                
              } label: {
                Image(systemName: "x.circle.fill")
                  .foregroundColor(.white)
                  .padding(5)
                  .background(Color.black.opacity(0.5))
                  .clipShape(Circle())
              }
            }
          }
        } // photos picker
        TextField("Enter your fullname", text: $entrepreneurFullName)
          .modifier(TextFieldStyle())
        
      } //vstack photo picker
      VStack {
        TextField("Bio", text: $bioDescription)
          .modifier(TextFieldStyle())
      } //vstack textfield
      Spacer()
    } //vstack
    .padding()
    .navigationBarTitle("Edit Profile")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarRole(.editor)
    .toolbar {
      if changed {
        Button {
          entrepreneur.fullName = entrepreneurFullName
          entrepreneur.profileImage = selectedImageData
          
          dismiss()
        } label: {
          Image(systemName: "pencil.circle.fill")
            .imageScale(.large)
        }
      }
    }
    .onAppear {
      selectedImageData = entrepreneur.profileImage
      entrepreneurFullName = entrepreneur.fullName
      bioDescription = entrepreneur.bioDescr ?? ""
    }
    .task(id: selectedImage) {
      if let data = try? await selectedImage?.loadTransferable(type: Data.self) {
        selectedImageData = data
      }
    }
  } //body
} //struct

struct TextFieldStyle: ViewModifier {
  func body(content: Content) -> some View {
        content
          .padding(10)
          .background(Color(.systemGray6))
          .cornerRadius(8)
          .shadow(radius: 3)
          .padding(.horizontal)
          .frame(width: 300, height: 40)
    }
}

#Preview {
  EditProfileView(entrepreneur: createStubEntrepreneurs()[0])
    .environment(\.modelContext, createPreviewModelContainer().mainContext)
}
