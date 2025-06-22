//
//  MediaPicker.swift
//  Stickies
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import UIKit
import AVKit

struct MediaPicker: UIViewControllerRepresentable {
    enum MediaType {
        case video
        case audio
    }

    var mediaType: MediaType
    @Binding var mediaURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        switch mediaType {
        case .video:
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.mediaTypes = ["public.movie"]
            return picker
        case .audio:
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
            picker.delegate = context.coordinator
            return picker
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate {
        let parent: MediaPicker

        init(_ parent: MediaPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.mediaURL = url
            }
            picker.dismiss(animated: true)
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.mediaURL = urls.first
        }
    }
}
