//
//  NoteDetailView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 27/02/26.
//

import SwiftUI
import AVKit

struct NoteDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: NotesViewModel
    let note: StickyNote
    
    @State private var showEditNote = false
    @State private var showDeleteConfirmation = false
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title Section
                Text(note.title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(note.colorValue.isWhite ? .primary : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                
                // Metadata Section (Category, Date, Priority)
                HStack(spacing: 12) {
                    Label(note.category.rawValue, systemImage: note.category.systemImage)
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(note.colorValue.isWhite ? Color.primary.opacity(0.08) : Color.white.opacity(0.2))
                        .foregroundColor(note.colorValue.isWhite ? .primary : .white)
                        .cornerRadius(8)
                    
                    if note.isTimeBounded {
                        Label(formattedDateRange(start: note.startDate, end: note.endDate), systemImage: "calendar")
                            .font(.footnote)
                            .foregroundColor(note.colorValue.isWhite ? .secondary : .white.opacity(0.8))
                            .accentColor(themeManager.theme.color)
                    }
                    
                    Spacer()
                    
                    if note.priority != .none {
                        Text(note.priority.rawValue)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(priorityColor(note.priority).opacity(0.1))
                            .foregroundColor(priorityColor(note.priority))
                            .cornerRadius(4)
                    }
                }
                
                // Content Section
                Text(note.content)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .lineSpacing(6)
                    .foregroundColor(note.colorValue.isWhite ? .primary : .white.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Attachments Section
                if hasAttachments {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("addnote.attachments.label")
                            .font(.headline)
                            .foregroundColor(note.colorValue.isWhite ? .secondary : .white.opacity(0.8))
                            .padding(.top, 10)
                        
                        if let image = note.attachment {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: UIScreen.main.bounds.width - 40)
                                    .cornerRadius(12)
                                    .clipped()
                                
                                Text("addnote.attachments.image.label")
                                    .font(.caption)
                                    .foregroundColor(note.colorValue.isWhite ? .secondary : .white.opacity(0.7))
                            }
                        }
                        
                        if let videoURL = note.videoURL {
                            VideoAttachmentView(videoURL: videoURL, note: note)
                        }
                        
                        if let audioURL = note.audioURL {
                            AudioAttachmentView(audioURL: audioURL, note: note)
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(
            ZStack {
                if let backgroundImage = note.backgroundImage {
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .overlay(
                            Rectangle()
                                .fill(note.colorValue.opacity(note.colorValue.isWhite ? 0.4 : 0.7))
                                .ignoresSafeArea()
                        )
                } else {
                    note.colorValue.ignoresSafeArea()
                }
            }
        )
        .toolbar {

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.theme.color)
                        .frame(width: 36, height: 36)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 18) {

                    Button(action: { showEditNote = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 17, weight: .medium))
                    }

                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .medium))
                    }

                    Menu {
                        Button(role: .destructive, action: {
                            showDeleteConfirmation = true
                        }) {
                            Label("common.delete", systemImage: "trash")
                        }

                        Button(action: {
                            viewModel.markAsDone(id: note.id)
                            dismiss()
                        }) {
                            Label(
                                note.isDone ? "stickynote.active.mark" : "home.tab.archive",
                                systemImage: note.isDone ? "arrow.clockwise" : "archivebox"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 17, weight: .medium))
                    }
                }
                .foregroundColor(themeManager.theme.color)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
            }
        }
        .sheet(isPresented: $showEditNote) {
            NavigationStack {
                AddNoteView(
                    viewModel: viewModel,
                    showAddNote: $showEditNote,
                    editingNote: note
                )
            }
            .tint(themeManager.theme.color)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [note.title, note.content])
        }
        .alert("stickynote.delete", isPresented: $showDeleteConfirmation) {
            Button("common.delete", role: .destructive) {
                viewModel.deleteNote(id: note.id)
                dismiss()
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("stickynote.delete.confirm")
        }
    }
    
    private var hasAttachments: Bool {
        note.attachmentData != nil || note.audioURLString != nil || note.videoURLString != nil
    }
    
    private func formattedDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return formatter.string(from: start)
        } else {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
    
    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        case .none: return .secondary
        }
    }
}

struct VideoAttachmentView: View {
    let videoURL: URL
    let note: StickyNote
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VideoPlayer(player: player)
                .frame(height: 200)
                .cornerRadius(12)
                .onAppear {
                    player = AVPlayer(url: videoURL)
                }
            
            Text("addnote.attachments.video.label")
                .font(.caption)
                .foregroundColor(note.colorValue.isWhite ? .secondary : .white.opacity(0.7))
        }
    }
}

struct AudioAttachmentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let audioURL: URL
    let note: StickyNote
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    
    var body: some View {
        HStack {
            Button(action: {
                if isPlaying {
                    player?.pause()
                } else {
                    if player == nil {
                        player = AVPlayer(url: audioURL)
                    }
                    player?.play()
                }
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(themeManager.theme.color)
            }
            
            VStack(alignment: .leading) {
                Text("addnote.attachments.audio.label")
                    .font(.subheadline.bold())
                Text(audioURL.lastPathComponent)
                    .font(.caption)
                    .foregroundColor(note.colorValue.isWhite ? .secondary : .white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(note.colorValue.isWhite ? Color(.secondarySystemBackground) : Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
