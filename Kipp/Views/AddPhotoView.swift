//
//  AddPhotoView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import PhotosUI

struct AddPhotoView: View {
    @Binding var selectedImage: UIImage?

    @State private var showCameraPicker = false
    @State private var showLibraryPicker = false
    @State private var showFilePicker = false
    @State private var cameraCoordinator: ImmersiveCameraCoordinator?

    // MARK: - Recent Photos
    @State private var recentPhotos: [UIImage] = []

    var body: some View {
        Form {
            // MARK: Source Section
            Section {
                Button {
                    openCamera()
                } label: {
                    AttachmentSourceRow(
                        icon: "camera.fill",
                        iconColor: .blue,
                        title: String(localized: "addphoto.source.camera"),
                        subtitle: String(localized: "addphoto.source.camera.subtitle")
                    )
                }

                Button {
                    showLibraryPicker = true
                } label: {
                    AttachmentSourceRow(
                        icon: "photo.on.rectangle",
                        iconColor: .green,
                        title: String(localized: "addphoto.source.library"),
                        subtitle: String(localized: "addphoto.source.library.subtitle")
                    )
                }

                Button {
                    showFilePicker = true
                } label: {
                    AttachmentSourceRow(
                        icon: "folder.fill",
                        iconColor: .orange,
                        title: String(localized: "addphoto.source.browse"),
                        subtitle: String(localized: "addphoto.source.browse.subtitle")
                    )
                }
            } header: {
                Text(String(localized: "addaudio.section.source"))
            }

            // MARK: Selected Photo Preview
            if let image = selectedImage {
                Section {
                    VStack(spacing: 12) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )

                        Button(role: .destructive) {
                            selectedImage = nil
                        } label: {
                            Label(String(localized: "addphoto.selected.remove"), systemImage: "trash")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                } header: {
                    Text(String(localized: "addphoto.section.selected"))
                }
            }

            // MARK: Recent Photos
            if !recentPhotos.isEmpty {
                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 8) {
                        ForEach(Array(recentPhotos.prefix(4).enumerated()), id: \.offset) { _, photo in
                            Button {
                                selectedImage = photo
                            } label: {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(Color(.separator), lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(String(localized: "addphoto.section.recent"))
                }
            }
        }
        .navigationTitle(String(localized: "addphoto.title"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLibraryPicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentImagePicker(selectedImage: $selectedImage)
        }
        .onAppear {
            loadRecentPhotos()
        }
    }

    // MARK: - Camera
    private func openCamera() {
        guard let topVC = UIApplication.topViewController() else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        let coordinator = ImmersiveCameraCoordinator(
            onImagePicked: { image in
                selectedImage = image
            },
            onDismiss: {}
        )
        picker.delegate = coordinator
        cameraCoordinator = coordinator
        topVC.present(picker, animated: true)
    }

    // MARK: - Recent Photos (from PHPhotoLibrary)
    private func loadRecentPhotos() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else { return }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 4

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let manager = PHImageManager.default()
        let targetSize = CGSize(width: 300, height: 300)
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic

        var images: [UIImage] = []
        let group = DispatchGroup()

        assets.enumerateObjects { asset, _, _ in
            group.enter()
            manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    images.append(image)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            recentPhotos = images
        }
    }
}

// MARK: - Document Image Picker

struct DocumentImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentImagePicker

        init(_ parent: DocumentImagePicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            var didStart = false
            if url.startAccessingSecurityScopedResource() { didStart = true }
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }

            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                parent.selectedImage = image
            }
        }
    }
}
