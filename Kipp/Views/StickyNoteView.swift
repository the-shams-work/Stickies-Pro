//
//  StickyNoteView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import AVKit

struct StickyNoteView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let note: StickyNote
    let markAsDone: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    var isSelecting: Bool = false
    var isSelected: Bool = false

    @State private var showDeleteConfirmation = false
    @State private var showFullText = false
    @State private var textLimit = 125
    @State private var showFullScreenImage = false
    @State private var showFullScreenVideo = false
    @State private var showAudioPlayer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if isSelecting {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? themeManager.theme.color : .secondary)
                        .font(.title2)
                        .transition(.scale)
                }
                Text(note.title)
                    .font(.title3.bold())
                    .foregroundColor(note.colorValue.isWhite ? .black : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            let needsExpandButton = note.content.count > textLimit || note.content.contains("\n")
            if needsExpandButton {
                VStack(alignment: .leading, spacing: 5) {
                    Text(showFullText ? note.content : String(note.content.prefix(textLimit)) + (showFullText ? "" : "..."))
                        .font(.body)
                        .foregroundColor(note.colorValue.isWhite ? .black : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(showFullText ? nil : 3)

                    HStack {
                        Spacer()
                        Button(action: { showFullText.toggle() }) {
                            Image(systemName: showFullText ? "chevron.up" : "chevron.down")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(note.colorValue.isWhite ? .black : .white)
                                .padding(6)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                Text(note.content)
                    .font(.body)
                    .foregroundColor(note.colorValue.isWhite ? .black : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(3)
            }

            if !Calendar.current.isDate(note.startDate, inSameDayAs: note.endDate) {
                Text(String(format: String(localized: "stickynote.start_end"), formattedDate(note.startDate), formattedDate(note.endDate)))
                    .font(.footnote)
                    .foregroundColor(note.colorValue.isWhite ? Color.black.opacity(0.8) : Color.white.opacity(0.8))
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
                                .foregroundColor(note.colorValue.isWhite ? .black : .white)
                            Text("addnote.attachments.image.label")
                                .font(.caption)
                                .foregroundColor(note.colorValue.isWhite ? .black : .white)
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
                                .foregroundColor(note.colorValue.isWhite ? .black : .white)
                            Text("addnote.attachments.video.label")
                                .font(.caption)
                                .foregroundColor(note.colorValue.isWhite ? .black : .white)
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
                                .foregroundColor(note.colorValue.isWhite ? .black : .white)
                            Text("addnote.attachments.audio.label")
                                .font(.caption)
                                .foregroundColor(note.colorValue.isWhite ? .black : .white)
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
        .background(
            ZStack {
                if let backgroundImage = note.backgroundImage {
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .overlay(
                            Rectangle()
                                .fill(note.colorValue.opacity(0.7))
                        )
                } else {
                    note.colorValue
                }
            }
        )
        .cornerRadius(12)
        .contextMenu(isSelecting ? nil : ContextMenu {
            if note.isDone {
                Button(action: {
                    markAsDone()
                }) {
                    Label("stickynote.active.mark", systemImage: "arrow.clockwise")
                }
                Button(role: .destructive, action: {
                    showDeleteConfirmation = true
                }) {
                    Label("common.delete", systemImage: "trash")
                }
            } else {
                Button(action: {
                    onEdit()
                }) {
                    Label("common.edit", systemImage: "pencil")
                }
                Button(action: {
                    markAsDone()
                }) {
                    Label("home.tab.archive", systemImage: "archivebox")
                }
                Button(role: .destructive, action: {
                    showDeleteConfirmation = true
                }) {
                    Label("common.delete", systemImage: "trash")
                }
            }
        })
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("stickynote.delete"),
                message: Text("stickynote.delete.confirm"),
                primaryButton: .destructive(Text("common.delete")) {
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
    @EnvironmentObject var themeManager: ThemeManager
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
                    .foregroundColor(themeManager.theme.color)
                
                Text("stickynote.audio.player")
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
                                .foregroundColor(themeManager.theme.color)
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
            .navigationTitle("stickynote.audio.player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.done") {
                        audioPlayer?.pause()
                        dismiss()
                    }
                    .foregroundColor(themeManager.theme.color)
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
