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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if isSelecting {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? themeManager.theme.color : .secondary)
                        .font(.title3)
                        .transition(.scale)
                }
                
                Text(note.title)
                    .font(.headline.bold())
                    .foregroundColor(note.colorValue.isWhite ? .black : .white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if hasAttachments {
                    Image(systemName: "paperclip")
                        .font(.caption)
                        .foregroundColor(note.colorValue.isWhite ? .black.opacity(0.6) : .white.opacity(0.6))
                }
            }

            Text(note.content)
                .font(.subheadline)
                .foregroundColor(note.colorValue.isWhite ? .black.opacity(0.9) : .white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            HStack {
                if note.isTimeBounded {
                    Text(formattedDate(note.startDate))
                        .font(.caption2)
                        .foregroundColor(note.colorValue.isWhite ? .black.opacity(0.7) : .white.opacity(0.7))
                }
                
                Spacer()
                
                if note.priority != .none {
                    Circle()
                        .fill(priorityColor(note.priority))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                if let backgroundImage = note.backgroundImage {
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .overlay(
                            Rectangle()
                                .fill(note.colorValue.opacity(0.75))
                        )
                } else {
                    note.colorValue
                }
            }
        )
        .cornerRadius(12)
        .contextMenu(isSelecting ? nil : ContextMenu {
            Button(action: { onEdit() }) {
                Label("common.edit", systemImage: "pencil")
            }
            Button(action: { markAsDone() }) {
                Label(note.isDone ? "stickynote.active.mark" : "home.tab.archive", 
                      systemImage: note.isDone ? "arrow.clockwise" : "archivebox")
            }
            Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                Label("common.delete", systemImage: "trash")
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

    private var hasAttachments: Bool {
        note.attachmentData != nil || note.audioURLString != nil || note.videoURLString != nil
    }

    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        case .none: return .clear
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}


