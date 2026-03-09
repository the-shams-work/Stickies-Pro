//
//  AddVideoView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import AVKit
import Photos

struct AddVideoView: View {
    @Binding var selectedVideoURL: URL?

    @State private var showLibraryPicker = false
    @State private var showFilePicker = false
    @State private var videoCoordinator: ImmersiveVideoCoordinator?

    // MARK: - Recent Videos
    @State private var recentVideoThumbnails: [(image: UIImage, asset: PHAsset)] = []

    var body: some View {
        Form {
            // MARK: Source Section
            Section {
                Button {
                    openVideoCamera()
                } label: {
                    AttachmentSourceRow(
                        icon: "video.fill",
                        iconColor: .purple,
                        title: String(localized: "addvideo.source.record"),
                        subtitle: String(localized: "addvideo.source.record.subtitle")
                    )
                }

                Button {
                    showLibraryPicker = true
                } label: {
                    AttachmentSourceRow(
                        icon: "photo.on.rectangle",
                        iconColor: .green,
                        title: String(localized: "addvideo.source.library"),
                        subtitle: String(localized: "addvideo.source.library.subtitle")
                    )
                }

                Button {
                    showFilePicker = true
                } label: {
                    AttachmentSourceRow(
                        icon: "folder.fill",
                        iconColor: .orange,
                        title: String(localized: "addvideo.source.browse"),
                        subtitle: String(localized: "addvideo.source.browse.subtitle")
                    )
                }
            } header: {
                Text(String(localized: "addaudio.section.source"))
            }

            // MARK: Selected Video Preview
            if let videoURL = selectedVideoURL {
                Section {
                    VStack(spacing: 12) {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        HStack {
                            Image(systemName: "film")
                                .foregroundColor(.secondary)
                            Text(videoURL.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Button(role: .destructive) {
                            selectedVideoURL = nil
                        } label: {
                            Label(String(localized: "addvideo.selected.remove"), systemImage: "trash")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                } header: {
                    Text(String(localized: "addvideo.section.selected"))
                }
            }

            // MARK: Recent Videos
            if !recentVideoThumbnails.isEmpty {
                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 8) {
                        ForEach(Array(recentVideoThumbnails.prefix(4).enumerated()), id: \.offset) { _, item in
                            Button {
                                loadVideoFromAsset(item.asset)
                            } label: {
                                ZStack(alignment: .bottomTrailing) {
                                    Image(uiImage: item.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(Color(.separator), lineWidth: 0.5)
                                        )

                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white, .black.opacity(0.5))
                                        .padding(6)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(String(localized: "addvideo.section.recent"))
                }
            }
        }
        .navigationTitle(String(localized: "addvideo.title"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLibraryPicker) {
            VideoPicker(videoURL: $selectedVideoURL, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentVideoPicker(selectedVideoURL: $selectedVideoURL)
        }
        .onAppear {
            loadRecentVideos()
        }
    }

    // MARK: - Camera
    private func openVideoCamera() {
        guard let topVC = UIApplication.topViewController() else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        let coordinator = ImmersiveVideoCoordinator(
            onVideoPicked: { url in
                selectedVideoURL = url
            },
            onDismiss: {}
        )
        picker.delegate = coordinator
        videoCoordinator = coordinator
        topVC.present(picker, animated: true)
    }

    // MARK: - Load video from PHAsset
    private func loadVideoFromAsset(_ asset: PHAsset) {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat

        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            guard let urlAsset = avAsset as? AVURLAsset else { return }
            let sourceURL = urlAsset.url
            let fileManager = FileManager.default
            let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documents.appendingPathComponent(sourceURL.lastPathComponent)

            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
                DispatchQueue.main.async {
                    selectedVideoURL = destinationURL
                }
            } catch {
                print("Failed to copy video: \(error)")
            }
        }
    }

    // MARK: - Recent Videos (from PHPhotoLibrary)
    private func loadRecentVideos() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else { return }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 4

        let assets = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        let manager = PHImageManager.default()
        let targetSize = CGSize(width: 300, height: 300)
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic

        var items: [(image: UIImage, asset: PHAsset)] = []
        let group = DispatchGroup()

        assets.enumerateObjects { asset, _, _ in
            group.enter()
            manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    items.append((image: image, asset: asset))
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            recentVideoThumbnails = items
        }
    }
}

// MARK: - Document Video Picker

struct DocumentVideoPicker: UIViewControllerRepresentable {
    @Binding var selectedVideoURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.movie, .video, .mpeg4Movie, .quickTimeMovie])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentVideoPicker

        init(_ parent: DocumentVideoPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            var didStart = false
            if url.startAccessingSecurityScopedResource() { didStart = true }
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }

            let fileManager = FileManager.default
            let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documents.appendingPathComponent(url.lastPathComponent)

            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: url, to: destinationURL)
                parent.selectedVideoURL = destinationURL
            } catch {
                print("Failed to copy video file: \(error)")
            }
        }
    }
}
