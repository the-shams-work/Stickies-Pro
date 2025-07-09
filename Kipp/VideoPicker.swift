//
//  VideoPicker.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 17/02/25.
//

import SwiftUI
import AVKit
import UIKit

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    let sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Immersive Video Picker Coordinator
class ImmersiveVideoCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let onVideoPicked: (URL?) -> Void
    let onDismiss: () -> Void
    
    init(onVideoPicked: @escaping (URL?) -> Void, onDismiss: @escaping () -> Void) {
        self.onVideoPicked = onVideoPicked
        self.onDismiss = onDismiss
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let url = info[.mediaURL] as? URL
        onVideoPicked(url)
        picker.dismiss(animated: true, completion: onDismiss)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: onDismiss)
    }
}

struct VideoPickerButton: View {
    @Binding var selectedVideoURL: URL?
    @State private var showActionSheet = false
    @State private var showVideoPicker = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var coordinator: ImmersiveVideoCoordinator?
    
    var body: some View {
        Button("Add Video") {
            showActionSheet = true
        }
        .confirmationDialog("Select Video", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Camera") {
                selectedSourceType = .camera
                presentImmersiveCamera()
            }
            Button("Photo Library") {
                selectedSourceType = .photoLibrary
                showVideoPicker = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose how you want to add a video")
        }
        .sheet(isPresented: Binding(get: { showVideoPicker && selectedSourceType == .photoLibrary }, set: { if !$0 { showVideoPicker = false } })) {
            VideoPicker(videoURL: $selectedVideoURL, sourceType: .photoLibrary)
        }
    }
    
    private func presentImmersiveCamera() {
        guard let topVC = UIApplication.topViewController() else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        let newCoordinator = ImmersiveVideoCoordinator(
            onVideoPicked: { url in
                selectedVideoURL = url
            },
            onDismiss: {}
        )
        picker.delegate = newCoordinator
        coordinator = newCoordinator // retain
        topVC.present(picker, animated: true)
    }
}
