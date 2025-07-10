//
//  ImagePicker.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import UIKit

// Helper to get top UIViewController
extension UIApplication {
    static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

// Immersive Camera Picker Coordinator
class ImmersiveCameraCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let onImagePicked: (UIImage?) -> Void
    let onDismiss: () -> Void
    
    init(onImagePicked: @escaping (UIImage?) -> Void, onDismiss: @escaping () -> Void) {
        self.onImagePicked = onImagePicked
        self.onDismiss = onDismiss
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        onImagePicked(image)
        picker.dismiss(animated: true, completion: onDismiss)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: onDismiss)
    }
}

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
    @State private var coordinator: ImmersiveCameraCoordinator?
    
    var body: some View {
        Button("Add Image") { 
            showActionSheet = true 
        }
        .confirmationDialog("Select Image", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Camera") {
                selectedSourceType = .camera
                presentImmersiveCamera()
            }
            Button("Photo Library") {
                selectedSourceType = .photoLibrary
                showImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose how you want to add an image")
        }
        .sheet(isPresented: Binding(get: { showImagePicker && selectedSourceType == .photoLibrary }, set: { if !$0 { showImagePicker = false } })) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
    }
    
    private func presentImmersiveCamera() {
        guard let topVC = UIApplication.topViewController() else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        let newCoordinator = ImmersiveCameraCoordinator(
            onImagePicked: { image in
                selectedImage = image
            },
            onDismiss: {}
        )
        picker.delegate = newCoordinator
        coordinator = newCoordinator
        topVC.present(picker, animated: true)
    }
}
