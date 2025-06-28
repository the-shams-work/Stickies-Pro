//
//  MediaPicker.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import UIKit
import AVKit
import AVFoundation

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
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.mediaURL = urls.first
        }
    }
}

struct AudioPickerButton: View {
    @Binding var selectedAudioURL: URL?
    @State private var showActionSheet = false
    @State private var showAudioPicker = false
    @State private var showAudioRecorder = false
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingURL: URL?
    
    var body: some View {
        Button("Select Audio") { 
            showActionSheet = true 
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Select Audio"),
                message: Text("Choose how you want to add audio"),
                buttons: [
                    .default(Text("Record Audio")) {
                        requestMicrophonePermission()
                    },
                    .default(Text("Choose File")) {
                        showAudioPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showAudioPicker) {
            MediaPicker(mediaType: .audio, mediaURL: $selectedAudioURL)
        }
        .sheet(isPresented: $showAudioRecorder) {
            AudioRecorderView(
                isRecording: $isRecording,
                audioRecorder: $audioRecorder,
                recordingURL: $recordingURL,
                selectedAudioURL: $selectedAudioURL
            )
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    showAudioRecorder = true
                } else {
                    // Handle permission denied
                    print("Microphone permission denied")
                }
            }
        }
    }
}

struct AudioRecorderView: View {
    @Binding var isRecording: Bool
    @Binding var audioRecorder: AVAudioRecorder?
    @Binding var recordingURL: URL?
    @Binding var selectedAudioURL: URL?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Audio Recorder")
                .font(.title)
                .fontWeight(.bold)
            
            Image(systemName: isRecording ? "mic.fill" : "mic")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(isRecording ? .red : .purple)
                .scaleEffect(isRecording ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)
            
            Text(isRecording ? "Recording..." : "Tap to start recording")
                .font(.headline)
                .foregroundColor(isRecording ? .red : .primary)
            
            HStack(spacing: 40) {
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(isRecording ? .red : .green)
                }
                
                if !isRecording && recordingURL != nil {
                    Button(action: {
                        selectedAudioURL = recordingURL
                        dismiss()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.purple)
        }
        .padding()
        .onAppear {
            setupAudioSession()
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        recordingURL = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = nil
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
}
