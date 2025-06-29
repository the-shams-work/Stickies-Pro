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
        NavigationView {
            VStack {
                if viewModel.notes.filter({ $0.isDone }).isEmpty {
                    VStack {
                        Spacer()
                        Text("No Archived Notes Yet.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.notes.filter { $0.isDone }) { note in
                                StickyNoteView(
                                    note: note,
                                    markAsDone: { viewModel.markAsDone(id: note.id) },
                                    onEdit: {}, // Editing disabled in history
                                    onDelete: { viewModel.deleteNote(id: note.id) }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Archive")
        }
    }
}
