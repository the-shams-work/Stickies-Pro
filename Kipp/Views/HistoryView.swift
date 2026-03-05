//
//  HistoryView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: NotesViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.notes.filter({ $0.isDone }).isEmpty {
                    HIGEmptyStateView(
                        icon: "archivebox",
                        title: "home.empty.archive",
                        message: "home.empty.archive.desc"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.notes.filter { $0.isDone }) { note in
                                StickyNoteView(
                                    note: note,
                                    markAsDone: { viewModel.markAsDone(id: note.id) },
                                    onEdit: {},
                                    onDelete: { viewModel.deleteNote(id: note.id) },
                                    onTogglePin: { viewModel.togglePin(id: note.id) }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("home.tab.archive")
            .background(Color(.systemGroupedBackground))
        }
    }
}
