//
//  AnalyticsView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 24/02/25.
//

import SwiftUI

struct AnalyticsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: NotesViewModel
    
    private var totalNotesCount: Int {
        viewModel.notes.count
    }
    
    private var activeNotesCount: Int {
        viewModel.notes.filter { !$0.isDone }.count
    }
    
    private var archivedNotesCount: Int {
        viewModel.notes.filter { $0.isDone }.count
    }
    
    private var categoryCounts: [(Category: NoteCategory, Count: Int)] {
        var counts: [NoteCategory: Int] = [:]
        for note in viewModel.notes {
            counts[note.category, default: 0] += 1
        }
        return counts.map { ($0.key, $0.value) }.sorted { $0.Count > $1.Count }
    }
    
    private var mostUsedCategory: NoteCategory? {
        categoryCounts.first?.Category
    }
    
    private var imageAttachmentCount: Int {
        viewModel.notes.filter { $0.attachmentData != nil || $0.backgroundImageData != nil }.count
    }
    
    private var videoAttachmentCount: Int {
        viewModel.notes.filter { $0.videoURLString != nil }.count
    }
    
    private var audioAttachmentCount: Int {
        viewModel.notes.filter { $0.audioURLString != nil }.count
    }

    private var fileAttachmentCount: Int {
        viewModel.notes.filter { $0.fileURLString != nil }.count
    }
    
    private var totalAttachmentsCount: Int {
        imageAttachmentCount + videoAttachmentCount + audioAttachmentCount + fileAttachmentCount
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Summary cards
                    HStack(spacing: 12) {
                        MetricCard(title: "common.total", value: "\(totalNotesCount)", icon: "note.text", color: themeManager.theme.color)
                        MetricCard(title: "analytics.active", value: "\(activeNotesCount)", icon: "doc.text", color: .green)
                        MetricCard(title: "home.tab.archive", value: "\(archivedNotesCount)", icon: "archivebox", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Attachments
                    VStack(alignment: .leading, spacing: 12) {
                        Text("home.filters.content.attachments")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        if totalAttachmentsCount == 0 {
                            Text("analytics.attachments.empty")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 16)
                        } else {
                            HStack(spacing: 12) {
                                AttachmentCard(title: "addnote.attachments.image.label", count: imageAttachmentCount, icon: "photo", color: .blue)
                                AttachmentCard(title: "addnote.attachments.video.label", count: videoAttachmentCount, icon: "video", color: .purple)
                                AttachmentCard(title: "addnote.attachments.audio.label", count: audioAttachmentCount, icon: "music.note", color: .orange)
                                AttachmentCard(title: "addnote.attachments.file.label", count: fileAttachmentCount, icon: "doc", color: .gray)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal)
                    
                    // Category breakdown
                    VStack(alignment: .leading, spacing: 10) {
                        Text("analytics.category.breakdown")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal)
                        
                        if categoryCounts.isEmpty {
                            Text("analytics.category.empty")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .padding(.horizontal)
                        } else {
                            if let mostUsed = mostUsedCategory, let mostUsedCount = categoryCounts.first?.Count {
                                HStack {
                                    Text("analytics.category.mostused")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Image(systemName: mostUsed.systemImage)
                                        .foregroundColor(themeManager.theme.color)
                                    Text(LocalizedStringKey(mostUsed.rawValue))
                                        .fontWeight(.semibold)
                                    Text("(\(mostUsedCount))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                            }
                            
                            VStack(spacing: 0) {
                                ForEach(categoryCounts, id: \.Category.id) { item in
                                    HStack {
                                        Image(systemName: item.Category.systemImage)
                                            .foregroundColor(themeManager.theme.color)
                                            .frame(width: 28)
                                        
                                        Text(LocalizedStringKey(item.Category.rawValue))
                                            .font(.body)
                                        
                                        Spacer()
                                        
                                        Text("\(item.Count)")
                                            .font(.body.weight(.semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 11)
                                    .padding(.horizontal, 16)
                                    
                                    if item.Category != categoryCounts.last?.Category {
                                        Divider()
                                            .padding(.leading, 52)
                                    }
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("analytics.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(themeManager.theme.color)
                }
            }
        }
    }
}

struct MetricCard: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.weight(.bold))
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct AttachmentCard: View {
    let title: LocalizedStringKey
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title2.weight(.bold))
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
