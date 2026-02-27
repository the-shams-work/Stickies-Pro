//
//  NoteDetailView.swift
//  Kipp
//
//  Created by Antigravity on 27/02/26.
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
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                
                // Metadata Section (Category, Date, Priority)
                HStack(spacing: 12) {
                    Label(note.category.rawValue, systemImage: note.category.systemImage)
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(note.colorValue.opacity(0.15))
                        .foregroundColor(note.colorValue)
                        .cornerRadius(8)
                    
                    if note.isTimeBounded {
                        Label(formattedDateRange(start: note.startDate, end: note.endDate), systemImage: "calendar")
                            .font(.footnote)
                            .foregroundColor(.secondary)
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
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Attachments Section
                if hasAttachments {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("addnote.attachments.label")
                            .font(.headline)
                            .foregroundColor(.secondary)
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
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let videoURL = note.videoURL {
                            VideoAttachmentView(videoURL: videoURL)
                        }
                        
                        if let audioURL = note.audioURL {
                            AudioAttachmentView(audioURL: audioURL)
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { showEditNote = true }) {
                    Image(systemName: "pencil")
                }
                
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Menu {
                    Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                        Label("common.delete", systemImage: "trash")
                    }
                    
                    Button(action: {
                        viewModel.markAsDone(id: note.id)
                        dismiss()
                    }) {
                        Label(note.isDone ? "stickynote.active.mark" : "home.tab.archive", 
                              systemImage: note.isDone ? "arrow.clockwise" : "archivebox")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
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
                .foregroundColor(.secondary)
        }
    }
}

struct AudioAttachmentView: View {
    let audioURL: URL
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
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading) {
                Text("addnote.attachments.audio.label")
                    .font(.subheadline.bold())
                Text(audioURL.lastPathComponent)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
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
