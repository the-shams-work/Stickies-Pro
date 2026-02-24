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
    
    private var totalAttachmentsCount: Int {
        imageAttachmentCount + videoAttachmentCount + audioAttachmentCount
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 15) {
                        MetricCard(title: "common.total", value: "\(totalNotesCount)", icon: "note.text", color: themeManager.theme.color)
                        MetricCard(title: "analytics.active", value: "\(activeNotesCount)", icon: "doc.text", color: themeManager.theme.color)
                        MetricCard(title: "home.tab.archive", value: "\(archivedNotesCount)", icon: "archivebox", color: themeManager.theme.color)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("home.filters.content.attachments")
                            .font(.headline)
                        
                        if totalAttachmentsCount == 0 {
                            Text("analytics.attachments.empty")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            HStack(spacing: 15) {
                                AttachmentCard(title: "addnote.attachments.image.label", count: imageAttachmentCount, icon: "photo", color: themeManager.theme.color)
                                AttachmentCard(title: "addnote.attachments.video.label", count: videoAttachmentCount, icon: "video", color: themeManager.theme.color)
                                AttachmentCard(title: "addnote.attachments.audio.label", count: audioAttachmentCount, icon: "music.note", color: themeManager.theme.color)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("analytics.category.breakdown")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if categoryCounts.isEmpty {
                            Text("analytics.category.empty")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
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
                                            .frame(width: 30)
                                        
                                        Text(LocalizedStringKey(item.Category.rawValue))
                                        
                                        Spacer()
                                        
                                        Text("\(item.Count)")
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                    
                                    if item.Category != categoryCounts.last?.Category {
                                        Divider()
                                            .padding(.leading, 50)
                                    }
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
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
                    Button("common.done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.theme.color)
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
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
    }
}

struct AttachmentCard: View {
    let title: LocalizedStringKey
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
    }
}
