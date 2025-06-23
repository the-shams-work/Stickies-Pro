//
//  ImagePicker.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct ImagePickerButton: View {
    @Binding var selectedImage: UIImage?
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        Button("Select Image") { 
            showActionSheet = true 
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Select Image"),
                message: Text("Choose how you want to add an image"),
                buttons: [
                    .default(Text("Camera")) {
                        selectedSourceType = .camera
                        showImagePicker = true
                    },
                    .default(Text("Photo Library")) {
                        selectedSourceType = .photoLibrary
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: selectedSourceType)
        }
    }
}
