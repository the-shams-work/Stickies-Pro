//
//  File.swift
//  Stickies Pro
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

struct VideoPickerButton: View {
    @Binding var selectedVideoURL: URL?
    @State private var showActionSheet = false
    @State private var showVideoPicker = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        Button("Select Video") { 
            showActionSheet = true 
        }
        .confirmationDialog("Select Video", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Camera") {
                selectedSourceType = .camera
                showVideoPicker = true
            }
            
            Button("Photo Library") {
                selectedSourceType = .photoLibrary
                showVideoPicker = true
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose how you want to add a video")
        }
        .sheet(isPresented: $showVideoPicker) {
            VideoPicker(videoURL: $selectedVideoURL, sourceType: selectedSourceType)
        }
    }
}
