//
//  AddAudioView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import AVFoundation

struct AddAudioView: View {
    @Binding var selectedAudioURL: URL?

    @State private var showAudioRecorder = false
    @State private var showAudioFilePicker = false
    @State private var showBrowseFiles = false
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingURL: URL?

    var body: some View {
        Form {
            // MARK: Source Section
            Section {
                Button {
                    requestMicrophonePermission()
                } label: {
                    AttachmentSourceRow(
                        icon: "mic.fill",
                        iconColor: .red,
                        title: String(localized: "addaudio.source.record"),
                        subtitle: String(localized: "addaudio.source.record.subtitle")
                    )
                }

                Button {
                    showAudioFilePicker = true
                } label: {
                    AttachmentSourceRow(
                        icon: "music.note.list",
                        iconColor: .purple,
                        title: String(localized: "addaudio.source.audiofiles"),
                        subtitle: String(localized: "addaudio.source.audiofiles.subtitle")
                    )
                }

                Button {
                    showBrowseFiles = true
                } label: {
                    AttachmentSourceRow(
                        icon: "folder.fill",
                        iconColor: .orange,
                        title: String(localized: "addaudio.source.browse"),
                        subtitle: String(localized: "addaudio.source.browse.subtitle")
                    )
                }
            } header: {
                Text(String(localized: "addaudio.section.source"))
            }

            // MARK: Selected Audio Preview
            if let audioURL = selectedAudioURL {
                Section {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.purple)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(audioURL.lastPathComponent)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Text(String(localized: "addaudio.selected.audiofile"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)

                        Button(role: .destructive) {
                            selectedAudioURL = nil
                        } label: {
                            Label(String(localized: "addaudio.selected.remove"), systemImage: "trash")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                } header: {
                    Text(String(localized: "addaudio.section.selected"))
                }
            }
        }
        .navigationTitle(String(localized: "addaudio.title"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAudioRecorder) {
            AudioRecorderView(
                isRecording: $isRecording,
                audioRecorder: $audioRecorder,
                recordingURL: $recordingURL,
                selectedAudioURL: $selectedAudioURL
            )
        }
        .sheet(isPresented: $showAudioFilePicker) {
            MediaPicker(mediaType: .audio, mediaURL: $selectedAudioURL)
        }
        .sheet(isPresented: $showBrowseFiles) {
            DocumentAudioPicker(selectedAudioURL: $selectedAudioURL)
                .id(UUID()) // Force recreation
        }
    }

    // MARK: - Microphone Permission
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    showAudioRecorder = true
                }
            }
        }
    }
}

// MARK: - Document Audio Picker

struct DocumentAudioPicker: UIViewControllerRepresentable {
    @Binding var selectedAudioURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio, .mp3, .mpeg4Audio, .wav, .aiff])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentAudioPicker

        init(_ parent: DocumentAudioPicker) {
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
                parent.selectedAudioURL = destinationURL
            } catch {
                print("Failed to copy audio file: \(error)")
            }
        }
    }
}
