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
            HStack(alignment: .center) {
                if isSelecting {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? themeManager.theme.color : .secondary)
                        .font(.title3)
                        .transition(.scale)
                }
                
                Text(note.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(note.colorValue.isWhite ? .primary : .white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if hasAttachments {
                    Image(systemName: "paperclip")
                        .font(.caption2)
                        .foregroundColor(note.colorValue.isWhite ? .secondary : .white.opacity(0.6))
                }
            }

            Text(note.content)
                .font(.caption)
                .foregroundColor(note.colorValue.isWhite ? .secondary : .white.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                if note.isTimeBounded {
                    Text(formattedDate(note.startDate))
                        .font(.caption2)
                        .foregroundColor(note.colorValue.isWhite ? .secondary : .white.opacity(0.6))
                }
                
                Spacer()
                
                if note.priority != .none {
                    Text(note.priority.rawValue)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(priorityColor(note.priority).opacity(0.2))
                        )
                        .foregroundColor(priorityColor(note.priority))
                }
            }
        }
        .padding(12)
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
                } else if note.backgroundStyle != .none {
                    note.backgroundStyle.backgroundColor
                    BackgroundPatternOverlay(style: note.backgroundStyle)
                } else {
                    note.colorValue
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
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


