//
//  ImagePicker.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import UIKit

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

struct BackgroundImagePickerButton: View {
    @Binding var selectedBackgroundImage: UIImage?
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var coordinator: ImmersiveCameraCoordinator?
    @State private var showRemoveBackgroundAlert = false
    
    var body: some View {
        HStack {
            Text("Background Image")
            Spacer()
            if let image = selectedBackgroundImage {
                ZStack(alignment: .topTrailing) {
                    Button(action: { showActionSheet = true }) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    Button(action: { showRemoveBackgroundAlert = true }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.7)))
                            .frame(width: 20, height: 20)
                    }
                    .offset(x: 8, y: -8)
                }
            } else {
                Button(action: { showActionSheet = true }) {
                    ZStack {
                        Circle()
                            .stroke(Color.purple, lineWidth: 2)
                            .background(Circle().fill(Color.white))
                            .frame(width: 26, height: 26)
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.purple)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .contentShape(Rectangle())
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
            Text("Choose how you want to add a background image")
        }
        .sheet(isPresented: Binding(get: { showImagePicker && selectedSourceType == .photoLibrary }, set: { if !$0 { showImagePicker = false } })) {
            ImagePicker(image: $selectedBackgroundImage, sourceType: .photoLibrary)
        }
        .alert("Remove Background Image?", isPresented: $showRemoveBackgroundAlert) {
            Button("Remove", role: .destructive) { selectedBackgroundImage = nil }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove the background image from your note.")
        }
    }
    
    private func presentImmersiveCamera() {
        guard let topVC = UIApplication.topViewController() else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        let newCoordinator = ImmersiveCameraCoordinator(
            onImagePicked: { image in
                selectedBackgroundImage = image
            },
            onDismiss: {}
        )
        picker.delegate = newCoordinator
        coordinator = newCoordinator
        topVC.present(picker, animated: true)
    }
}
