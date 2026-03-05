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

    /// Always read the latest version from the viewModel so edits are reflected live
    private var currentNote: StickyNote {
        viewModel.notes.first(where: { $0.id == note.id }) ?? note
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(currentNote.title)
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(currentNote.colorValue.isWhite ? .primary : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                
                // Metadata chips
                FlowLayout(spacing: 8) {
                    MetadataChip(
                        icon: currentNote.category.systemImage,
                        text: currentNote.category.rawValue,
                        isWhite: currentNote.colorValue.isWhite
                    )
                    
                    MetadataChip(
                        icon: "clock",
                        text: formattedCreatedDate(currentNote.startDate),
                        isWhite: currentNote.colorValue.isWhite
                    )
                    
                    if currentNote.isTimeBounded {
                        MetadataChip(
                            icon: "calendar",
                            text: formattedDateRange(start: currentNote.startDate, end: currentNote.endDate),
                            isWhite: currentNote.colorValue.isWhite
                        )
                    }
                    
                    if currentNote.priority != .none {
                        MetadataChip(
                            icon: currentNote.priority.systemImage,
                            text: currentNote.priority.rawValue,
                            isWhite: currentNote.colorValue.isWhite
                        )
                    }
                }
                
                // Divider
                Rectangle()
                    .fill(currentNote.colorValue.isWhite ? Color(.separator) : Color.white.opacity(0.2))
                    .frame(height: 0.5)
                
                // Content
                Text(currentNote.content)
                    .font(.body)
                    .lineSpacing(6)
                    .foregroundColor(currentNote.colorValue.isWhite ? .primary : .white.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Attachments
                if hasAttachments {
                    VStack(alignment: .leading, spacing: 14) {
                        Label("addnote.attachments.label", systemImage: "paperclip")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(currentNote.colorValue.isWhite ? .secondary : .white.opacity(0.8))
                            .padding(.top, 4)
                        
                        if let image = currentNote.attachment {
                            VStack(alignment: .leading, spacing: 6) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: UIScreen.main.bounds.width - 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .clipped()
                                
                                Text("addnote.attachments.image.label")
                                    .font(.caption)
                                    .foregroundColor(currentNote.colorValue.isWhite ? .secondary : .white.opacity(0.7))
                            }
                        }
                        
                        if let videoURL = currentNote.videoURL {
                            VideoAttachmentView(videoURL: videoURL, note: currentNote)
                        }
                        
                        if let audioURL = currentNote.audioURL {
                            AudioAttachmentView(audioURL: audioURL, note: currentNote)
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
                if let backgroundImage = currentNote.backgroundImage {
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .overlay(
                            Rectangle()
                                .fill(currentNote.colorValue.opacity(currentNote.colorValue.isWhite ? 0.4 : 0.7))
                                .ignoresSafeArea()
                        )
                    if currentNote.backgroundStyle != .none {
                        BackgroundPatternOverlay(style: currentNote.backgroundStyle)
                            .ignoresSafeArea()
                    }
                } else if currentNote.backgroundStyle != .none {
                    // If note has a color, use it as base; otherwise use style background
                    if UIColor(currentNote.colorValue).cgColor.alpha < 0.05 {
                        currentNote.backgroundStyle.backgroundColor.ignoresSafeArea()
                    } else {
                        currentNote.colorValue.ignoresSafeArea()
                    }
                    BackgroundPatternOverlay(style: currentNote.backgroundStyle)
                        .ignoresSafeArea()
                } else {
                    // Transparent ("None") → use system background; otherwise show the color
                    if UIColor(currentNote.colorValue).cgColor.alpha < 0.05 {
                        Color(.systemBackground).ignoresSafeArea()
                    } else {
                        currentNote.colorValue.ignoresSafeArea()
                    }
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundColor(themeManager.theme.color)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: { showEditNote = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 17, weight: .medium))
                    }

                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .medium))
                    }

                    Menu {
                        Button(action: {
                            viewModel.markAsDone(id: currentNote.id)
                            dismiss()
                        }) {
                            Label(
                                currentNote.isDone ? "stickynote.active.mark" : "home.tab.archive",
                                systemImage: currentNote.isDone ? "arrow.clockwise" : "archivebox"
                            )
                        }

                        Button(role: .destructive, action: {
                            showDeleteConfirmation = true
                        }) {
                            Label("common.delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 17, weight: .medium))
                    }
                }
                .foregroundColor(themeManager.theme.color)
            }
        }
        .sheet(isPresented: $showEditNote) {
            NavigationStack {
                AddNoteView(
                    viewModel: viewModel,
                    showAddNote: $showEditNote,
                    editingNote: currentNote
                )
            }
            .tint(themeManager.theme.color)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [currentNote.title, currentNote.content])
        }
        .alert("stickynote.delete", isPresented: $showDeleteConfirmation) {
            Button("common.delete", role: .destructive) {
                viewModel.deleteNote(id: currentNote.id)
                dismiss()
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("stickynote.delete.confirm")
        }
    }
    
    private var hasAttachments: Bool {
        currentNote.attachmentData != nil || currentNote.audioURLString != nil || currentNote.videoURLString != nil
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

    private func formattedCreatedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        if calendar.isDateInToday(date) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return "Yesterday, \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
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
        VStack(alignment: .leading, spacing: 6) {
            VideoPlayer(player: player)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
        HStack(spacing: 12) {
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
                    .font(.system(size: 32))
                    .foregroundColor(themeManager.theme.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("addnote.attachments.audio.label")
                    .font(.subheadline.weight(.medium))
                Text(audioURL.lastPathComponent)
                    .font(.caption)
                    .foregroundColor(note.colorValue.isWhite ? .secondary : .white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(note.colorValue.isWhite ? Color(.secondarySystemBackground) : Color.white.opacity(0.15))
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Metadata Chip

struct MetadataChip: View {
    let icon: String
    let text: String
    var isWhite: Bool = true
    var tintColor: Color? = nil
    
    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(chipBackground)
            )
            .foregroundColor(chipForeground)
    }
    
    private var chipBackground: Color {
        if let tintColor {
            return tintColor.opacity(0.12)
        }
        return isWhite ? Color.primary.opacity(0.07) : Color.white.opacity(0.2)
    }
    
    private var chipForeground: Color {
        if let tintColor {
            return tintColor
        }
        return isWhite ? .primary : .white
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentY += lineHeight + spacing
                currentX = 0
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }
        
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentY += lineHeight + spacing
                currentX = bounds.minX
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}
