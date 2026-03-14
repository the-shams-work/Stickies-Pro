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

    /// Always read the latest version from the viewModel so edits are reflected live
    private var currentNote: StickyNote {
        viewModel.notes.first(where: { $0.id == note.id }) ?? note
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                HStack(alignment: .top, spacing: 8) {
                    Text(currentNote.title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(currentNote.colorValue.isLightColor ? .primary : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    
                    if currentNote.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.title2)
                            .foregroundColor(currentNote.colorValue.isLightColor ? .orange : .yellow)
                            .padding(.top, 6)
                    }
                }
                .padding(.top, 8)
                
                // Metadata chips
                FlowLayout(spacing: 8) {
                    MetadataChip(
                        icon: currentNote.category.systemImage,
                        text: String(localized: String.LocalizationValue(currentNote.category.rawValue)),
                        isLightColor: currentNote.colorValue.isLightColor
                    )
                    
                    MetadataChip(
                        icon: "clock",
                        text: formattedCreatedDate(currentNote.startDate),
                        isLightColor: currentNote.colorValue.isLightColor
                    )
                    
                    if currentNote.isTimeBounded {
                        MetadataChip(
                            icon: "calendar",
                            text: formattedDateRange(start: currentNote.startDate, end: currentNote.endDate),
                            isLightColor: currentNote.colorValue.isLightColor
                        )
                    }
                    
                    if currentNote.priority != .none {
                        MetadataChip(
                            icon: currentNote.priority.systemImage,
                            text: String(localized: String.LocalizationValue(currentNote.priority.rawValue)),
                            isLightColor: currentNote.colorValue.isLightColor
                        )
                    }
                }
                
                // Divider
                Rectangle()
                    .fill(currentNote.colorValue.isLightColor ? Color(.separator) : Color.white.opacity(0.2))
                    .frame(height: 0.5)
                
                // Content
                Text(currentNote.content)
                    .font(.body)
                    .lineSpacing(6)
                    .foregroundColor(currentNote.colorValue.isLightColor ? .primary : .white.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Attachments
                if hasAttachments {
                    VStack(alignment: .leading, spacing: 14) {
                        Label("addnote.attachments.title", systemImage: "paperclip")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(currentNote.colorValue.isLightColor ? .secondary : .white.opacity(0.8))
                            .padding(.top, 4)
                            .accessibilityAddTraits(.isHeader)
                        
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
                                    .foregroundColor(currentNote.colorValue.isLightColor ? .secondary : .white.opacity(0.7))
                            }
                        }
                        
                        if let videoURL = currentNote.videoURL {
                            VideoAttachmentView(videoURL: videoURL, note: currentNote)
                        }
                        
                        if let audioURL = currentNote.audioURL {
                            AudioAttachmentView(audioURL: audioURL, note: currentNote)
                        }
                        
                        if let fileURL = currentNote.fileURL {
                            FileAttachmentView(fileURL: fileURL, note: currentNote)
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
                                .fill(currentNote.colorValue.opacity(currentNote.colorValue.isLightColor ? 0.4 : 0.7))
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
                            .font(.title3.weight(.medium))
                    }
                    .foregroundColor(themeManager.theme.color)
                }
                .accessibilityLabel(Text("common.back"))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: { showEditNote = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 17, weight: .medium))
                    }

                    Menu {
                        Button(action: {
                            viewModel.togglePin(id: currentNote.id)
                        }) {
                            Label(
                                currentNote.isPinned ? "stickynote.unpin" : "stickynote.pin",
                                systemImage: currentNote.isPinned ? "pin.slash" : "pin"
                            )
                        }

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
                            .font(.body.weight(.medium))
                    }
                    .accessibilityLabel(Text("common.more"))
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
        currentNote.attachmentData != nil || currentNote.audioURLString != nil || currentNote.videoURLString != nil || currentNote.fileURLString != nil
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
            return String(format: String(localized: "common.today"), formatter.string(from: date))
        } else if calendar.isDateInYesterday(date) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return String(format: String(localized: "common.yesterday"), formatter.string(from: date))
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
                .foregroundColor(note.colorValue.isLightColor ? .secondary : .white.opacity(0.7))
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
                    .font(.largeTitle)
                    .foregroundColor(themeManager.theme.color)
            }
            .accessibilityLabel(Text(isPlaying ? "common.pause" : "common.play"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("addnote.attachments.audio.label")
                    .font(.subheadline.weight(.medium))
                Text(audioURL.lastPathComponent)
                    .font(.caption)
                    .foregroundColor(note.colorValue.isLightColor ? .secondary : .white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(note.colorValue.isLightColor ? Color(.secondarySystemBackground) : Color.white.opacity(0.15))
        )
    }
}

struct FileAttachmentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let fileURL: URL
    let note: StickyNote

    var body: some View {
        Button {
            UIApplication.shared.open(fileURL)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: iconForFileExtension(fileURL.pathExtension))
                    .font(.title2)
                    .foregroundColor(themeManager.theme.color)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(fileURL.lastPathComponent)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(note.colorValue.isLightColor ? .primary : .white)
                        .lineLimit(1)
                    Text(fileURL.pathExtension.uppercased() + " " + String(localized: "addfile.selected.suffix"))
                        .font(.caption)
                        .foregroundColor(note.colorValue.isLightColor ? .secondary : .white.opacity(0.7))
                }

                Spacer()

                Image(systemName: "arrow.up.right.square")
                    .font(.body)
                    .foregroundColor(note.colorValue.isLightColor ? .secondary : .white.opacity(0.6))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(note.colorValue.isLightColor ? Color(.secondarySystemBackground) : Color.white.opacity(0.15))
            )
        }
        .accessibilityLabel(Text("Open \(fileURL.lastPathComponent)"))
    }

    private func iconForFileExtension(_ ext: String) -> String {
        switch ext.lowercased() {
        case "pdf": return "doc.richtext.fill"
        case "doc", "docx": return "doc.text.fill"
        case "txt": return "doc.plaintext.fill"
        case "png", "jpg", "jpeg", "heic", "svg": return "photo.fill"
        case "zip", "rar", "7z", "gz": return "archivebox.fill"
        case "mp3", "m4a", "wav", "aiff": return "music.note"
        case "mp4", "mov", "avi": return "film"
        default: return "doc.fill"
        }
    }
}

// MARK: - Metadata Chip

struct MetadataChip: View {
    let icon: String
    let text: String
    var isLightColor: Bool = true
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
            .accessibilityElement(children: .combine)
    }
    
    private var chipBackground: Color {
        if let tintColor {
            return tintColor.opacity(0.12)
        }
        return isLightColor ? Color.primary.opacity(0.07) : Color.white.opacity(0.2)
    }
    
    private var chipForeground: Color {
        if let tintColor {
            return tintColor
        }
        return isLightColor ? .primary : .white
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
