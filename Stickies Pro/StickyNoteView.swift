//
//  StickyNoteView.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import AVKit

struct StickyNoteView: View {
    let note: StickyNote
    let markAsDone: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false
    @State private var showActionSheet = false
    @State private var showFullText = false
    @State private var textLimit = 125
    @State private var showFullScreenImage = false
    @State private var showFullScreenVideo = false
    @State private var showAudioPlayer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(note.title)
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            if note.content.count > textLimit {
                VStack(alignment: .leading, spacing: 5) {
                    Text(showFullText ? note.content : String(note.content.prefix(textLimit)) + "...")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Spacer()
                        Button(action: { showFullText.toggle() }) {
                            Text(showFullText ? "See Less" : "See More")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
            } else {
                Text(note.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
            }

            // Only show dates if the note is time-bounded
            if !Calendar.current.isDate(note.startDate, inSameDayAs: Date()) || !Calendar.current.isDate(note.endDate, inSameDayAs: Date()) {
                Text("Start: \(formattedDate(note.startDate)) - End: \(formattedDate(note.endDate))")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 15) {
                if let image = note.attachment {
                    Button(action: {
                        showFullScreenImage = true
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .frame(width: 30, height: 25)
                                .foregroundColor(.white)
                            Text("Image")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .fullScreenCover(isPresented: $showFullScreenImage) {
                        ZoomableImageView(image: image)
                    }
                }

                if let videoURL = note.videoURL {
                    Button(action: {
                        showFullScreenVideo = true
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: "video.fill")
                                .resizable()
                                .frame(width: 30, height: 25)
                                .foregroundColor(.white)
                            Text("Video")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .fullScreenCover(isPresented: $showFullScreenVideo) {
                        ZoomableVideoView(videoURL: videoURL)
                    }
                }

                if let audioURL = note.audioURL {
                    Button(action: {
                        showAudioPlayer = true
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: "music.note")
                                .resizable()
                                .frame(width: 30, height: 25)
                                .foregroundColor(.white)
                            Text("Audio")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showAudioPlayer) {
                        AudioPlayerSheet(audioURL: audioURL)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
        .background(note.colorValue)
        .cornerRadius(12)
        .shadow(radius: 5)
        .onLongPressGesture {
            showActionSheet.toggle()
        }
        .actionSheet(isPresented: $showActionSheet) {
            if note.isDone {
                return ActionSheet(
                    title: Text("Choose an action for this note."),
                    buttons: [
                        .destructive(Text("Delete")) {
                            showDeleteConfirmation = true
                        },
                        .default(Text("Active")) {
                            markAsDone()
                        },
                        .cancel()
                    ]
                )
            } else {
                return ActionSheet(
                    title: Text("Choose an action for this note."),
                    buttons: [
                        .default(Text("Edit")) {
                            onEdit()
                        },
                        .destructive(Text("Delete")) {
                            showDeleteConfirmation = true
                        },
                        .default(Text("Archive")) {
                            markAsDone()
                        },
                        .cancel()
                    ]
                )
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Note"),
                message: Text("Are you sure you want to delete this note? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct AudioPlayerSheet: View {
    let audioURL: URL
    @Environment(\.dismiss) var dismiss
    @State private var audioPlayer: AVPlayer?
    @State private var isAudioPlaying = false
    @State private var audioProgress: Double = 0.0
    @State private var audioDuration: Double = 0.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "music.note")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.purple)
                
                Text("Audio Player")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(audioURL.lastPathComponent)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 20) {
                    Slider(value: $audioProgress, in: 0...audioDuration, onEditingChanged: { _ in
                        Task { @MainActor in
                            let targetTime = CMTime(seconds: audioProgress, preferredTimescale: 600)
                            audioPlayer?.seek(to: targetTime)
                        }
                    })
                    .padding(.horizontal)
                    
                    HStack {
                        Text(formatTime(audioProgress))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            Task { @MainActor in
                                if isAudioPlaying {
                                    audioPlayer?.pause()
                                } else {
                                    audioPlayer?.play()
                                }
                                isAudioPlaying.toggle()
                            }
                        }) {
                            Image(systemName: isAudioPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.purple)
                        }
                        
                        Spacer()
                        
                        Text(formatTime(audioDuration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Audio Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        audioPlayer?.pause()
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
            .onAppear {
                setupAudioPlayer()
            }
            .onDisappear {
                audioPlayer?.pause()
            }
        }
    }
    
    private func setupAudioPlayer() {
        audioPlayer = AVPlayer(url: audioURL)
        let asset = AVAsset(url: audioURL)
        
        Task {
            let duration = try? await asset.load(.duration)
            audioDuration = duration.map { CMTimeGetSeconds($0) } ?? 0.0
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if let currentTime = audioPlayer?.currentTime() {
                    audioProgress = CMTimeGetSeconds(currentTime)
                }
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
